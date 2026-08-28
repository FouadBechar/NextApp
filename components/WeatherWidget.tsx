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
import type { WeatherData, WeatherWidgetProps } from "@/types/weather";
import { getWeatherPresentation } from "@/lib/weather";
import styles from "./WeatherWidget.module.css";

const DEFAULT_CITY = "Algiers";
const DEFAULT_LATITUDE = 36.7538;
const DEFAULT_LONGITUDE = 3.0588;

function WeatherIcon({ name, size = 46 }: { name: ReturnType<typeof getWeatherPresentation>["icon"]; size?: number }) {
  const commonProps = { size, strokeWidth: 1.8, "aria-hidden": true } as const;

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


export default function WeatherWidget({
  city = DEFAULT_CITY,
  latitude = DEFAULT_LATITUDE,
  longitude = DEFAULT_LONGITUDE,
  locale = "en",
  enableGeolocation = true,
}: WeatherWidgetProps) {
  const [weather, setWeather] = useState<WeatherData | null>(null);
  const [currentLocation, setCurrentLocation] = useState({ latitude, longitude });
  const [locationLabel, setLocationLabel] = useState(city);
  const [loading, setLoading] = useState(true);
  const [locating, setLocating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const requestControllerRef = useRef<AbortController | null>(null);

  const loadWeather = useCallback(async (nextLatitude: number, nextLongitude: number) => {
    requestControllerRef.current?.abort();
    const controller = new AbortController();
    requestControllerRef.current = controller;
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `/api/weather?lat=${encodeURIComponent(nextLatitude)}&lon=${encodeURIComponent(nextLongitude)}`,
        { cache: "no-store", signal: controller.signal },
      );

      const payload = (await response.json()) as WeatherData | { error?: string };

      if (!response.ok) {
        throw new Error("error" in payload && payload.error ? payload.error : "Unable to load weather.");
      }

      setWeather(payload as WeatherData);
      setCurrentLocation({ latitude: nextLatitude, longitude: nextLongitude });
    } catch (requestError) {
      if (requestError instanceof Error && requestError.name === "AbortError") return;
      console.error("WeatherWidget error:", requestError);
      setError("Weather is temporarily unavailable.");
    } finally {
      if (requestControllerRef.current === controller) setLoading(false);
    }
  }, []);

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
        timeZone: weather.timezone === "auto" ? undefined : weather.timezone,
      }).format(new Date(weather.updatedAt));
    } catch {
      return weather.updatedAt;
    }
  }, [locale, weather?.updatedAt]);

  function handleRefresh() {
    void loadWeather(currentLocation.latitude, currentLocation.longitude);
  }

  function handleLocate() {
    if (!navigator.geolocation) {
      setError("Geolocation is not supported by this browser.");
      return;
    }

    setLocating(true);
    setError(null);

    navigator.geolocation.getCurrentPosition(
      (position) => {
        setLocationLabel("Your location");
        setLocating(false);
        void loadWeather(position.coords.latitude, position.coords.longitude);
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
    ? `${locationLabel}: ${Math.round(weather.temperature)} degrees, ${presentation?.label ?? "Current weather"}`
    : `Weather for ${locationLabel}`;

  return (
    <section className={styles.weatherWidget} aria-label={cardLabel}>
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
            <RefreshCw className={loading ? styles.spin : undefined} size={15} aria-hidden="true" />
            <span className="visually-hidden">Refresh</span>
          </button>
        </div>
      </div>

      {loading && !weather ? (
        <div className={styles.status} role="status" aria-live="polite">
          <RefreshCw className={styles.spin} size={28} aria-hidden="true" />
          <p className={styles.statusText}>Loading weather…</p>
        </div>
      ) : error && !weather ? (
        <div className={`${styles.status} ${styles.error}`} role="alert">
          <p className={styles.statusText}>{error}</p>
        </div>
      ) : weather && presentation ? (
        <>
          <div className={styles.content}>
            <div className={styles.temperatureBlock}>
              <div className={styles.iconWrap} aria-hidden="true">
                <WeatherIcon name={presentation.icon} />
              </div>

              <div>
                <span className={styles.temperature}>
                  {Math.round(weather.temperature)}
                  <span className={styles.degree}>°C</span>
                </span>
                <p className={styles.condition}>{presentation.label}</p>
                <p className={styles.feelsLike}>
                  Feels like {Math.round(weather.apparentTemperature)}°C
                </p>
              </div>
            </div>

            <div className={styles.metrics}>
              <div className={styles.metric}>
                <span className={styles.metricLabel}>Humidity</span>
                <span className={styles.metricValue}>
                  <Droplets size={15} aria-hidden="true" /> {Math.round(weather.relativeHumidity)}%
                </span>
              </div>
              <div className={styles.metric}>
                <span className={styles.metricLabel}>Wind</span>
                <span className={styles.metricValue}>
                  <Wind size={15} aria-hidden="true" /> {Math.round(weather.windSpeed)} km/h
                </span>
              </div>
            </div>
          </div>

          {error ? (
            <p className={styles.statusText} role="status" aria-live="polite">
              {error}
            </p>
          ) : null}

          <div className={styles.footer}>
            <span>Updated {formattedUpdatedAt}</span>
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
