export function getUserIdFromToken(token: string | null | undefined): string | null {
  if (!token || typeof token !== 'string') return null;
  const parts = token.split('.');
  if (parts.length < 2) return null;
  try {
    const payloadRaw = parts[1];
    // Buffer in Node and atob in browser. Node provides atob? Not necessarily. We'll use Buffer for server-side usage.
    // For safety, handle both environments.
    let decoded = '';
    try {
      decoded = Buffer.from(payloadRaw, 'base64').toString('utf8');
    } catch (e) {
      try {
        // fallback for browser (unlikely in APIs)
        decoded = atob(payloadRaw);
      } catch (err) {
        return null;
      }
    }
    const obj = JSON.parse(decoded);
    if (!obj) return null;
    return obj.sub || obj?.user_id || null;
  } catch (e) {
    return null;
  }
}
