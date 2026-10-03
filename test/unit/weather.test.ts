import { describe, expect, it, vi } from "vitest";
import {
  getCurrentWeather,
  getWeatherPresentation,
  normalizeCoordinates,
} from "../../lib/weather";
import { GET as getWeatherLocation } from "../../app/api/weather/location/route";

describe("weather helpers", () => {
  it("normalizes valid coordinates to four decimal places", () => {
    expect(normalizeCoordinates(36.75384, 3.05882)).toEqual({
      latitude: 36.7538,
      longitude: 3.0588,
    });
  });

  it("rejects coordinates outside the geographic bounds", () => {
    expect(() => normalizeCoordinates(91, 3)).toThrow("Invalid latitude.");
    expect(() => normalizeCoordinates(36, 181)).toThrow("Invalid longitude.");
  });

  it("maps representative weather codes to user-facing conditions", () => {
    expect(getWeatherPresentation(0, true)).toEqual({ label: "Clear sky", icon: "sun" });
    expect(getWeatherPresentation(0, false)).toEqual({ label: "Clear sky", icon: "moon" });
    expect(getWeatherPresentation(63)).toEqual({ label: "Rain", icon: "rain" });
    expect(getWeatherPresentation(95)).toEqual({ label: "Thunderstorm", icon: "storm" });
  });

  it("requests imperial units and converts the provider timestamp to ISO", async () => {
    const fetchMock = vi.fn().mockResolvedValue(
      new Response(
        JSON.stringify({
          latitude: 38.9072,
          longitude: -77.0369,
          timezone: "America/New_York",
          current: {
            time: 1_759_219_200,
            temperature_2m: 72,
            relative_humidity_2m: 55,
            apparent_temperature: 70,
            wind_speed_10m: 8,
            weather_code: 0,
            is_day: 1,
          },
        }),
      ),
    );
    vi.stubGlobal("fetch", fetchMock);

    try {
      const weather = await getCurrentWeather(38.9072, -77.0369, "imperial");

      expect(weather.updatedAt).toBe("2025-09-30T08:00:00.000Z");
      const requestUrl = new URL(fetchMock.mock.calls[0][0] as string);
      expect(requestUrl.searchParams.get("temperature_unit")).toBe("fahrenheit");
      expect(requestUrl.searchParams.get("wind_speed_unit")).toBe("mph");
      expect(requestUrl.searchParams.get("timeformat")).toBe("unixtime");
    } finally {
      vi.unstubAllGlobals();
    }
  });

  it("prefers a city-level name over its enclosing subdivision", async () => {
    const fetchMock = vi.fn().mockResolvedValue(
      new Response(
        JSON.stringify({
          city: "Algiers",
          principalSubdivision: "Algiers Province",
          countryName: "Algeria",
        }),
      ),
    );
    vi.stubGlobal("fetch", fetchMock);

    try {
      const response = await getWeatherLocation(
        new Request(
          "https://example.test/api/weather/location?lat=36.7538&lon=3.0588&locale=fr-FR",
        ),
      );

      expect(await response.json()).toEqual({ name: "Algiers" });

      const providerUrl = new URL(fetchMock.mock.calls[0]?.[0] as string);
      expect(providerUrl.searchParams.get("localityLanguage")).toBe("fr");
    } finally {
      vi.unstubAllGlobals();
    }
  });
});
