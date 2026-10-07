// @vitest-environment jsdom
import { act } from "react";
import { createRoot, type Root } from "react-dom/client";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import WeatherWidget from "../../components/WeatherWidget";

const weatherResponse = (temperature = 20) =>
  new Response(
    JSON.stringify({
      latitude: 38.9072,
      longitude: -77.0369,
      timezone: "America/New_York",
      updatedAt: "2025-09-30T08:00:00.000Z",
      temperature,
      apparentTemperature: temperature - 1,
      relativeHumidity: 55,
      windSpeed: 8,
      weatherCode: 0,
      isDay: true,
    }),
  );

async function flushUpdates() {
  await act(async () => {
    await Promise.resolve();
    await Promise.resolve();
  });
}

describe("WeatherWidget", () => {
  let container: HTMLDivElement;
  let root: Root;
  let originalGeolocation: Geolocation | undefined;

  beforeEach(async () => {
    (globalThis as typeof globalThis & { IS_REACT_ACT_ENVIRONMENT: boolean })
      .IS_REACT_ACT_ENVIRONMENT = true;
    container = document.createElement("div");
    document.body.append(container);
    root = createRoot(container);
    originalGeolocation = navigator.geolocation;
    vi.spyOn(console, "error").mockImplementation(() => undefined);
  });

  afterEach(async () => {
    await act(async () => root.unmount());
    container.remove();
    Object.defineProperty(navigator, "geolocation", {
      configurable: true,
      value: originalGeolocation,
    });
    vi.restoreAllMocks();
    vi.unstubAllGlobals();
  });

  it("does not pair a new city label with a stale reading after its request fails", async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(weatherResponse())
      .mockRejectedValueOnce(new Error("network unavailable"));
    vi.stubGlobal("fetch", fetchMock);

    await act(async () => {
      root.render(
        <WeatherWidget
          city="Washington, D.C."
          latitude={38.9072}
          longitude={-77.0369}
          enableGeolocation={false}
        />,
      );
    });
    await flushUpdates();
    expect(container.textContent).toContain("20°C");

    await act(async () => {
      root.render(
        <WeatherWidget
          city="Paris"
          latitude={48.8566}
          longitude={2.3522}
          enableGeolocation={false}
        />,
      );
    });
    await flushUpdates();

    expect(container.textContent).toContain("Paris");
    expect(container.textContent).not.toContain("20°C");
    expect(container.textContent).toContain("Weather is temporarily unavailable.");
    expect(
      new URL(fetchMock.mock.calls[1][0] as string, "https://example.test")
        .searchParams.get("lat"),
    ).toBe("48.8566");
  });

  it("reports a geolocation failure without describing the weather reading as stale", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(weatherResponse()));
    Object.defineProperty(navigator, "geolocation", {
      configurable: true,
      value: {
        getCurrentPosition: (
          _success: PositionCallback,
          failure: PositionErrorCallback,
        ) => failure({ code: 1, PERMISSION_DENIED: 1 } as GeolocationPositionError),
      },
    });

    await act(async () => {
      root.render(<WeatherWidget />);
    });
    await flushUpdates();

    const locationButton = container.querySelector<HTMLButtonElement>(
      '[title="Use your current location"]',
    );
    expect(locationButton).not.toBeNull();

    await act(async () => {
      locationButton?.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    });

    expect(container.textContent).toContain("Location permission was denied.");
    expect(container.textContent).not.toContain("Unable to refresh. Showing the last available reading.");
  });

  it("keeps a geocoded location label when only the locale changes", async () => {
    vi.stubGlobal(
      "fetch",
      vi.fn((input: string) =>
        input.startsWith("/api/weather/location")
          ? Promise.resolve(new Response(JSON.stringify({ name: "Algiers" })))
          : Promise.resolve(weatherResponse()),
      ),
    );
    Object.defineProperty(navigator, "geolocation", {
      configurable: true,
      value: {
        getCurrentPosition: (success: PositionCallback) =>
          success({ coords: { latitude: 36.7538, longitude: 3.0588 } } as GeolocationPosition),
      },
    });

    await act(async () => {
      root.render(<WeatherWidget city="Washington, D.C." />);
    });
    await flushUpdates();

    await act(async () => {
      container
        .querySelector<HTMLButtonElement>('[title="Use your current location"]')
        ?.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    });
    await flushUpdates();

    expect(container.textContent).toContain("Algiers");

    await act(async () => {
      root.render(<WeatherWidget city="Washington, D.C." locale="fr-FR" />);
    });

    expect(container.textContent).toContain("Algiers");
  });
});
