import { Resend } from 'resend';

let _resend: Resend | null = null;

/**
 * Lazily instantiate and return a Resend client instance.
 * Returns null if no RESEND_API_KEY is configured.
 */
export function getResend(): Resend | null {
  if (_resend) return _resend;
  const key = process.env.RESEND_API_KEY;
  if (!key) return null;
  _resend = new Resend(key);
  return _resend;
}

/**
 * Helper to check whether a resend client exists (env var present).
 */
export function hasResend(): boolean {
  return Boolean(process.env.RESEND_API_KEY);
}

export default getResend;

/**
 * Safe wrapper around Resend's `emails.send`. Centralizes missing-key handling,
 * error handling and consistent return shape for callers.
 */
export async function sendEmail<T extends any = any>(params: Parameters<Resend['emails']['send']>[0]) {
  const client = getResend();
  if (!client) {
    return { ok: false as const, missingApiKey: true };
  }
  try {
    const data = await client.emails.send(params);
    return { ok: true as const, data };
  } catch (error) {
    return { ok: false as const, missingApiKey: false, error };
  }
}
