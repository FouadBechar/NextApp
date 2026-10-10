#!/usr/bin/env node

import chalk from "chalk";
import ora from "ora";
import { createRequire } from "module";
import fs from "fs";
import path from "path";
import { generateSitemap } from "../scripts/generate-sitemap.mjs";

const require = createRequire(import.meta.url);
const { version } = require("../package.json");
const args = process.argv.slice(2);

function getArg(name, fallback) {
  const arg = args.find((a) => a.startsWith(`--${name}=`));
  return arg ? arg.split("=")[1] : fallback;
}

function hasArg(name) {
  return args.some((arg) => arg === `--${name}` || arg.startsWith(`--${name}=`));
}

function readConfig(configPath) {
  if (!fs.existsSync(configPath)) {
    return { config: {}, loadedConfigPath: null };
  }

  const raw = fs.readFileSync(configPath, "utf8");
  const parsed = JSON.parse(raw);

  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new Error("sitemap.config.json must contain a JSON object.");
  }

  return { config: parsed, loadedConfigPath: configPath };
}

if (args.includes("--help") || args.includes("-h")) {
  console.log(chalk.bold("next-sitemap-gen"));
  console.log("Generate sitemap.xml and sitemap.xml.gz for a Next.js app.\n");
  console.log(chalk.gray("Usage:"));
  console.log("  next-sitemap-gen --site=https://example.com");
  console.log("  next-sitemap-gen --site=example.com --input=public/pages.json --out-dir=public");
  console.log("  next-sitemap-gen --config=./sitemap.config.json");
  process.exit(0);
}

if (args.includes("--version") || args.includes("-v")) {
  console.log(version);
  process.exit(0);
}

const configPath = path.resolve(process.cwd(), getArg("config", "sitemap.config.json"));

let config = {};
let loadedConfigPath = null;

try {
  ({ config, loadedConfigPath } = readConfig(configPath));
} catch (err) {
  console.error(chalk.red("Invalid config:"), err?.message || err);
  process.exit(1);
}

let siteUrl = hasArg("site") ? getArg("site") : config.site || process.env.NEXT_PUBLIC_SITE_URL;
const inputPath = hasArg("input") ? getArg("input") : config.input || "public/pages.json";
const outDir = hasArg("out-dir") ? getArg("out-dir") : config.outDir || "public";
const ignoreRoutes = Array.isArray(config.ignoreRoutes) ? config.ignoreRoutes : undefined;
const defaults = config.defaults && typeof config.defaults === "object" ? config.defaults : undefined;
const rootEntry = config.rootEntry && typeof config.rootEntry === "object" ? config.rootEntry : undefined;

// Normalize the site URL so the common "example.com" input still works.
if (siteUrl && !/^https?:\/\//i.test(siteUrl)) {
  siteUrl = `https://${siteUrl}`;
}

if (!siteUrl) {
  console.error(chalk.red("Missing --site argument or NEXT_PUBLIC_SITE_URL"));
  console.log(chalk.gray("\nUsage:"));
  console.log(chalk.cyan("  next-sitemap-gen --site=https://example.com"));
  process.exit(1);
}

const spinner = ora("Generating sitemap...").start();

try {
  const result = await generateSitemap({
    siteUrl,
    inputPath,
    outDir,
    ignoreRoutes,
    defaults,
    rootEntry,
    silent: true,
  });

  spinner.succeed("Sitemap generated successfully");
  console.log(chalk.green("XML:"), chalk.cyan(result.xmlPath));
  console.log(chalk.green("Gzip:"), chalk.cyan(result.gzipPath));
  console.log(chalk.green("URLs:"), chalk.cyan(String(result.urlCount)));
  if (loadedConfigPath) {
    console.log(chalk.green("Config:"), chalk.cyan(loadedConfigPath));
  }
  if (result.warnings.length > 0) {
    console.log(chalk.yellow("Warnings:"), chalk.yellow(String(result.warnings.length)));
    for (const warning of result.warnings) {
      console.log(chalk.yellow(`- ${warning}`));
    }
  }
} catch (err) {
  spinner.fail("Generation failed");
  console.error(chalk.red("Error:"), err?.message || err);
  process.exit(1);
}
