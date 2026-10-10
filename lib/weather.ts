import type { WeatherData, WeatherUnitSystem } from "@/types/weather";

const OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast";
const REQUEST_TIMEOUT_MS = 8_000;

function isValidCoordinate(value: number, min: number, max: number): boolean {
  return Number.isFinite(value) && value >= min && value <= max;
}

export function normalizeCoordinates(latitude: number, longitude: number) {
  if (!isValidCoordinate(latitude, -90, 90)) {
    throw new Error("Invalid latitude.");
  }

  if (!isValidCoordinate(longitude, -180, 180)) {
    throw new Error("Invalid longitude.");
  }

  return {
    latitude: Number(latitude.toFixed(4)),
    longitude: Number(longitude.toFixed(4)),
  };
}

export async function getCurrentWeather(
  latitude: number,
  longitude: number,
  unitSystem: WeatherUnitSystem = "metric",
): Promise<WeatherData> {
  const coordinates = normalizeCoordinates(latitude, longitude);

  const params = new URLSearchParams({
    latitude: String(coordinates.latitude),
    longitude: String(coordinates.longitude),
    current: [
      "temperature_2m",
      "relative_humidity_2m",
      "apparent_temperature",
      "wind_speed_10m",
      "weather_code",
      "is_day",
    ].join(","),
    temperature_unit: unitSystem === "imperial" ? "fahrenheit" : "celsius",
    wind_speed_unit: unitSystem === "imperial" ? "mph" : "kmh",
    timezone: "auto",
    timeformat: "unixtime",
  });

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(`${OPEN_METEO_URL}?${params.toString()}`, {
      signal: controller.signal,
      next: { revalidate: 600 },
      headers: {
        Accept: "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`Weather provider returned ${response.status}.`);
    }

    const payload = (await response.json()) as {
      latitude?: number;
      longitude?: number;
      timezone?: string;
      current?: {
        time?: number;
        temperature_2m?: number;
        relative_humidity_2m?: number;
        apparent_temperature?: number;
        wind_speed_10m?: number;
        weather_code?: number;
        is_day?: number;
      };
    };

    const current = payload.current;

    if (
      !current ||
      typeof current.time !== "number" ||
      typeof current.temperature_2m !== "number" ||
      typeof current.relative_humidity_2m !== "number" ||
      typeof current.apparent_temperature !== "number" ||
      typeof current.wind_speed_10m !== "number" ||
      typeof current.weather_code !== "number" ||
      typeof current.is_day !== "number"
    ) {
      throw new Error("Weather provider returned an incomplete response.");
    }

    return {
      latitude: typeof payload.latitude === "number" ? payload.latitude : coordinates.latitude,
      longitude:
        typeof payload.longitude === "number" ? payload.longitude : coordinates.longitude,
      timezone: typeof payload.timezone === "string" ? payload.timezone : "auto",
      updatedAt: new Date(current.time * 1_000).toISOString(),
      temperature: current.temperature_2m,
      apparentTemperature: current.apparent_temperature,
      relativeHumidity: current.relative_humidity_2m,
      windSpeed: current.wind_speed_10m,
      weatherCode: current.weather_code,
      isDay: current.is_day === 1,
    };
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      throw new Error("Weather request timed out.");
    }

    throw error instanceof Error ? error : new Error("Unable to load weather data.");
  } finally {
    clearTimeout(timeout);
  }
}

export interface WeatherPresentation {
  label: string;
  icon: "sun" | "moon" | "cloud-sun" | "cloud-moon" | "cloud" | "rain" | "snow" | "storm" | "fog";
}

export function getWeatherPresentation(
  weatherCode: number,
  isDay = true,
): WeatherPresentation {
  if (weatherCode === 0) {
    return isDay
      ? { label: "Clear sky", icon: "sun" }
      : { label: "Clear sky", icon: "moon" };
  }

  if ([1, 2].includes(weatherCode)) {
    return isDay
      ? { label: "Partly cloudy", icon: "cloud-sun" }
      : { label: "Partly cloudy", icon: "cloud-moon" };
  }

  if (weatherCode === 3) {
    return { label: "Overcast", icon: "cloud" };
  }

  if ([45, 48].includes(weatherCode)) {
    return { label: "Foggy", icon: "fog" };
  }

  if ([51, 53, 55, 56, 57].includes(weatherCode)) {
    return { label: "Drizzle", icon: "rain" };
  }

  if ([61, 63, 65, 66, 67, 80, 81, 82].includes(weatherCode)) {
    return { label: "Rain", icon: "rain" };
  }

  if ([71, 73, 75, 77, 85, 86].includes(weatherCode)) {
    return { label: "Snow", icon: "snow" };
  }

  if ([95, 96, 99].includes(weatherCode)) {
    return { label: "Thunderstorm", icon: "storm" };
  }

  return { label: "Unknown conditions", icon: isDay ? "cloud-sun" : "cloud-moon" };
}
