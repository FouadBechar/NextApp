import { NextResponse } from 'next/server';

// Simple in-memory rate limiter. This is best-effort and will reset when the
// server restarts. For production, replace with a shared store (Redis).

type Entry = { count: number; windowStart: number };

const emailAttempts = new Map<string, Entry>();
const ipAttempts = new Map<string, Entry>();

const EMAIL_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const EMAIL_MAX = 5; // max attempts per email in window

const IP_WINDOW_MS = 60 * 60 * 1000; // 1 hour
const IP_MAX = 200; // max attempts per IP in window

function now() {
  return Date.now();
}

function incrMap(map: Map<string, Entry>, key: string, windowMs: number) {
  const n = now();
  const existing = map.get(key);
  if (!existing || existing.windowStart + windowMs <= n) {
    map.set(key, { count: 1, windowStart: n });
    return { count: 1, windowStart: n } as Entry;
  }
  existing.count += 1;
  map.set(key, existing);
  return existing;
}

function getRemaining(map: Map<string, Entry>, key: string, max: number, windowMs: number) {
  const e = map.get(key);
  if (!e) return { remaining: max, retryAfter: 0 };
  const elapsed = now() - e.windowStart;
  if (elapsed >= windowMs) return { remaining: max, retryAfter: 0 };
  return { remaining: Math.max(0, max - e.count), retryAfter: Math.ceil((windowMs - elapsed) / 1000) };
}

export async function POST(req: Request) {
  try {
    const origin = new URL(req.url).origin;
    const body = await req.json().catch(() => ({}));
    const email = typeof body?.email === 'string' ? body.email.toLowerCase().trim() : null;

    // Determine client IP from headers (x-forwarded-for) fallback to unknown
    const xff = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip') || '';
    const ip = xff.split(',')[0].trim() || 'unknown';

    // Increment IP counter
    const ipEntry = incrMap(ipAttempts, ip, IP_WINDOW_MS);
    if (ipEntry.count > IP_MAX) {
      const retry = getRemaining(ipAttempts, ip, IP_MAX, IP_WINDOW_MS).retryAfter;
      return NextResponse.json({ error: 'Too many requests from this IP', retryAfter: retry }, { status: 429, headers: { 'Retry-After': String(retry) } });
    }

    // If email present, increment email counter
    if (email) {
      const emailEntry = incrMap(emailAttempts, email, EMAIL_WINDOW_MS);
      if (emailEntry.count > EMAIL_MAX) {
        const retry = getRemaining(emailAttempts, email, EMAIL_MAX, EMAIL_WINDOW_MS).retryAfter;
        return NextResponse.json({ error: 'Too many login attempts for this account', retryAfter: retry }, { status: 429, headers: { 'Retry-After': String(retry) } });
      }
    }

    const ipRemaining = getRemaining(ipAttempts, ip, IP_MAX, IP_WINDOW_MS);
    const emailRemaining = email ? getRemaining(emailAttempts, email, EMAIL_MAX, EMAIL_WINDOW_MS) : { remaining: EMAIL_MAX, retryAfter: 0 };

    return NextResponse.json({ ok: true, remaining: { ip: ipRemaining.remaining, email: emailRemaining.remaining } });
  } catch (err) {
    console.error('login-attempt error', err);
    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
