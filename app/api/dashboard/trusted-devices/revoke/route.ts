import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import parseJsonOrEmpty from '@/utils/parse-request';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';
import { createServerClient } from '@supabase/ssr';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

// Using shared `verifyUserFromRequest` helper

// Using shared `verifyUserFromRequest` helper

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for trusted-devices revoke', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, id } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();
    // If an id is provided, delete that device for this user. Otherwise delete all.
    if (id) {
      const { error } = await admin.from('trusted_devices').delete().eq('id', id).eq('user_id', userId);
      if (error) {
        const msg = String(error.message || '').toLowerCase();
        if (msg.includes('relation') && msg.includes('does not exist')) {
          return NextResponse.json({ success: true, warning: 'trusted_devices table missing' });
        }
        console.error('trusted_devices delete error', error);
        return isoError(error.message);
      }
      return NextResponse.json({ success: true });
    }

    const { error: delErr } = await admin.from('trusted_devices').delete().eq('user_id', userId);
    if (delErr) {
      const msg = String(delErr.message || '').toLowerCase();
      if (msg.includes('relation') && msg.includes('does not exist')) {
        return NextResponse.json({ success: true, warning: 'trusted_devices table missing' });
      }
      console.error('trusted_devices bulk delete error', delErr);
      return isoError(delErr.message);
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error('trusted-devices revoke error', err);
    return isoError();
  }
}
