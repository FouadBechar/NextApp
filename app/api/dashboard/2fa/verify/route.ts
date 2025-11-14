import { NextRequest, NextResponse } from 'next/server';
import { authenticator } from 'otplib';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';
import { createServerClient } from '@supabase/ssr';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

async function verifyUserFromRequest(req: NextRequest, expectedUserId?: string) {
  try {
    const serverSupabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return req.cookies.getAll();
          },
          setAll() {
            /* no-op */
          },
        },
      }
    );

    const {
      data: { user },
    } = await serverSupabase.auth.getUser();
    if (user && (!expectedUserId || user.id === expectedUserId)) {
      return { ok: true, user, via: 'cookie' };
    }
  } catch (e) {
    // ignore and fall back to token
  }

  const authHeader = req.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { ok: false, status: 401, reason: 'missing authorization' };
  }
  const token = authHeader.split(' ')[1];
  try {
    const admin = createAdminClient();
    const userRes = await (admin.auth as any).getUser(token);
    const fetchedUser = userRes?.data?.user;
    if (!fetchedUser) return { ok: false, status: 401, reason: 'invalid token' };
    if (expectedUserId && fetchedUser.id !== expectedUserId) return { ok: false, status: 403, reason: 'forbidden' };
    return { ok: true, user: fetchedUser, via: 'token' };
  } catch (e) {
    return { ok: false, status: 401, reason: 'invalid token' };
  }
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for 2fa verify', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, secret, token } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });
    if (!secret) return NextResponse.json({ error: 'missing secret' }, { status: 400 });
    if (!token) return NextResponse.json({ error: 'missing token' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    // Verify the provided TOTP token against the secret
    let ok = false;
    try {
      ok = authenticator.check(String(token), String(secret));
    } catch (e) {
      console.warn('TOTP verification error', e);
      ok = false;
    }

    if (!ok) return NextResponse.json({ error: 'invalid token' }, { status: 400 });

    // Persist the verified secret to the user's preferences JSONB (profiles.preferences)
    // NOTE: For production, consider encrypting the secret at rest or storing it in a separate
    // secure table/column. This implementation follows the project's existing preferences pattern.
    const admin = createAdminClient();

    // Read existing preferences (handle missing column gracefully like settings route)
    const { data: existing, error: fetchErr } = await admin.from('profiles').select('preferences').eq('id', userId).maybeSingle();
    if (fetchErr) {
      const msg = String(fetchErr.message || '').toLowerCase();
      if (msg.includes('column') && msg.includes('preferences') && msg.includes('does not exist')) {
        console.warn('Preferences column missing in profiles table; cannot persist totp settings');
        return NextResponse.json({ success: true, warning: 'preferences column missing; totp not persisted' });
      }
      console.error('Profiles select error', fetchErr);
      return isoError(fetchErr.message);
    }

    const prefs = existing?.preferences || {};
    const now = new Date().toISOString();
    const totp = {
      enabled: true,
      // store secret as-is for now; do not return it in responses
      secret: String(secret),
      createdAt: now,
    };

    const merged = { ...prefs, totp };

    const { data: upd, error: updErr } = await admin.from('profiles').update({ preferences: merged }).eq('id', userId).select('preferences').maybeSingle();
    if (updErr) {
      const msg = String(updErr.message || '').toLowerCase();
      if (msg.includes('column') && msg.includes('preferences') && msg.includes('does not exist')) {
        console.warn('Preferences column missing on profiles table; totp not persisted', updErr);
        return NextResponse.json({ success: true, warning: 'preferences column missing; totp not persisted' });
      }
      console.error('Failed to persist totp preferences', updErr);
      return isoError(updErr.message);
    }

    // Do not include the secret in the response payload
    // Also set a server-side trusted-device cookie so future visits from this browser
    // can be detected by the server. Cookie value includes userId for basic scoping.
    try {
      // Create a DB-backed trusted device token and set cookie with the raw token.
      const crypto = await import('crypto');
      const rawToken = crypto.randomBytes(32).toString('hex');
      const hash = crypto.createHash('sha256').update(rawToken).digest('hex');

      const admin = createAdminClient();
      try {
        const ua = (req.headers.get('user-agent') || '').slice(0, 1000);
        const nowIso = new Date().toISOString();
        const { error: insErr } = await admin.from('trusted_devices').insert([{ user_id: userId, token_hash: hash, user_agent: ua, created_at: nowIso, last_seen: nowIso }]);
        if (insErr) {
          const msg = String(insErr.message || '').toLowerCase();
          if (msg.includes('relation') && msg.includes('does not exist')) {
            console.warn('trusted_devices table missing; cannot persist trusted device', insErr);
            // fall back to cookie-only behavior
            const outRes = NextResponse.json({ success: true, totp: { enabled: true, createdAt: now } });
            outRes.cookies.set('trusted_device', rawToken, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 365 });
            return outRes;
          }
          console.error('Failed to insert trusted_devices', insErr);
        }
      } catch (e) {
        console.warn('Failed to persist trusted device', e);
      }

      const outRes = NextResponse.json({ success: true, totp: { enabled: true, createdAt: now } });
      outRes.cookies.set('trusted_device', rawToken, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 365 });
      return outRes;
    } catch (e) {
      console.warn('Failed to set trusted_device token', e);
      return NextResponse.json({ success: true, totp: { enabled: true, createdAt: now } });
    }
  } catch (err) {
    console.error('2FA.verify error', err);
    return isoError();
  }
}
