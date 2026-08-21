import assert from "node:assert/strict";
import fs from "fs";
import os from "os";
import path from "path";
import { execFileSync } from "child_process";
import { scanEnv } from "../core/scan-env.mjs";

function makeTempProject() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "env-guardian-test-"));
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

function initGitRepo(projectDir) {
  execFileSync("git", ["init"], { cwd: projectDir, stdio: "ignore" });
  execFileSync("git", ["config", "user.email", "test@example.com"], { cwd: projectDir, stdio: "ignore" });
  execFileSync("git", ["config", "user.name", "Test User"], { cwd: projectDir, stdio: "ignore" });
}

await runTest("reports missing env example when no files are present", async () => {
  const projectDir = makeTempProject();
  try {
    const result = scanEnv(projectDir, {
      gitTrackedChecker: () => false,
    });
    assert.equal(result.hasEnv, false);
    assert.equal(result.hasExample, false);
    assert.ok(result.warnings.includes("Missing .env.example."));
  } finally {
    fs.rmSync(projectDir, { recursive: true, force: true });
  }
});

await runTest("detects tracked env files and secret-like keys", async () => {
  const projectDir = makeTempProject();
  try {
    initGitRepo(projectDir);
    fs.writeFileSync(path.join(projectDir, ".env"), "API_KEY=abc\nTOKEN=def\n");
    fs.writeFileSync(path.join(projectDir, ".env.example"), "API_KEY=\nTOKEN=\n");
    execFileSync("git", ["add", "-f", ".env"], { cwd: projectDir, stdio: "ignore" });

    const result = scanEnv(projectDir, {
      gitTrackedChecker: () => true,
    });

    assert.equal(result.hasEnv, true);
    assert.equal(result.envTracked, true);
    assert.equal(result.hasExample, true);
    assert.deepEqual(result.detectedSecrets, ["API_KEY", "TOKEN"]);
    assert.ok(result.warnings.includes("The .env file is tracked by git."));
  } finally {
    fs.rmSync(projectDir, { recursive: true, force: true });
  }
});

await runTest("does not mark untracked env files as tracked", async () => {
  const projectDir = makeTempProject();
  try {
    initGitRepo(projectDir);
    fs.writeFileSync(path.join(projectDir, ".env"), "NORMAL_VALUE=hello\n");
    fs.writeFileSync(path.join(projectDir, ".env.example"), "NORMAL_VALUE=\n");

    const result = scanEnv(projectDir, {
      gitTrackedChecker: () => false,
    });

    assert.equal(result.hasEnv, true);
    assert.equal(result.envTracked, false);
    assert.equal(result.detectedSecrets.length, 0);
    assert.equal(result.warnings.length, 0);
  } finally {
    fs.rmSync(projectDir, { recursive: true, force: true });
  }
});

await runTest("accepts an explicit project path", async () => {
  const projectDir = makeTempProject();
  try {
    fs.writeFileSync(path.join(projectDir, ".env.example"), "API_KEY=\n");

    const result = scanEnv(path.resolve(projectDir), {
      gitTrackedChecker: () => false,
    });

    assert.equal(result.projectRoot, path.resolve(projectDir));
    assert.equal(result.hasExample, true);
  } finally {
    fs.rmSync(projectDir, { recursive: true, force: true });
  }
});

if (process.exitCode) {
  process.exit(process.exitCode);
}
