/**
 * Extract a string message from a JSON-like payload. Returns `null` if no
 * string message is found.
 */
export function extractMessageFromObject(obj: unknown): string | null {
  if (!obj || typeof obj !== 'object') return null;
  // Common shapes: { message: string } { error: string } { error: { message: string } }
  const record = obj as Record<string, unknown>;
  const candidates: Array<unknown> = [record.message, record.error, record.err, record.reason];
  for (const c of candidates) {
    if (typeof c === 'string') return c;
    if (typeof c === 'object' && c !== null && 'message' in (c as Record<string, unknown>)) {
      const m = (c as Record<string, unknown>).message;
      if (typeof m === 'string') return m;
    }
  }
  return null;
}

export default extractMessageFromObject;
