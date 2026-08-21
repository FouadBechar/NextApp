import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import { createServerClient } from '@supabase/ssr';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

// Using shared `verifyUserFromRequest` helper
export async function GET(req: NextRequest) {
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();
    const { data, error } = await admin.from('trusted_devices').select('id,name,user_agent,created_at,last_seen').eq('user_id', userId).order('created_at', { ascending: false });
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      if (msg.includes('relation') && msg.includes('does not exist') || msg.includes('table') && msg.includes('does not exist')) {
        // table missing — return empty list so UI degrades gracefully
        return NextResponse.json({ devices: [] });
      }
      console.error('trusted_devices select error', error);
      return isoError(error.message);
    }

    return NextResponse.json({ devices: data || [] });
  } catch (err) {
    console.error('trusted-devices GET error', err);
    return isoError();
  }
}
