import { pathToFileURL } from "url";
import path from "path";
import nextEnv from "@next/env";
import { generateSitemap } from "../tools/sitemap-cli/scripts/generate-sitemap.mjs";

const { loadEnvConfig } = nextEnv;

export { generateSitemap };

loadEnvConfig(process.cwd());

const entryUrl = process.argv[1]
  ? pathToFileURL(path.resolve(process.argv[1])).href
  : null;

if (entryUrl && import.meta.url === entryUrl) {
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL;

  if (!siteUrl) {
    console.log("Skipping sitemap generation: NEXT_PUBLIC_SITE_URL is not set.");
    process.exit(0);
  }

  generateSitemap({
    siteUrl,
    inputPath: "public/pages.json",
    outDir: "public",
  }).catch((err) => {
    console.error("Failed:", err?.message || err);
    process.exit(1);
  });
}
