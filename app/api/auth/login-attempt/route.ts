import { NextResponse } from 'next/server';
import { getAttemptState, recordAttempt } from '@/lib/redis-rate-limit';

const EMAIL_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const EMAIL_MAX = 5; // max attempts per email in window

const IP_WINDOW_MS = 60 * 60 * 1000; // 1 hour
const IP_MAX = 200; // max attempts per IP in window

export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const email = typeof body?.email === 'string' ? body.email.toLowerCase().trim() : null;
    const phase = body?.phase === 'failed' ? 'failed' : 'preflight';

    if (phase === 'failed') {
      if (!email) return NextResponse.json({ error: 'Email is required' }, { status: 400 });

      const emailResult = await recordAttempt('email', email, EMAIL_MAX, EMAIL_WINDOW_MS);
      if (emailResult.count > EMAIL_MAX) {
        return NextResponse.json(
          { error: 'Too many login attempts for this account', retryAfter: emailResult.retryAfter },
          { status: 429, headers: { 'Retry-After': String(emailResult.retryAfter) } },
        );
      }

      return NextResponse.json({ ok: true, remaining: { email: emailResult.remaining } });
    }

    const xff = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip') || '';
    const ip = xff.split(',')[0].trim() || 'unknown';

    const ipResult = await recordAttempt('ip', ip, IP_MAX, IP_WINDOW_MS);
    if (ipResult.count > IP_MAX) {
      return NextResponse.json(
        { error: 'Too many requests from this IP', retryAfter: ipResult.retryAfter },
        { status: 429, headers: { 'Retry-After': String(ipResult.retryAfter) } },
      );
    }

    const emailResult = email
      ? await getAttemptState('email', email, EMAIL_MAX, EMAIL_WINDOW_MS)
      : { count: 0, remaining: EMAIL_MAX, retryAfter: 0 };
    if (emailResult.count >= EMAIL_MAX) {
      return NextResponse.json(
        { error: 'Too many login attempts for this account', retryAfter: emailResult.retryAfter },
        { status: 429, headers: { 'Retry-After': String(emailResult.retryAfter) } },
      );
    }

    return NextResponse.json({ ok: true, remaining: { ip: ipResult.remaining, email: emailResult.remaining } });
  } catch (err) {
    console.error('login-attempt error', err);
    return NextResponse.json({ error: 'Internal error' }, { status: 500 });
  }
}
