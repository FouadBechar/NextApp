import fs from "node:fs";
import path from "node:path";
import chalk from "chalk";

export const TARGETS = ["node_modules", "dist", "build", ".next", ".cache", "coverage"];
export const PROJECT_HINTS = [
  "package.json",
  ".git",
  "pnpm-lock.yaml",
  "package-lock.json",
  "yarn.lock",
  "tsconfig.json",
  "next.config.js",
  "next.config.ts",
  "vite.config.js",
  "vite.config.ts",
];

export function normalizeTargetPath(cwd) {
  return path.resolve(cwd);
}

export function looksLikeProjectRoot(cwd) {
  return PROJECT_HINTS.some((hint) => fs.existsSync(path.join(cwd, hint)));
}

export function ensureSafeProjectRoot(cwd, { force = false } = {}) {
  const targetPath = normalizeTargetPath(cwd);

  if (force) {
    return targetPath;
  }

  if (!looksLikeProjectRoot(targetPath)) {
    throw new Error(
      `Refusing to clean ${targetPath} because it does not look like a project root. Use --force to override.`
    );
  }

  return targetPath;
}

export function findExistingTargets(cwd) {
  const targetPath = normalizeTargetPath(cwd);

  return TARGETS.filter((target) => fs.existsSync(path.join(targetPath, target)));
}

export function removeTargets(cwd, targets) {
  const targetPath = normalizeTargetPath(cwd);

  for (const target of targets) {
    const fullPath = path.join(targetPath, target);
    fs.rmSync(fullPath, { recursive: true, force: true });
  }
}

export function cleanProject({ dryRun = false, cwd = process.cwd() } = {}) {
  const targetPath = normalizeTargetPath(cwd);
  const existingTargets = findExistingTargets(targetPath);

  console.log(chalk.cyan("\nDev Cleaner\n"));
  console.log(chalk.gray(`Target: ${targetPath}`));

  if (existingTargets.length === 0) {
    console.log(chalk.gray("Nothing to clean."));
    return { cwd: targetPath, removed: [], dryRun };
  }

  for (const target of existingTargets) {
    if (dryRun) {
      console.log(chalk.yellow(`Would remove: ${target}`));
    } else {
      console.log(chalk.green(`Removed: ${target}`));
    }
  }

  if (!dryRun) {
    removeTargets(targetPath, existingTargets);
    console.log(chalk.green("\nProject cleaned successfully\n"));
  }

  return {
    cwd: targetPath,
    removed: existingTargets,
    dryRun,
  };
}
