import { NextResponse } from "next/server";
import { getCurrentWeather } from "@/lib/weather";

const DEFAULT_LATITUDE = 36.7538;
const DEFAULT_LONGITUDE = 3.0588;
const MAX_AGE_SECONDS = 600;

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);

  const latitude = Number(searchParams.get("lat") ?? DEFAULT_LATITUDE);
  const longitude = Number(searchParams.get("lon") ?? DEFAULT_LONGITUDE);

  try {
    const weather = await getCurrentWeather(latitude, longitude);

    return NextResponse.json(weather, {
      headers: {
        "Cache-Control": `public, s-maxage=${MAX_AGE_SECONDS}, stale-while-revalidate=1800`,
      },
    });
  } catch (error) {
    console.error("Weather API error:", error);

    return NextResponse.json(
      { error: "Unable to load weather data right now." },
      { status: 502 },
    );
  }
}
