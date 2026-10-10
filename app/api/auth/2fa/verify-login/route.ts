import { NextRequest, NextResponse } from 'next/server';
import { authenticator } from 'otplib';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for auth 2fa verify-login', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, token } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });
    if (!token) return NextResponse.json({ error: 'missing token' }, { status: 400 });

    const admin = createAdminClient();
    // read totp secret from profiles.preferences
    const { data: profile, error: pErr } = await admin.from('profiles').select('preferences').eq('id', userId).maybeSingle();
    if (pErr) {
      console.error('Profiles select error', pErr);
      return isoError(pErr.message);
    }

    const prefs = profile?.preferences || {};
    const totp = prefs?.totp;
    if (!totp || !totp.secret) return NextResponse.json({ error: 'totp not configured' }, { status: 400 });

    let ok = false;
    try {
      ok = authenticator.check(String(token), String(totp.secret));
    } catch (e) {
      console.warn('TOTP check error', e);
      ok = false;
    }

    if (!ok) return NextResponse.json({ error: 'invalid token' }, { status: 400 });

    // create trusted device token and set cookie + persist hash
    try {
      const crypto = await import('crypto');
      const rawToken = crypto.randomBytes(32).toString('hex');
      const hash = crypto.createHash('sha256').update(rawToken).digest('hex');
      const ua = (req.headers.get('user-agent') || '').slice(0, 1000);
      const nowIso = new Date().toISOString();
      const { error: insErr } = await admin.from('trusted_devices').insert([{ user_id: userId, token_hash: hash, user_agent: ua, created_at: nowIso, last_seen: nowIso }]);
      if (insErr) {
        const msg = String(insErr.message || '').toLowerCase();
        if (msg.includes('relation') && msg.includes('does not exist')) {
          // table missing — still set cookie
          const out = NextResponse.json({ success: true, warning: 'trusted_devices table missing; cookie set only' });
          out.cookies.set('trusted_device', rawToken, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 365 });
          return out;
        }
        console.error('trusted_devices insert error', insErr);
      }

      const out = NextResponse.json({ success: true });
      out.cookies.set('trusted_device', rawToken, { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', path: '/', maxAge: 60 * 60 * 24 * 365 });
      return out;
    } catch (e) {
      console.warn('Failed to create trusted device', e);
      return NextResponse.json({ success: true });
    }
  } catch (err) {
    console.error('verify-login 2FA error', err);
    return isoError();
  }
}
