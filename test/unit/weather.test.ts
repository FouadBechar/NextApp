import { describe, expect, it } from "vitest";
import { getWeatherPresentation, normalizeCoordinates } from "../../lib/weather";

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
});
