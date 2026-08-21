#!/usr/bin/env node

import chalk from "chalk";
import { createRequire } from "module";
import { scanPort, parsePort, listPorts } from "../core/scan-ports.mjs";
import { killPort } from "../core/kill-port.mjs";
import { getProcessInfo, getProtectedPidMessage, PROTECTED_NAMES } from "../core/process-info.mjs";

const require = createRequire(import.meta.url);
const { version } = require("../package.json");

const args = process.argv.slice(2);

const force = args.includes("--force");
const dryRun = args.includes("--dry-run");
const listOnly = args.includes("--list");
const quickKill = args.includes("--kill");

function formatListAddress(entry) {
  if (entry.familySummary === "IPv4 + IPv6") {
    return "IPv4 + IPv6";
  }

  return entry.localAddress;
}

if (args.includes("--help") || args.includes("-h")) {
  console.log(chalk.bold("port-reaper"));
  console.log("Find and kill the process listening on a specific port (Windows).\n");
  console.log(chalk.gray("Usage:"));
  console.log("  port-reaper 3000");
  console.log("  port-reaper 3000 --dry-run");
  console.log("  port-reaper --kill 3000");
  console.log("  port-reaper 3000 --force");
  console.log("  port-reaper --list");
  console.log("  port-reaper --version");
  process.exit(0);
}

if (args.includes("--version") || args.includes("-v")) {
  console.log(version);
  process.exit(0);
}

const portArg = args.find((arg) => !arg.startsWith("-"));

if (listOnly) {
  try {
    const ports = await listPorts();

    if (ports.length === 0) {
      console.log(chalk.yellow("No listening ports found."));
      process.exit(0);
    }

    const enriched = await Promise.all(
      ports.map(async (entry) => {
        const processInfo = await getProcessInfo(entry.pid);
        return { ...entry, processInfo };
      })
    );

    console.log(chalk.cyan("Listening Ports\n"));

    for (const entry of enriched) {
      const color = entry.port < 1024 ? chalk.yellow : chalk.green;
      console.log(
        color(`[${entry.port}]`) +
          ` -> ${entry.processInfo.imageName} (PID: ${entry.pid}) | ${entry.protocol} | ${formatListAddress(entry)}`
      );
    }

    process.exit(0);
  } catch (error) {
    console.error(chalk.red(`Failed: ${error.message}`));
    process.exit(1);
  }
}

if (!portArg) {
  console.error(chalk.red("Please provide a port."));
  console.log(chalk.gray("Usage:"));
  console.log(chalk.cyan("  port-reaper 3000"));
  process.exit(1);
}

let port;

try {
  port = parsePort(portArg);
} catch (error) {
  console.error(chalk.red(error.message));
  process.exit(1);
}

try {
  const result = await scanPort(port);

  if (!result) {
    console.log(chalk.yellow(`No listening process found on port ${port}.`));
    process.exit(0);
  }

  const processInfo = await getProcessInfo(result.pid);
  const protectedMessage = getProtectedPidMessage(result.pid);

  if (!quickKill) {
    console.log(chalk.cyan("Port Reaper\n"));
    console.log(`-> Port: ${result.port}`);
    console.log(`-> Process: ${processInfo.imageName} (PID: ${result.pid})`);
    console.log(`-> Address: ${result.localAddress}`);
    console.log(`-> Protocol: ${result.protocol}`);
  }

  if ((protectedMessage || PROTECTED_NAMES.has(processInfo.imageName)) && !force) {
    throw new Error(
      (protectedMessage || `Protected process: ${processInfo.imageName}`) +
        " (use --force to override)"
    );
  }

  if (dryRun) {
    console.log(
      chalk.green(
        `\nWould kill ${processInfo.imageName} (PID: ${result.pid}) on port ${result.port}.`
      )
    );
    process.exit(0);
  }

  const res = await killPort(result.pid);

  if (quickKill) {
    console.log(
      chalk.green(`Killed ${processInfo.imageName} (PID: ${result.pid}) on port ${result.port}.`)
    );
  } else {
    console.log(chalk.green("\nTerminated successfully"));
  }
} catch (error) {
  console.error(chalk.red(`Failed: ${error.message}`));
  process.exit(1);
}
