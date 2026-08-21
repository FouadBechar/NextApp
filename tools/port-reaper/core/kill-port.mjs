import { execFile } from "child_process";

export function parsePid(value) {
  const normalized = String(value || "").trim();

  if (!/^\d+$/.test(normalized)) {
    throw new Error("PID must be a numeric value.");
  }

  return normalized;
}

export function formatKillPortError(message, pid) {
  const normalized = String(message || "").trim();

  if (/Access is denied/i.test(normalized)) {
    return `Administrator privileges required or Windows denied access to PID ${pid}.`;
  }

  if (/not found|no running instance|does not exist/i.test(normalized)) {
    return `Process PID ${pid} is no longer running.`;
  }

  return normalized || `Failed to terminate PID ${pid}.`;
}

export function killPort(pidInput) {
  const pid = parsePid(pidInput);

  return new Promise((resolve, reject) => {
    execFile("taskkill", ["/F", "/PID", pid], { windowsHide: true }, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(formatKillPortError(stderr || error.message, pid)));
        return;
      }

      resolve({
        success: true,
        pid,
        output: stdout,
      });
    });
  });
}
