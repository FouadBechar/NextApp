import assert from "node:assert/strict";
import { parsePid, formatKillPortError } from "../core/kill-port.mjs";
import {
  parsePort,
  parseNetstatOutput,
  parseListeningPorts,
  detectAddressFamily,
  pickPrimaryAddress,
  summarizeAddressFamilies,
} from "../core/scan-ports.mjs";
import {
  parseTasklistCsvLine,
  getProtectedPidMessage,
  getUnknownProcessLabel,
} from "../core/process-info.mjs";

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

await runTest("accepts valid ports", async () => {
  assert.equal(parsePort("3000"), 3000);
  assert.equal(parsePort("80"), 80);
});

await runTest("rejects invalid ports", async () => {
  assert.throws(() => parsePort("abc"), /numeric/);
  assert.throws(() => parsePort("0"), /between 1 and 65535/);
  assert.throws(() => parsePort("70000"), /between 1 and 65535/);
});

await runTest("parses matching netstat output", async () => {
  const output = [
    "  TCP    0.0.0.0:3000     0.0.0.0:0      LISTENING       12345",
    "  TCP    127.0.0.1:9229   0.0.0.0:0      LISTENING       54321",
  ].join("\n");

  const result = parseNetstatOutput(output, 3000);

  assert.deepEqual(result, {
    port: 3000,
    pid: "12345",
    protocol: "TCP",
    localAddress: "0.0.0.0:3000",
    state: "LISTENING",
    raw: "TCP    0.0.0.0:3000     0.0.0.0:0      LISTENING       12345",
  });
});

await runTest("returns null when no listening process matches the port", async () => {
  const output = "  TCP    0.0.0.0:9229     0.0.0.0:0      LISTENING       54321";
  assert.equal(parseNetstatOutput(output, 3000), null);
});

await runTest("parses and sorts all listening ports", async () => {
  const output = [
    "  TCP    [::]:3000        [::]:0         LISTENING       12345",
    "  TCP    127.0.0.1:9229   0.0.0.0:0      LISTENING       54321",
    "  TCP    0.0.0.0:3000     0.0.0.0:0      LISTENING       12345",
    "  TCP    0.0.0.0:3000     0.0.0.0:0      LISTENING       12345",
  ].join("\n");

  const result = parseListeningPorts(output);

  assert.deepEqual(result, [
    {
      port: 3000,
      pid: "12345",
      protocol: "TCP",
      localAddress: "0.0.0.0:3000",
      addresses: ["[::]:3000", "0.0.0.0:3000"],
      familySummary: "IPv4 + IPv6",
      state: "LISTENING",
      raw: "TCP    [::]:3000        [::]:0         LISTENING       12345",
    },
    {
      port: 9229,
      pid: "54321",
      protocol: "TCP",
      localAddress: "127.0.0.1:9229",
      addresses: ["127.0.0.1:9229"],
      familySummary: "IPv4",
      state: "LISTENING",
      raw: "TCP    127.0.0.1:9229   0.0.0.0:0      LISTENING       54321",
    },
  ]);
});

await runTest("detects address families", async () => {
  assert.equal(detectAddressFamily("0.0.0.0:3000"), "IPv4");
  assert.equal(detectAddressFamily("[::]:3000"), "IPv6");
});

await runTest("summarizes combined address families", async () => {
  assert.equal(summarizeAddressFamilies(["0.0.0.0:3000"]), "IPv4");
  assert.equal(summarizeAddressFamilies(["[::]:3000"]), "IPv6");
  assert.equal(summarizeAddressFamilies(["0.0.0.0:3000", "[::]:3000"]), "IPv4 + IPv6");
});

await runTest("prefers an IPv4 display address when available", async () => {
  assert.equal(pickPrimaryAddress(["[::]:3000", "0.0.0.0:3000"]), "0.0.0.0:3000");
  assert.equal(pickPrimaryAddress(["[::1]:3000"]), "[::1]:3000");
});

await runTest("accepts valid numeric pids", async () => {
  assert.equal(parsePid("12345"), "12345");
});

await runTest("rejects invalid pids", async () => {
  assert.throws(() => parsePid("abc"), /numeric/);
  assert.throws(() => parsePid("12 34"), /numeric/);
});

await runTest("parses tasklist csv output", async () => {
  const parsed = parseTasklistCsvLine("\"node.exe\",\"2316\",\"Console\",\"1\",\"82,000 K\"");
  assert.deepEqual(parsed, {
    imageName: "node.exe",
    pid: "2316",
  });
});

await runTest("protects sensitive system pids", async () => {
  assert.match(getProtectedPidMessage("4"), /protected system process/);
  assert.equal(getProtectedPidMessage("2316"), null);
});

await runTest("formats unknown process labels", async () => {
  assert.equal(getUnknownProcessLabel("exited"), "unknown (process exited)");
  assert.equal(getUnknownProcessLabel("access-denied"), "unknown (access denied)");
  assert.equal(getUnknownProcessLabel(), "unknown (details unavailable)");
});

await runTest("formats access denied taskkill errors", async () => {
  const message = formatKillPortError(
    "ERROR: The process with PID 1176 could not be terminated.\nReason: Access is denied.",
    "1176"
  );

  assert.match(message, /Administrator privileges required/);
});

await runTest("formats missing process taskkill errors", async () => {
  const message = formatKillPortError("ERROR: The process \"99999\" not found.", "99999");
  assert.match(message, /no longer running/);
});

if (process.exitCode) {
  process.exit(process.exitCode);
}
