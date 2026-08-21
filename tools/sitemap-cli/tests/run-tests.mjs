import assert from "node:assert/strict";
import fs from "fs";
import os from "os";
import path from "path";
import { generateSitemap } from "../scripts/generate-sitemap.mjs";

function makeTempProject() {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "sitemap-cli-test-"));
  fs.mkdirSync(path.join(tempDir, "public"), { recursive: true });
  return tempDir;
}

async function runTest(name, fn) {
  try {
    await fn();
    console.log(`PASS ${name}`);
  } catch (error) {
    console.error(`FAIL ${name}`);
    console.error(error);
    process.exitCode = 1;
  }
}

async function withTempProject(fn) {
  const originalCwd = process.cwd();
  const projectDir = makeTempProject();

  try {
    process.chdir(projectDir);
    await fn(projectDir);
  } finally {
    process.chdir(originalCwd);
    fs.rmSync(projectDir, { recursive: true, force: true });
  }
}

await runTest("falls back to a minimal sitemap when pages.json is missing", async () => {
  await withTempProject(async (projectDir) => {
    const result = await generateSitemap({
      siteUrl: "https://example.com",
      inputPath: "public/pages.json",
      outDir: "public",
      silent: true,
    });

    const xml = fs.readFileSync(path.join(projectDir, "public", "sitemap.xml"), "utf8");

    assert.equal(result.urlCount, 1);
    assert.match(xml, /https:\/\/example\.com\//);
    assert.ok(result.warnings.some((warning) => warning.includes("Generating a minimal sitemap")));
  });
});

await runTest("fails when pages.json is malformed or not an array", async () => {
  await withTempProject(async (projectDir) => {
    fs.writeFileSync(path.join(projectDir, "public", "pages.json"), '{"url":"/not-an-array"}');

    await assert.rejects(
      () =>
        generateSitemap({
          siteUrl: "https://example.com",
          inputPath: "public/pages.json",
          outDir: "public",
          silent: true,
        }),
      /must contain a JSON array/
    );
  });
});

await runTest("normalizes routes, skips ignored routes, and deduplicates entries", async () => {
  await withTempProject(async (projectDir) => {
    fs.writeFileSync(
      path.join(projectDir, "public", "pages.json"),
      JSON.stringify([
        { url: "privacy/" },
        { url: "https://example.com/privacy/" },
        { url: "/dashboard" },
        { url: "/about?ref=home" },
      ]),
    );

    const result = await generateSitemap({
      siteUrl: "https://example.com",
      inputPath: "public/pages.json",
      outDir: "public",
      silent: true,
    });

    const xml = fs.readFileSync(path.join(projectDir, "public", "sitemap.xml"), "utf8");

    assert.equal(result.urlCount, 3);
    assert.match(xml, /https:\/\/example\.com\/privacy/);
    assert.match(xml, /https:\/\/example\.com\/about\?ref=home/);
    assert.doesNotMatch(xml, /https:\/\/example\.com\/dashboard/);
    assert.ok(result.warnings.some((warning) => warning.includes("duplicate route /privacy")));
    assert.ok(result.warnings.some((warning) => warning.includes("/dashboard was ignored")));
  });
});

await runTest("warns on invalid field values and skips invalid objects", async () => {
  await withTempProject(async (projectDir) => {
    fs.writeFileSync(
      path.join(projectDir, "public", "pages.json"),
      JSON.stringify([
        null,
        { url: "" },
        { url: "/valid", priority: 4, changefreq: "sometimes", lastmod: "not-a-date" },
      ]),
    );

    const result = await generateSitemap({
      siteUrl: "https://example.com",
      inputPath: "public/pages.json",
      outDir: "public",
      silent: true,
    });

    const xml = fs.readFileSync(path.join(projectDir, "public", "sitemap.xml"), "utf8");

    assert.equal(result.urlCount, 2);
    assert.match(xml, /https:\/\/example\.com\/valid/);
    assert.ok(result.warnings.some((warning) => warning.includes("entry 0 is not a valid page object")));
    assert.ok(result.warnings.some((warning) => warning.includes("entry 1 is missing a valid string url")));
    assert.ok(result.warnings.some((warning) => warning.includes("/valid has an invalid changefreq value")));
    assert.ok(result.warnings.some((warning) => warning.includes("/valid has an invalid priority value")));
    assert.ok(result.warnings.some((warning) => warning.includes("/valid has an invalid lastmod value")));
  });
});

await runTest("supports config-driven defaults and disabling the root entry", async () => {
  await withTempProject(async (projectDir) => {
    fs.writeFileSync(
      path.join(projectDir, "public", "pages.json"),
      JSON.stringify([
        { url: "/custom" },
        { url: "/private" },
      ]),
    );

    const result = await generateSitemap({
      siteUrl: "https://example.com",
      inputPath: "public/pages.json",
      outDir: "public",
      ignoreRoutes: ["/private"],
      defaults: {
        changefreq: "monthly",
        priority: 0.5,
      },
      rootEntry: {
        enabled: false,
      },
      silent: true,
    });

    const xml = fs.readFileSync(path.join(projectDir, "public", "sitemap.xml"), "utf8");

    assert.equal(result.urlCount, 1);
    assert.match(xml, /https:\/\/example\.com\/custom/);
    assert.match(xml, /<changefreq>monthly<\/changefreq>/);
    assert.match(xml, /<priority>0.5<\/priority>/);
    assert.doesNotMatch(xml, /https:\/\/example\.com\/<\/loc>/);
    assert.doesNotMatch(xml, /https:\/\/example\.com\/private/);
  });
});

if (process.exitCode) {
  process.exit(process.exitCode);
}
