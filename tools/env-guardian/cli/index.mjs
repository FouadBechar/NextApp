#!/usr/bin/env node

import chalk from "chalk";
import { createRequire } from "module";
import path from "path";
import { scanEnv } from "../core/scan-env.mjs";

const require = createRequire(import.meta.url);
const { version } = require("../package.json");
const args = process.argv.slice(2);
const pathArg = args.find((arg) => arg.startsWith("--path="));
const targetPath = pathArg ? path.resolve(pathArg.split("=")[1]) : process.cwd();

if (args.includes("--help") || args.includes("-h")) {
  console.log(chalk.bold("env-guardian"));
  console.log("Scan a project for unsafe .env practices.\n");
  console.log(chalk.gray("Usage:"));
  console.log("  env-guardian");
  console.log("  env-guardian --path=./my-project");
  console.log("  env-guardian --version");
  process.exit(0);
}

if (args.includes("--version") || args.includes("-v")) {
  console.log(version);
  process.exit(0);
}

try {
  const result = scanEnv(targetPath);

  console.log(chalk.cyan("\nEnv Guardian Report\n"));
  console.log(`Project: ${result.projectRoot}`);
  console.log(`- .env exists: ${result.hasEnv ? "yes" : "no"}`);
  console.log(`- .env tracked by git: ${result.envTracked ? "yes" : "no"}`);
  console.log(`- .env.example exists: ${result.hasExample ? "yes" : "no"}`);

  if (result.detectedSecrets.length > 0) {
    console.log(`- secret-like keys found: ${result.detectedSecrets.join(", ")}`);
  }

  if (result.warnings.length > 0) {
    console.log(chalk.yellow("\nWarnings:"));
    for (const warning of result.warnings) {
      console.log(chalk.yellow(`- ${warning}`));
    }
    process.exitCode = 1;
  } else {
    console.log(chalk.green("\nNo issues found"));
  }
} catch (err) {
  console.error(chalk.red(err?.message || String(err)));
  process.exit(1);
}
