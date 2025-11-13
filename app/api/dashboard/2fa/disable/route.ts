import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
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
    const body = await req.json();
    const { userId } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();

    // Read existing preferences (handle missing column gracefully)
    const { data: existing, error: fetchErr } = await admin.from('profiles').select('preferences').eq('id', userId).maybeSingle();
    if (fetchErr) {
      const msg = String(fetchErr.message || '').toLowerCase();
      if (msg.includes('column') && msg.includes('preferences') && msg.includes('does not exist')) {
        console.warn('Preferences column missing in profiles table; nothing to update');
        return NextResponse.json({ success: true, warning: 'preferences column missing; nothing to update' });
      }
      console.error('Profiles select error', fetchErr);
      return isoError(fetchErr.message);
    }

    const prefs = existing?.preferences || {};

    // Remove totp entry or mark disabled
    if (prefs && prefs.totp) {
      const merged = { ...prefs };
      // remove sensitive secret when disabling
      delete merged.totp;

      const { data: upd, error: updErr } = await admin.from('profiles').update({ preferences: merged }).eq('id', userId).select('preferences').maybeSingle();
      if (updErr) {
        const msg = String(updErr.message || '').toLowerCase();
        if (msg.includes('column') && msg.includes('preferences') && msg.includes('does not exist')) {
          console.warn('Preferences column missing on profiles table; cannot persist disable', updErr);
          return NextResponse.json({ success: true, warning: 'preferences column missing; not persisted' });
        }
        console.error('Failed to persist disable totp', updErr);
        return isoError(updErr.message);
      }
    }

    // Clear cookie and remove DB entries when possible
    try {
      const admin = createAdminClient();
      try {
        const { error: delErr } = await admin.from('trusted_devices').delete().eq('user_id', userId);
        if (delErr) {
          const msg = String(delErr.message || '').toLowerCase();
          if (msg.includes('relation') && msg.includes('does not exist')) {
            // table missing — ignore
          } else {
            console.error('Failed to delete trusted_devices on disable', delErr);
          }
        }
      } catch (e) {
        console.warn('Error deleting trusted_devices on disable', e);
      }

      const res = NextResponse.json({ success: true });
      // expire cookie
      res.cookies.set('trusted_device', '', { httpOnly: true, secure: process.env.NODE_ENV === 'production', sameSite: 'lax', path: '/', maxAge: 0 });
      return res;
    } catch (e) {
      return NextResponse.json({ success: true });
    }
  } catch (err) {
    console.error('2FA.disable error', err);
    return isoError();
  }
}
