// Reusable runtime-safe helpers for Google reCAPTCHA v3.
// Exports loadReCaptcha and executeRecaptcha for callers to use.

type Grecaptcha = {
  ready: (cb: () => void) => void;
  execute: (siteKey: string, opts?: { action: string }) => Promise<string> | string;
};

export async function loadReCaptcha(siteKey: string, timeout = 10000): Promise<void> {
  if (typeof window === "undefined") throw new Error("reCAPTCHA can only be loaded in the browser");

  // If grecaptcha already available and has execute, we're done
  const win = window as unknown as Window & { grecaptcha?: Grecaptcha };
  if (win.grecaptcha && typeof win.grecaptcha.execute === 'function') return;

  const existing = document.querySelector(`script[src^="https://www.google.com/recaptcha/api.js"]`);
  if (existing) {
    // Wait until grecaptcha is ready (poll until execute exists)
    await new Promise<void>((resolve, reject) => {
      const interval = setInterval(() => {
        if (win.grecaptcha && typeof win.grecaptcha.execute === 'function') {
          clearInterval(interval);
          resolve();
        }
      }, 50);
      setTimeout(() => {
        if (!(win.grecaptcha && typeof win.grecaptcha.execute === 'function')) {
          clearInterval(interval);
          reject(new Error("reCAPTCHA load timeout"));
        }
      }, timeout);
    });
    return;
  }

  await new Promise<void>((resolve, reject) => {
    const script = document.createElement("script");
    // mark the script so callers can remove it later if desired
    script.id = "recaptcha-v3";
    script.src = `https://www.google.com/recaptcha/api.js?render=${siteKey}`;
    script.async = true;
    script.defer = true;
    script.onload = () => {
        if (win.grecaptcha && typeof win.grecaptcha.ready === 'function') {
          win.grecaptcha.ready(() => resolve());
      } else {
        resolve();
      }
    };
    script.onerror = () => reject(new Error("Failed to load reCAPTCHA script"));
    document.head.appendChild(script);

    // Fallback timeout
    setTimeout(() => {
      if (!(win.grecaptcha && typeof win.grecaptcha.execute === 'function')) {
        reject(new Error("reCAPTCHA load timeout"));
      }
    }, timeout);
  });
}

/**
 * Executes reCAPTCHA v3 and returns the token.
 * This function guards runtime availability and surfaces clearer errors.
 */
export async function executeRecaptcha(siteKey: string, action = "submit", timeout = 10000): Promise<string> {
  if (!siteKey) throw new Error("reCAPTCHA site key is not configured");
  if (typeof window === "undefined") throw new Error("reCAPTCHA can only be executed in the browser");

  try {
    await loadReCaptcha(siteKey, timeout);
    const win = window as unknown as Window & { grecaptcha?: Grecaptcha };
    if (!(win.grecaptcha && win.grecaptcha.execute)) {
      throw new Error("reCAPTCHA not available after loading");
    }
    const token = await win.grecaptcha.execute(siteKey, { action });
    if (!token) throw new Error("reCAPTCHA returned empty token");
    return token as string;
  } catch (err: unknown) {
    // Normalize error messages for callers
    const message = err instanceof Error ? err.message : String(err);
    throw new Error(`reCAPTCHA execution failed: ${message}`);
  }
}

/**
 * Safe wrapper that returns a normalized result instead of throwing.
 * Useful for UI flows where you want to handle failure without try/catch.
 */
export async function executeRecaptchaSafe(siteKey: string, action = "submit", timeout = 10000): Promise<{ ok: true; token: string } | { ok: false; error: string }> {
  try {
    const token = await executeRecaptcha(siteKey, action, timeout);
    return { ok: true, token };
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return { ok: false, error: message };
  }
}
