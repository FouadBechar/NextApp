import { execFile } from "child_process";

export function parsePort(value) {
  const normalized = String(value || "").trim();

  if (!/^\d+$/.test(normalized)) {
    throw new Error("Port must be a numeric value.");
  }

  const port = Number(normalized);

  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error("Port must be between 1 and 65535.");
  }

  return port;
}

export function parseNetstatOutput(stdout, port) {
  const lines = String(stdout || "").split(/\r?\n/);

  for (const line of lines) {
    const clean = line.trim();
    if (!clean || !clean.includes("LISTENING")) continue;

    const parts = clean.split(/\s+/);
    if (parts.length < 5) continue;

    const protocol = parts[0];
    const localAddress = parts[1];
    const state = parts[3];
    const pid = parts[4];

    if (!/^\d+$/.test(pid)) continue;
    if (state !== "LISTENING") continue;
    if (!localAddress.endsWith(`:${port}`)) continue;

    return {
      port,
      pid,
      protocol,
      localAddress,
      state,
      raw: clean,
    };
  }

  return null;
}

export function detectAddressFamily(localAddress) {
  const normalized = String(localAddress || "").trim();

  if (normalized.includes("[::")) {
    return "IPv6";
  }

  return "IPv4";
}

export function summarizeAddressFamilies(addresses) {
  const families = new Set(addresses.map((address) => detectAddressFamily(address)));
  const orderedFamilies = ["IPv4", "IPv6"].filter((family) => families.has(family));

  return orderedFamilies.join(" + ");
}

export function pickPrimaryAddress(addresses) {
  const uniqueAddresses = Array.from(new Set(addresses));
  const ipv4Address = uniqueAddresses.find((address) => detectAddressFamily(address) === "IPv4");

  return ipv4Address || uniqueAddresses[0] || "";
}

export function parseListeningPorts(stdout) {
  const lines = String(stdout || "").split(/\r?\n/);
  const results = new Map();

  for (const line of lines) {
    const clean = line.trim();
    if (!clean || !clean.includes("LISTENING")) continue;

    const parts = clean.split(/\s+/);
    if (parts.length < 5) continue;

    const protocol = parts[0];
    const localAddress = parts[1];
    const state = parts[3];
    const pid = parts[4];

    if (state !== "LISTENING") continue;
    if (!/^\d+$/.test(pid)) continue;

    const portText = localAddress.split(":").at(-1);
    if (!/^\d+$/.test(portText || "")) continue;

    const port = Number(portText);
    const key = `${protocol}:${port}:${pid}`;
    const existing = results.get(key);

    if (existing) {
      existing.addresses = Array.from(new Set([...existing.addresses, localAddress]));
      existing.localAddress = pickPrimaryAddress(existing.addresses);
      existing.familySummary = summarizeAddressFamilies(existing.addresses);
      continue;
    }

    results.set(key, {
      port,
      pid,
      protocol,
      localAddress: pickPrimaryAddress([localAddress]),
      addresses: [localAddress],
      familySummary: summarizeAddressFamilies([localAddress]),
      state,
      raw: clean,
    });
  }

  return Array.from(results.values()).sort(
    (a, b) => a.port - b.port || Number(a.pid) - Number(b.pid)
  );
}

export function listPorts() {
  return new Promise((resolve, reject) => {
    execFile("netstat", ["-ano"], { windowsHide: true }, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(stderr || error.message));
        return;
      }

      resolve(parseListeningPorts(stdout));
    });
  });
}

export function scanPort(portInput) {
  const port = parsePort(portInput);

  return new Promise((resolve, reject) => {
    execFile("netstat", ["-ano"], { windowsHide: true }, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(stderr || error.message));
        return;
      }

      resolve(parseNetstatOutput(stdout, port));
    });
  });
}
