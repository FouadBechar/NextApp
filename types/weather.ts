export interface WeatherData {
  latitude: number;
  longitude: number;
  timezone: string;
  updatedAt: string;
  temperature: number;
  apparentTemperature: number;
  relativeHumidity: number;
  windSpeed: number;
  weatherCode: number;
  isDay: boolean;
}

export interface WeatherApiResponse extends WeatherData {}

export interface WeatherWidgetProps {
  city?: string;
  latitude?: number;
  longitude?: number;
  locale?: string;
  enableGeolocation?: boolean;
}
