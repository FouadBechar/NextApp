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

type WeatherCopy = {
  currentWeather: string;
  myLocation: string;
  locating: string;
  useCurrentLocation: string;
  refresh: string;
  refreshWeather: string;
  loadingWeather: string;
  geolocationUnsupported: string;
  locationPermissionDenied: string;
  locationUnavailable: string;
  weatherUnavailable: string;
  showingLastReading: string;
  feelsLike: string;
  humidity: string;
  wind: string;
  observedAt: string;
  weatherDataBy: string;
  weatherFor: (location: string) => string;
  cardLabel: (location: string, temperature: string, condition: string) => string;
};

type Location = {
  latitude: number;
  longitude: number;
  label: string;
};

const WEATHER_COPY: Record<"en" | "fr" | "ar", WeatherCopy> = {
  en: {
    currentWeather: "Current weather",
    myLocation: "My location",
    locating: "Locating…",
    useCurrentLocation: "Use your current location",
    refresh: "Refresh",
    refreshWeather: "Refresh weather",
    loadingWeather: "Loading weather…",
    geolocationUnsupported: "Geolocation is not supported by this browser.",
    locationPermissionDenied: "Location permission was denied.",
    locationUnavailable: "Unable to determine your location.",
    weatherUnavailable: "Weather is temporarily unavailable.",
    showingLastReading: "Unable to refresh. Showing the last available reading.",
    feelsLike: "Feels like",
    humidity: "Humidity",
    wind: "Wind",
    observedAt: "Observed at",
    weatherDataBy: "Weather data by Open-Meteo",
    weatherFor: (location) => `Weather for ${location}`,
    cardLabel: (location, temperature, condition) =>
      `${location}: ${temperature} degrees, ${condition}`,
  },
  fr: {
    currentWeather: "Météo actuelle",
    myLocation: "Ma position",
    locating: "Localisation…",
    useCurrentLocation: "Utiliser votre position actuelle",
    refresh: "Actualiser",
    refreshWeather: "Actualiser la météo",
    loadingWeather: "Chargement de la météo…",
    geolocationUnsupported: "La géolocalisation n’est pas prise en charge par ce navigateur.",
    locationPermissionDenied: "L’autorisation de localisation a été refusée.",
    locationUnavailable: "Impossible de déterminer votre position.",
    weatherUnavailable: "La météo est temporairement indisponible.",
    showingLastReading: "Actualisation impossible. Affichage de la dernière donnée disponible.",
    feelsLike: "Ressenti",
    humidity: "Humidité",
    wind: "Vent",
    observedAt: "Observé à",
    weatherDataBy: "Données météo par Open-Meteo",
    weatherFor: (location) => `Météo pour ${location}`,
    cardLabel: (location, temperature, condition) =>
      `${location} : ${temperature} degrés, ${condition}`,
  },
  ar: {
    currentWeather: "الطقس الحالي",
    myLocation: "موقعي",
    locating: "جارٍ تحديد الموقع…",
    useCurrentLocation: "استخدام موقعك الحالي",
    refresh: "تحديث",
    refreshWeather: "تحديث الطقس",
    loadingWeather: "جارٍ تحميل الطقس…",
    geolocationUnsupported: "تحديد الموقع الجغرافي غير مدعوم في هذا المتصفح.",
    locationPermissionDenied: "تم رفض إذن تحديد الموقع.",
    locationUnavailable: "تعذر تحديد موقعك.",
    weatherUnavailable: "بيانات الطقس غير متاحة مؤقتًا.",
    showingLastReading: "تعذر التحديث. يتم عرض آخر قراءة متاحة.",
    feelsLike: "المحسوس",
    humidity: "الرطوبة",
    wind: "الرياح",
    observedAt: "وقت الرصد",
    weatherDataBy: "بيانات الطقس من Open-Meteo",
    weatherFor: (location) => `الطقس في ${location}`,
    cardLabel: (location, temperature, condition) =>
      `${location}: ${temperature} درجة، ${condition}`,
  },
};

const CONDITION_COPY: Record<"en" | "fr" | "ar", Record<string, string>> = {
  en: {},
  fr: {
    "Clear sky": "Ciel dégagé",
    "Partly cloudy": "Partiellement nuageux",
    Overcast: "Couvert",
    Foggy: "Brumeux",
    Drizzle: "Bruine",
    Rain: "Pluie",
    Snow: "Neige",
    Thunderstorm: "Orage",
    "Unknown conditions": "Conditions inconnues",
  },
  ar: {
    "Clear sky": "سماء صافية",
    "Partly cloudy": "غائم جزئيًا",
    Overcast: "غائم",
    Foggy: "ضبابي",
    Drizzle: "رذاذ",
    Rain: "مطر",
    Snow: "ثلج",
    Thunderstorm: "عاصفة رعدية",
    "Unknown conditions": "ظروف غير معروفة",
  },
};

function getLanguage(locale: string): "en" | "fr" | "ar" {
  const language = locale.split("-")[0]?.toLowerCase();
  return language === "fr" || language === "ar" ? language : "en";
}

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
  signal: AbortSignal,
): Promise<string | null> {
  try {
    const params = new URLSearchParams({
      lat: String(latitude),
      lon: String(longitude),
      locale,
    });

    const response = await fetch(`/api/weather/location?${params.toString()}`, {
      cache: "no-store",
      signal,
    });

    if (!response.ok) {
      throw new Error(
        `Reverse geocoding failed with status ${response.status}.`,
      );
    }

    const data = (await response.json()) as { name?: string | null };

    return data.name ?? null;
  } catch (error) {
    if (error instanceof Error && error.name === "AbortError") {
      return null;
    }

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
  const [currentLocation, setCurrentLocation] = useState<Location>({
    latitude,
    longitude,
    label: city,
  });
  const [loading, setLoading] = useState(true);
  const [locating, setLocating] = useState(false);
  const [hasWeatherError, setHasWeatherError] = useState(false);
  const [locationError, setLocationError] = useState<string | null>(null);
  const requestControllerRef = useRef<AbortController | null>(null);
  const weatherRequestIdRef = useRef(0);
  const locationRequestIdRef = useRef(0);
  const locationControllerRef = useRef<AbortController | null>(null);
  const isMountedRef = useRef(true);
  const unitSystemRef = useRef(unitSystem);
  const providedLocationRef = useRef<Location | null>(null);
  const language = useMemo(() => getLanguage(locale), [locale]);
  const copy = useMemo(() => WEATHER_COPY[language], [language]);
  const numberFormatter = useMemo(() => {
    try {
      return new Intl.NumberFormat(locale, { maximumFractionDigits: 0 });
    } catch {
      return new Intl.NumberFormat("en", { maximumFractionDigits: 0 });
    }
  }, [locale]);
  unitSystemRef.current = unitSystem;

  const loadWeather = useCallback(
    async (nextLatitude: number, nextLongitude: number) => {
      requestControllerRef.current?.abort();

      const controller = new AbortController();
      requestControllerRef.current = controller;
      const requestId = ++weatherRequestIdRef.current;

      setLoading(true);
      setHasWeatherError(false);

      try {
        const response = await fetch(
          `/api/weather?lat=${encodeURIComponent(
            nextLatitude,
          )}&lon=${encodeURIComponent(nextLongitude)}&units=${unitSystemRef.current}`,
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

        if (
          !isMountedRef.current ||
          weatherRequestIdRef.current !== requestId
        ) {
          return;
        }

        setWeather(payload as WeatherData);
      } catch (requestError) {
        if (
          requestError instanceof Error &&
          requestError.name === "AbortError"
        ) {
          return;
        }

        if (
          !isMountedRef.current ||
          weatherRequestIdRef.current !== requestId
        ) {
          return;
        }

        console.error("WeatherWidget error:", requestError);
        setHasWeatherError(true);
      } finally {
        if (
          isMountedRef.current &&
          weatherRequestIdRef.current === requestId
        ) {
          setLoading(false);
        }
      }
    },
    [],
  );

  useEffect(() => {
    const nextProvidedLocation = { latitude, longitude, label: city };
    const previousProvidedLocation = providedLocationRef.current;
    const hasLocationChanged =
      !previousProvidedLocation ||
      previousProvidedLocation.latitude !== latitude ||
      previousProvidedLocation.longitude !== longitude ||
      previousProvidedLocation.label !== city;

    providedLocationRef.current = nextProvidedLocation;

    if (hasLocationChanged) {
      setCurrentLocation(nextProvidedLocation);
      setWeather(null);
      setLocating(false);
      setLocationError(null);
      locationRequestIdRef.current += 1;
      locationControllerRef.current?.abort();
      void loadWeather(latitude, longitude);
    } else {
      void loadWeather(currentLocation.latitude, currentLocation.longitude);
    }

    return () => requestControllerRef.current?.abort();
    // currentLocation is intentionally omitted: a unit change should reload the
    // selected location, but selecting a location should not trigger this effect.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [city, latitude, longitude, unitSystem, loadWeather]);

  useEffect(() => {
    isMountedRef.current = true;

    return () => {
      isMountedRef.current = false;
      weatherRequestIdRef.current += 1;
      locationRequestIdRef.current += 1;
      requestControllerRef.current?.abort();
      locationControllerRef.current?.abort();
    };
  }, []);

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
  const formattedTemperature = weather
    ? numberFormatter.format(weather.temperature)
    : "";
  const formattedApparentTemperature = weather
    ? numberFormatter.format(weather.apparentTemperature)
    : "";
  const formattedHumidity = weather
    ? numberFormatter.format(weather.relativeHumidity)
    : "";
  const formattedWindSpeed = weather
    ? numberFormatter.format(weather.windSpeed)
    : "";
  const conditionLabel = presentation
    ? CONDITION_COPY[language][presentation.label] ?? presentation.label
    : copy.currentWeather;

  function handleRefresh() {
    void loadWeather(
      currentLocation.latitude,
      currentLocation.longitude,
    );
  }

  async function handleLocate() {
    if (!navigator.geolocation) {
      setLocationError(copy.geolocationUnsupported);
      return;
    }

    locationControllerRef.current?.abort();
    const locationRequestId = ++locationRequestIdRef.current;
    setLocating(true);
    setLocationError(null);

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        if (
          !isMountedRef.current ||
          locationRequestIdRef.current !== locationRequestId
        ) {
          return;
        }

        const { latitude, longitude } = position.coords;
        setWeather(null);
        setCurrentLocation({
          latitude,
          longitude,
          label: copy.myLocation,
        });
        setLocating(false);

        void loadWeather(latitude, longitude);

        const controller = new AbortController();
        locationControllerRef.current = controller;
        const locationName = await getLocationName(
          latitude,
          longitude,
          locale,
          controller.signal,
        );

        if (
          isMountedRef.current &&
          locationRequestIdRef.current === locationRequestId &&
          !controller.signal.aborted
        ) {
          setCurrentLocation({
            latitude,
            longitude,
            label: locationName || copy.myLocation,
          });
        }
      },
      (positionError) => {
        if (
          !isMountedRef.current ||
          locationRequestIdRef.current !== locationRequestId
        ) {
          return;
        }

        setLocating(false);

        setLocationError(
          positionError.code === positionError.PERMISSION_DENIED
            ? copy.locationPermissionDenied
            : copy.locationUnavailable,
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
    ? copy.cardLabel(currentLocation.label, formattedTemperature, conditionLabel)
    : copy.weatherFor(currentLocation.label);
  const fatalError = hasWeatherError
    ? copy.weatherUnavailable
    : locationError;

  return (
    <section
      className={styles.weatherWidget}
      aria-label={cardLabel}
      aria-busy={loading || locating}
    >
      <div className={styles.header}>
        <div>
          <p className={styles.eyebrow}>{copy.currentWeather}</p>

          <h2 className={styles.city}>
            <MapPin size={17} aria-hidden="true" /> {currentLocation.label}
          </h2>
        </div>

        <div className={styles.actions}>
          {enableGeolocation ? (
            <button
              className={styles.actionButton}
              type="button"
              onClick={handleLocate}
              disabled={locating}
              title={copy.useCurrentLocation}
            >
              <LocateFixed size={15} aria-hidden="true" />

              {locating ? copy.locating : copy.myLocation}
            </button>
          ) : null}

          <button
            className={styles.actionButton}
            type="button"
            onClick={handleRefresh}
            disabled={loading || locating}
            title={copy.refreshWeather}
            aria-label={copy.refreshWeather}
          >
            <RefreshCw
              className={loading ? styles.spin : undefined}
              size={15}
              aria-hidden="true"
            />

            <span className="visually-hidden">
              {copy.refresh}
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
            {copy.loadingWeather}
          </p>
        </div>
      ) : fatalError && !weather ? (
        <div
          className={`${styles.status} ${styles.error}`}
          role="alert"
        >
          <p className={styles.statusText}>{fatalError}</p>
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
                  {formattedTemperature}

                  <span className={styles.degree}>
                    {temperatureUnit}
                  </span>
                </span>

                <p className={styles.condition}>
                  {conditionLabel}
                </p>

                <p className={styles.feelsLike}>
                  {copy.feelsLike}{" "}
                  {formattedApparentTemperature}
                  {temperatureUnit}
                </p>
              </div>
            </div>

            <div className={styles.metrics}>
              <div className={styles.metric}>
                <span className={styles.metricLabel}>
                  {copy.humidity}
                </span>

                <span className={styles.metricValue}>
                  <Droplets
                    size={15}
                    aria-hidden="true"
                  />{" "}
                  {formattedHumidity}
                  %
                </span>
              </div>

              <div className={styles.metric}>
                <span className={styles.metricLabel}>
                  {copy.wind}
                </span>

                <span className={styles.metricValue}>
                  <Wind
                    size={15}
                    aria-hidden="true"
                  />{" "}
                  {formattedWindSpeed} {windSpeedUnit}
                </span>
              </div>
            </div>
          </div>

          {hasWeatherError ? (
            <p
              className={styles.statusText}
              role="status"
              aria-live="polite"
            >
              {copy.showingLastReading}
            </p>
          ) : locationError ? (
            <p
              className={styles.statusText}
              role="status"
              aria-live="polite"
            >
              {locationError}
            </p>
          ) : null}

          <div className={styles.footer}>
            <span>
              {copy.observedAt} {formattedUpdatedAt}
            </span>

            <a
              className={styles.attribution}
              href="https://open-meteo.com/"
              target="_blank"
              rel="noopener noreferrer"
            >
              {copy.weatherDataBy}
            </a>
          </div>
        </>
      ) : null}
    </section>
  );
}
