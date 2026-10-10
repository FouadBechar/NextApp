import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import { createServerClient } from '@supabase/ssr';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

// Using shared `verifyUserFromRequest` helper

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for 2fa disable', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
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
