import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {
  TARGETS,
  cleanProject,
  ensureSafeProjectRoot,
  findExistingTargets,
  looksLikeProjectRoot,
} from "../core/clean.mjs";

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

function makeTempProject() {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "dev-cleaner-"));
  fs.writeFileSync(path.join(tempRoot, "package.json"), '{"name":"temp-project"}');
  return tempRoot;
}

function createDir(root, name) {
  fs.mkdirSync(path.join(root, name), { recursive: true });
}

await runTest("detects a project root from package.json", async () => {
  const projectRoot = makeTempProject();
  assert.equal(looksLikeProjectRoot(projectRoot), true);
});

await runTest("rejects non-project directories by default", async () => {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "dev-cleaner-empty-"));
  assert.throws(() => ensureSafeProjectRoot(tempRoot), /does not look like a project root/);
});

await runTest("allows non-project directories with force", async () => {
  const tempRoot = fs.mkdtempSync(path.join(os.tmpdir(), "dev-cleaner-force-"));
  assert.equal(ensureSafeProjectRoot(tempRoot, { force: true }), path.resolve(tempRoot));
});

await runTest("finds only existing cleanup targets", async () => {
  const projectRoot = makeTempProject();
  createDir(projectRoot, "node_modules");
  createDir(projectRoot, ".next");

  assert.deepEqual(findExistingTargets(projectRoot), ["node_modules", ".next"]);
});

await runTest("dry run reports targets without deleting them", async () => {
  const projectRoot = makeTempProject();
  createDir(projectRoot, "node_modules");
  createDir(projectRoot, "coverage");

  const result = cleanProject({ dryRun: true, cwd: projectRoot });

  assert.deepEqual(result.removed, ["node_modules", "coverage"]);
  assert.equal(fs.existsSync(path.join(projectRoot, "node_modules")), true);
  assert.equal(fs.existsSync(path.join(projectRoot, "coverage")), true);
});

await runTest("clean removes targets from a project", async () => {
  const projectRoot = makeTempProject();
  createDir(projectRoot, "node_modules");
  createDir(projectRoot, "dist");

  const result = cleanProject({ cwd: projectRoot });

  assert.deepEqual(result.removed, ["node_modules", "dist"]);
  assert.equal(fs.existsSync(path.join(projectRoot, "node_modules")), false);
  assert.equal(fs.existsSync(path.join(projectRoot, "dist")), false);
});

await runTest("returns nothing to clean when no targets exist", async () => {
  const projectRoot = makeTempProject();
  const result = cleanProject({ dryRun: true, cwd: projectRoot });
  assert.deepEqual(result.removed, []);
});

await runTest("target list stays stable", async () => {
  assert.deepEqual(TARGETS, ["node_modules", "dist", "build", ".next", ".cache", "coverage"]);
});

if (process.exitCode) {
  process.exit(process.exitCode);
}
