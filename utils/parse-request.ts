export async function parseJsonOrEmpty(req: unknown) {
  try {
    // Accept either a standard Request (with text()) or a test-friendly object with json()
    // Some tests provide a minimal object that implements `json()` but not `text()`.
    const anyReq = req as any;
    if (typeof anyReq?.text === 'function') {
      const text = await anyReq.text();
      if (!text) return {};
      return JSON.parse(text);
    }
    if (typeof anyReq?.json === 'function') {
      const j = await anyReq.json();
      return j ?? {};
    }
    return {};
  } catch (e) {
    const err = new Error('Invalid JSON');
    // attach original error for debugging
    // @ts-ignore
    err.cause = e;
    throw err;
  }
}

export default parseJsonOrEmpty;
