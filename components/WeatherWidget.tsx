"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  Cloud,
  CloudFog,
  CloudLightning,
  CloudRain,
  CloudMoon,
  CloudSun,
  Droplets,
  LocateFixed,
  MapPin,
  Moon,
  RefreshCw,
  Snowflake,
  Sun,
  Wind,
} from "lucide-react";
import type {
  WeatherData,
  WeatherWidgetProps,
} from "@/types/weather";
import { getWeatherPresentation } from "@/lib/weather";
import styles from "./WeatherWidget.module.css";

const DEFAULT_CITY = "Washington, D.C.";
const DEFAULT_LATITUDE = 38.9072;
const DEFAULT_LONGITUDE = -77.0369;

function WeatherIcon({
  name,
  size = 46,
}: {
  name: ReturnType<typeof getWeatherPresentation>["icon"];
  size?: number;
}) {
  const commonProps = {
    size,
    strokeWidth: 1.8,
    "aria-hidden": true,
  } as const;

  switch (name) {
    case "sun":
      return <Sun {...commonProps} />;
    case "moon":
      return <Moon {...commonProps} />;
    case "cloud-sun":
      return <CloudSun {...commonProps} />;
    case "cloud-moon":
      return <CloudMoon {...commonProps} />;
    case "cloud":
      return <Cloud {...commonProps} />;
    case "rain":
      return <CloudRain {...commonProps} />;
    case "snow":
      return <Snowflake {...commonProps} />;
    case "storm":
      return <CloudLightning {...commonProps} />;
    case "fog":
      return <CloudFog {...commonProps} />;
    default:
      return <Cloud {...commonProps} />;
  }
}

/**
 * Converts latitude/longitude into a human-readable place name.
 *
 * The app's API proxies the reverse-geocoding provider so precise coordinates
 * are not shared directly from the visitor's browser.
 */
async function getLocationName(
  latitude: number,
  longitude: number,
  locale: string,
): Promise<string | null> {
  try {
    const params = new URLSearchParams({
      latitude: String(latitude),
      longitude: String(longitude),
      locale,
    });

    const response = await fetch(`/api/weather/location?${params.toString()}`, {
      cache: "no-store",
    });

    if (!response.ok) {
      throw new Error(
        `Reverse geocoding failed with status ${response.status}.`,
      );
    }

    const data = (await response.json()) as { name?: string | null };

    return data.name ?? null;
  } catch (error) {
    console.error("Reverse geocoding error:", error);
    return null;
  }
}

export default function WeatherWidget({
  city = DEFAULT_CITY,
  latitude = DEFAULT_LATITUDE,
  longitude = DEFAULT_LONGITUDE,
  locale = "en",
  enableGeolocation = true,
  unitSystem = "metric",
}: WeatherWidgetProps) {
  const [weather, setWeather] = useState<WeatherData | null>(null);
  const [currentLocation, setCurrentLocation] = useState({
    latitude,
    longitude,
  });
  const [locationLabel, setLocationLabel] = useState(city);
  const [loading, setLoading] = useState(true);
  const [locating, setLocating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const requestControllerRef = useRef<AbortController | null>(null);

  const loadWeather = useCallback(
    async (nextLatitude: number, nextLongitude: number) => {
      requestControllerRef.current?.abort();

      const controller = new AbortController();
      requestControllerRef.current = controller;

      setLoading(true);
      setError(null);

      try {
        const response = await fetch(
          `/api/weather?lat=${encodeURIComponent(
            nextLatitude,
          )}&lon=${encodeURIComponent(nextLongitude)}&units=${unitSystem}`,
          {
            cache: "no-store",
            signal: controller.signal,
          },
        );

        const payload = (await response.json()) as
          | WeatherData
          | { error?: string };

        if (!response.ok) {
          throw new Error(
            "error" in payload && payload.error
              ? payload.error
              : "Unable to load weather.",
          );
        }

        setWeather(payload as WeatherData);
        setCurrentLocation({
          latitude: nextLatitude,
          longitude: nextLongitude,
        });
      } catch (requestError) {
        if (
          requestError instanceof Error &&
          requestError.name === "AbortError"
        ) {
          return;
        }

        console.error("WeatherWidget error:", requestError);
        setError("Weather is temporarily unavailable.");
      } finally {
        if (requestControllerRef.current === controller) {
          setLoading(false);
        }
      }
    },
    [unitSystem],
  );

  useEffect(() => {
    void loadWeather(latitude, longitude);

    return () => requestControllerRef.current?.abort();
  }, [latitude, longitude, loadWeather]);

  useEffect(() => {
    setLocationLabel(city);
  }, [city]);

  const presentation = useMemo(() => {
    if (!weather) return null;

    return getWeatherPresentation(weather.weatherCode, weather.isDay);
  }, [weather]);

  const formattedUpdatedAt = useMemo(() => {
    if (!weather?.updatedAt) return "";

    try {
      return new Intl.DateTimeFormat(locale, {
        hour: "2-digit",
        minute: "2-digit",
        timeZone:
          weather.timezone === "auto" ? undefined : weather.timezone,
      }).format(new Date(weather.updatedAt));
    } catch {
      return weather.updatedAt;
    }
  }, [locale, weather?.updatedAt, weather?.timezone]);

  const temperatureUnit = unitSystem === "imperial" ? "°F" : "°C";
  const windSpeedUnit = unitSystem === "imperial" ? "mph" : "km/h";

  function handleRefresh() {
    void loadWeather(
      currentLocation.latitude,
      currentLocation.longitude,
    );
  }

  async function handleLocate() {
    if (!navigator.geolocation) {
      setError("Geolocation is not supported by this browser.");
      return;
    }

    setLocating(true);
    setError(null);

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude, longitude } = position.coords;
        requestControllerRef.current?.abort();
        setWeather(null);
        setLocationLabel("Your location");
        setLocating(false);

        void loadWeather(latitude, longitude);

        try {
          const locationName = await getLocationName(
            latitude,
            longitude,
            locale,
          );

          setLocationLabel(locationName || "Your location");
        } catch {
          setLocationLabel("Your location");
        }
      },
      (positionError) => {
        setLocating(false);

        setError(
          positionError.code === positionError.PERMISSION_DENIED
            ? "Location permission was denied."
            : "Unable to determine your location.",
        );
      },
      {
        enableHighAccuracy: false,
        timeout: 8_000,
        maximumAge: 300_000,
      },
    );
  }

  const cardLabel = weather
    ? `${locationLabel}: ${Math.round(
        weather.temperature,
      )} degrees, ${
        presentation?.label ?? "Current weather"
      }`
    : `Weather for ${locationLabel}`;

  return (
    <section
      className={styles.weatherWidget}
      aria-label={cardLabel}
    >
      <div className={styles.header}>
        <div>
          <p className={styles.eyebrow}>Current weather</p>

          <h2 className={styles.city}>
            <MapPin size={17} aria-hidden="true" /> {locationLabel}
          </h2>
        </div>

        <div className={styles.actions}>
          {enableGeolocation ? (
            <button
              className={styles.actionButton}
              type="button"
              onClick={handleLocate}
              disabled={locating || loading}
              title="Use your current location"
            >
              <LocateFixed size={15} aria-hidden="true" />

              {locating ? "Locating…" : "My location"}
            </button>
          ) : null}

          <button
            className={styles.actionButton}
            type="button"
            onClick={handleRefresh}
            disabled={loading || locating}
            title="Refresh weather"
            aria-label="Refresh weather"
          >
            <RefreshCw
              className={loading ? styles.spin : undefined}
              size={15}
              aria-hidden="true"
            />

            <span className="visually-hidden">
              Refresh
            </span>
          </button>
        </div>
      </div>

      {loading && !weather ? (
        <div
          className={styles.status}
          role="status"
          aria-live="polite"
        >
          <RefreshCw
            className={styles.spin}
            size={28}
            aria-hidden="true"
          />

          <p className={styles.statusText}>
            Loading weather…
          </p>
        </div>
      ) : error && !weather ? (
        <div
          className={`${styles.status} ${styles.error}`}
          role="alert"
        >
          <p className={styles.statusText}>{error}</p>
        </div>
      ) : weather && presentation ? (
        <>
          <div className={styles.content}>
            <div className={styles.temperatureBlock}>
              <div
                className={styles.iconWrap}
                aria-hidden="true"
              >
                <WeatherIcon
                  name={presentation.icon}
                />
              </div>

              <div>
                <span className={styles.temperature}>
                  {Math.round(weather.temperature)}

                  <span className={styles.degree}>
                    {temperatureUnit}
                  </span>
                </span>

                <p className={styles.condition}>
                  {presentation.label}
                </p>

                <p className={styles.feelsLike}>
                  Feels like{" "}
                  {Math.round(weather.apparentTemperature)}
                  {temperatureUnit}
                </p>
              </div>
            </div>

            <div className={styles.metrics}>
              <div className={styles.metric}>
                <span className={styles.metricLabel}>
                  Humidity
                </span>

                <span className={styles.metricValue}>
                  <Droplets
                    size={15}
                    aria-hidden="true"
                  />{" "}
                  {Math.round(
                    weather.relativeHumidity,
                  )}
                  %
                </span>
              </div>

              <div className={styles.metric}>
                <span className={styles.metricLabel}>
                  Wind
                </span>

                <span className={styles.metricValue}>
                  <Wind
                    size={15}
                    aria-hidden="true"
                  />{" "}
                  {Math.round(weather.windSpeed)} {windSpeedUnit}
                </span>
              </div>
            </div>
          </div>

          {error ? (
            <p
              className={styles.statusText}
              role="status"
              aria-live="polite"
            >
              {error}
            </p>
          ) : null}

          <div className={styles.footer}>
            <span>
              Updated {formattedUpdatedAt}
            </span>

            <a
              className={styles.attribution}
              href="https://open-meteo.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              Weather data by Open-Meteo
            </a>
          </div>
        </>
      ) : null}
    </section>
  );
}
