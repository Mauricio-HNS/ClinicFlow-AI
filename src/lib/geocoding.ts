import { z } from "zod";

const NominatimSchema = z.array(
  z.object({
    lat: z.string(),
    lon: z.string()
  })
);

export async function geocodeLocation(query: string) {
  if (!query) return null;

  const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(
    query
  )}`;

  const res = await fetch(url, {
    headers: {
      "User-Agent": "empleos-finder"
    }
  });

  if (!res.ok) return null;

  const data = NominatimSchema.parse(await res.json());
  if (!data.length) return null;

  return {
    lat: Number(data[0].lat),
    lng: Number(data[0].lon)
  };
}
