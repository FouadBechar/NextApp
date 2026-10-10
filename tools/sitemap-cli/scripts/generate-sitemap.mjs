import fs from "fs";
import path from "path";
import nextEnv from "@next/env";
import { Readable } from "stream";
import { SitemapStream, streamToPromise } from "sitemap";
import { pathToFileURL } from "url";
import { createGzip } from "zlib";

const { loadEnvConfig } = nextEnv;
loadEnvConfig(process.cwd());

export async function generateSitemap({
  siteUrl,
  inputPath,
  outDir = "public",
  ignoreRoutes,
  defaults,
  rootEntry,
  silent = false,
}) {
  const SITE_URL = (siteUrl || "").replace(/\/+$/, "");

  const log = (...args) => !silent && console.log(...args);
  const error = (...args) => !silent && console.error(...args);
  const warnings = [];

  function warn(message) {
    warnings.push(message);
    if (!silent) console.warn(message);
  }

  if (!/^https?:\/\//i.test(SITE_URL)) {
    throw new Error("Invalid siteUrl");
  }

  const projectRoot = process.cwd();
  const pagesPath = path.join(projectRoot, inputPath || "public/pages.json");
  const outputDir = path.join(projectRoot, outDir || "public");
  const outXmlPath = path.join(outputDir, "sitemap.xml");
  const outGzipPath = path.join(outputDir, "sitemap.xml.gz");

  const IGNORE_ROUTES =
    Array.isArray(ignoreRoutes) && ignoreRoutes.length > 0
      ? ignoreRoutes
      : ["/auth", "/api", "/admin", "/_", "/dashboard"];

  function normalizeUrl(value) {
    if (!value) return null;
    let normalized = String(value).trim();

    try {
      if (/^https?:\/\//i.test(normalized)) {
        const urlObj = new URL(normalized);
        normalized = urlObj.pathname + (urlObj.search || "");
      }
    } catch {}

    if (!normalized.startsWith("/")) normalized = `/${normalized}`;
    return normalized.replace(/\/+$/, "") || "/";
  }

  function coercePriority(priority) {
    const parsed = parseFloat(priority);
    if (!Number.isFinite(parsed)) return 0.7;
    return Math.min(1, Math.max(0, parsed));
  }

  function coerceChangefreq(value) {
    const allowed = new Set([
      "always",
      "hourly",
      "daily",
      "weekly",
      "monthly",
      "yearly",
      "never",
    ]);
    const normalized = String(value).toLowerCase();
    return allowed.has(normalized) ? normalized : "weekly";
  }

  // function getValidLastmod(input) {
  //   if (!input) return undefined;
  //   const parsed = new Date(input);
  //   return Number.isNaN(parsed.getTime()) ? undefined : parsed.toISOString();
  // }

  function getValidLastmod(input) {
    if (!input) return undefined;
    const parsed = new Date(input);
    if (Number.isNaN(parsed.getTime())) return undefined;
    // This removes the decimal and milliseconds before the 'Z'
    return parsed.toISOString().replace(/\.\d{3}/, "");
  }

  const defaultChangefreq = coerceChangefreq(defaults?.changefreq);
  const defaultPriority = coercePriority(defaults?.priority);
  const rootEnabled = rootEntry?.enabled !== false;
  const rootChangefreq = coerceChangefreq(rootEntry?.changefreq ?? "weekly");
  const rootPriority = coercePriority(rootEntry?.priority ?? 1.0);
  const rootLastmod =
    rootEntry?.lastmod === "auto" || rootEntry?.lastmod === undefined
      ? new Date().toISOString()
      : (getValidLastmod(rootEntry.lastmod) ?? new Date().toISOString());

  let pages = [];

  try {
    if (fs.existsSync(pagesPath)) {
      const parsed = JSON.parse(fs.readFileSync(pagesPath, "utf8"));
      if (Array.isArray(parsed)) pages = parsed;
      else throw new Error("pages.json must contain a JSON array.");
    } else {
      warn(
        `Warning: ${inputPath || "public/pages.json"} was not found. Generating a minimal sitemap.`,
      );
    }
  } catch (err) {
    throw new Error(
      `Failed to read ${inputPath || "public/pages.json"}: ${err?.message || err}`,
    );
  }

  const smStream = new SitemapStream({ hostname: SITE_URL });
  const seen = new Set();

  if (rootEnabled) {
    seen.add(`${SITE_URL}/`);
    smStream.write({
      url: "/",
      changefreq: rootChangefreq,
      priority: rootPriority,
      lastmod: rootLastmod,
    });
  }

  for (const [index, page] of pages.entries()) {
    if (!page || typeof page !== "object" || Array.isArray(page)) {
      warn(
        `Warning: entry ${index} is not a valid page object and was skipped.`,
      );
      continue;
    }

    if (typeof page.url !== "string" || page.url.trim() === "") {
      warn(
        `Warning: entry ${index} is missing a valid string url and was skipped.`,
      );
      continue;
    }

    const normalized = normalizeUrl(page.url);
    if (!normalized) {
      warn(`Warning: entry ${index} has an invalid url and was skipped.`);
      continue;
    }

    if (IGNORE_ROUTES.some((route) => normalized.startsWith(route))) {
      warn(
        `Warning: ${normalized} was ignored because it matches a reserved route prefix.`,
      );
      continue;
    }

    const loc = SITE_URL + normalized;
    if (seen.has(loc)) {
      warn(`Warning: duplicate route ${normalized} was skipped.`);
      continue;
    }
    seen.add(loc);

    const lastmod = getValidLastmod(page.lastmod) ?? new Date().toISOString();
    if (page.lastmod && !getValidLastmod(page.lastmod)) {
      warn(
        `Warning: ${normalized} has an invalid lastmod value. Using the current timestamp instead.`,
      );
    }

    const changefreq =
      page.changefreq === undefined
        ? defaultChangefreq
        : coerceChangefreq(page.changefreq);
    if (
      page.changefreq !== undefined &&
      changefreq === "weekly" &&
      String(page.changefreq).toLowerCase() !== "weekly"
    ) {
      warn(
        `Warning: ${normalized} has an invalid changefreq value. Using "weekly" instead.`,
      );
    }

    const priority =
      page.priority === undefined
        ? defaultPriority
        : coercePriority(page.priority);
    if (page.priority !== undefined) {
      const parsedPriority = parseFloat(page.priority);
      if (
        !Number.isFinite(parsedPriority) ||
        parsedPriority < 0 ||
        parsedPriority > 1
      ) {
        warn(
          `Warning: ${normalized} has an invalid priority value. Clamping or defaulting to 0.7.`,
        );
      }
    }

    smStream.write({
      url: normalized,
      changefreq,
      priority,
      lastmod,
    });
  }

  smStream.end();

  const sitemapBuffer = await streamToPromise(smStream);

  fs.mkdirSync(path.dirname(outXmlPath), { recursive: true });
  fs.writeFileSync(outXmlPath, sitemapBuffer);
  log("Sitemap written");

  await new Promise((resolve, reject) => {
    Readable.from([sitemapBuffer])
      .pipe(createGzip())
      .pipe(fs.createWriteStream(outGzipPath))
      .on("finish", resolve)
      .on("error", reject);
  });

  log("Gzip done");

  return {
    xmlPath: outXmlPath,
    gzipPath: outGzipPath,
    urlCount: seen.size,
    warnings,
  };
}

const entryUrl = process.argv[1]
  ? pathToFileURL(path.resolve(process.argv[1])).href
  : null;

if (entryUrl && import.meta.url === entryUrl) {
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL;

  if (!siteUrl) {
    console.warn(
      "Skipping sitemap generation: NEXT_PUBLIC_SITE_URL is not set.",
    );
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
