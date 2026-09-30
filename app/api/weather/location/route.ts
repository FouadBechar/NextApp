import { NextResponse } from "next/server";
import { normalizeCoordinates } from "@/lib/weather";

const REVERSE_GEOCODING_URL =
  "https://api.bigdatacloud.net/data/reverse-geocode-client";

function getLanguage(locale: string | null): string {
  const language = locale?.split("-")[0]?.toLowerCase() ?? "en";
  return /^[a-z]{2,3}$/.test(language) ? language : "en";
}

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const latitude = Number(searchParams.get("lat"));
  const longitude = Number(searchParams.get("lon"));

  try {
    const coordinates = normalizeCoordinates(latitude, longitude);
    const params = new URLSearchParams({
      latitude: String(coordinates.latitude),
      longitude: String(coordinates.longitude),
      localityLanguage: getLanguage(searchParams.get("locale")),
    });
    const response = await fetch(`${REVERSE_GEOCODING_URL}?${params}`, {
      headers: { Accept: "application/json" },
      next: { revalidate: 86_400 },
    });

    if (!response.ok) {
      throw new Error(`Reverse geocoding provider returned ${response.status}.`);
    }

    const data = (await response.json()) as {
      city?: string;
      locality?: string;
      localityName?: string;
      principalSubdivision?: string;
      countryName?: string;
    };
    const name =
      data.principalSubdivision ??
      data.city ??
      data.locality ??
      data.localityName ??
      data.countryName ??
      null;

    return NextResponse.json(
      { name },
      { headers: { "Cache-Control": "private, max-age=86400" } },
    );
  } catch (error) {
    console.error("Weather location API error:", error);
    const isInvalidCoordinate =
      error instanceof Error && error.message.startsWith("Invalid ");

    return NextResponse.json(
      { error: isInvalidCoordinate ? error.message : "Unable to identify location." },
      { status: isInvalidCoordinate ? 400 : 502 },
    );
  }
}
