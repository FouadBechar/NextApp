#!/usr/bin/env node

import path from "node:path";
import { cleanProject, ensureSafeProjectRoot } from "../core/clean.mjs";

const args = process.argv.slice(2);

const showHelp = args.includes("--help") || args.includes("-h");
const dryRun = args.includes("--dry-run");
const force = args.includes("--force");

const pathFlagIndex = args.findIndex((arg) => arg === "--path");
const explicitPath = pathFlagIndex >= 0 ? args[pathFlagIndex + 1] : null;

if (pathFlagIndex >= 0 && (!explicitPath || explicitPath.startsWith("-"))) {
  console.error("Failed: --path requires a directory value.");
  process.exit(1);
}

if (showHelp) {
  console.log("dev-clean");
  console.log("Clean project dependencies, build output, and caches.\n");
  console.log("Usage:");
  console.log("  dev-clean");
  console.log("  dev-clean --dry-run");
  console.log('  dev-clean --path "C:\\my-project"');
  console.log("  dev-clean --force");
  console.log("  dev-clean --help");
  process.exit(0);
}

const targetPath = path.resolve(explicitPath || process.cwd());

try {
  ensureSafeProjectRoot(targetPath, { force });
  cleanProject({ dryRun, cwd: targetPath });
} catch (error) {
  console.error(`Failed: ${error.message}`);
  process.exit(1);
}
