import { execFile } from "child_process";
import { parsePid } from "./kill-port.mjs";

export const PROTECTED_PIDS = new Set(["0", "4"]);

export const PROTECTED_NAMES = new Set([
  "System",
  "Registry",
  "smss.exe",
  "csrss.exe",
  "wininit.exe",
]);

export function parseTasklistCsvLine(line) {
  const trimmed = String(line || "").trim();
  if (!trimmed) return null;

  const match = trimmed.match(/^"([^"]+)","(\d+)"/);
  if (!match) return null;

  return {
    imageName: match[1],
    pid: match[2],
  };
}

export function getUnknownProcessLabel(reason = "unavailable") {
  if (reason === "exited") {
    return "unknown (process exited)";
  }

  if (reason === "access-denied") {
    return "unknown (access denied)";
  }

  return "unknown (details unavailable)";
}

export function getProtectedPidMessage(pid) {
  const normalized = parsePid(pid);
  if (!PROTECTED_PIDS.has(normalized)) return null;
  return `Refusing to kill protected system process PID ${normalized}.`;
}

export function getProcessInfo(pidInput) {
  const pid = parsePid(pidInput);

  return new Promise((resolve, reject) => {
    execFile(
      "tasklist",
      ["/FI", `PID eq ${pid}`, "/NH", "/FO", "CSV"],
      { windowsHide: true },
      (error, stdout, stderr) => {
        if (error) {
          reject(new Error(stderr || error.message));
          return;
        }

        const firstLine = String(stdout || "")
          .split(/\r?\n/)
          .map((line) => line.trim())
          .find(Boolean);

        const parsed = parseTasklistCsvLine(firstLine);

        if (!parsed) {
          const output = String(stdout || "");
          const reason = output.includes("No tasks are running") ? "exited" : "unavailable";

          resolve({
            pid,
            imageName: getUnknownProcessLabel(reason),
          });
          return;
        }

        resolve(parsed);
      }
    );
  });
}
