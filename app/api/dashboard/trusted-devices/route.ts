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
    if (user && (!expectedUserId || user.id === expectedUserId)) return { ok: true, user, via: 'cookie' };
  } catch (e) {
    // ignore
  }

  const authHeader = req.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) return { ok: false, status: 401, reason: 'missing authorization' };
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
