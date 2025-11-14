export async function parseJsonOrEmpty(req: Request) {
  try {
    const text = await req.text();
    if (!text) return {};
    return JSON.parse(text);
  } catch (e) {
    const err = new Error('Invalid JSON');
    // attach original error for debugging
    // @ts-ignore
    err.cause = e;
    throw err;
  }
}

export default parseJsonOrEmpty;
