import fs from "fs";
import path from "path";
import { execFileSync } from "child_process";

const DEFAULT_SECRET_PATTERNS = [
  { name: "API_KEY", regex: /^\s*[A-Z0-9_]*API[_-]?KEY\s*=/im },
  { name: "SECRET", regex: /^\s*[A-Z0-9_]*SECRET\s*=/im },
  { name: "TOKEN", regex: /^\s*[A-Z0-9_]*TOKEN\s*=/im },
  { name: "PASSWORD", regex: /^\s*[A-Z0-9_]*PASSWORD\s*=/im },
  { name: "PRIVATE_KEY", regex: /^\s*[A-Z0-9_]*PRIVATE[_-]?KEY\s*=/im },
];

function isGitTracked(projectRoot, relativePath) {
  try {
    const result = execFileSync("git", ["ls-files", "--cached", "--full-name", relativePath], {
      cwd: projectRoot,
      stdio: ["ignore", "pipe", "pipe"],
      encoding: "utf8",
    });

    return result.includes(relativePath);
  } catch (error) {
    const stderr = String(error?.stderr || "");
    if (
      stderr.includes("not a git repository") ||
      stderr.includes("fatal: not a git repository") ||
      stderr.includes("did not match any files")
    ) {
      return false;
    }

    return false;
  }
}

function detectSecrets(content) {
  const findings = [];

  for (const pattern of DEFAULT_SECRET_PATTERNS) {
    if (pattern.regex.test(content)) {
      findings.push(pattern.name);
    }
  }

  return findings;
}

export function scanEnv(projectRoot = process.cwd(), options = {}) {
  const gitTrackedChecker = options.gitTrackedChecker || isGitTracked;
  const envPath = path.join(projectRoot, ".env");
  const examplePath = path.join(projectRoot, ".env.example");

  const result = {
    projectRoot,
    hasEnv: fs.existsSync(envPath),
    envTracked: false,
    hasExample: fs.existsSync(examplePath),
    warnings: [],
    detectedSecrets: [],
  };

  if (result.hasEnv) {
    result.envTracked = gitTrackedChecker(projectRoot, ".env");

    if (result.envTracked) {
      result.warnings.push("The .env file is tracked by git.");
    }

    const content = fs.readFileSync(envPath, "utf8");
    result.detectedSecrets = detectSecrets(content);

    for (const finding of result.detectedSecrets) {
      result.warnings.push(`Potential secret variable detected: ${finding}`);
    }
  }

  if (!result.hasExample) {
    result.warnings.push("Missing .env.example.");
  }

  return result;
}
