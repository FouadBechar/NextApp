import { NextResponse, type NextRequest } from 'next/server';
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
    // ignore
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

export async function GET(req: NextRequest) {
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const supabase = createAdminClient();
    const { data, error } = await supabase.from('profiles').select('preferences').eq('id', userId).maybeSingle();
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      if (msg.includes('column') && msg.includes('preferences') && msg.includes('does not exist')) {
        // DB doesn't have preferences column yet — return null so client falls back to defaults.
        console.warn('Preferences column missing in profiles table; returning null preferences');
        return NextResponse.json({ preferences: null });
      }

      console.error('Settings query error', error);
      return isoError(error.message);
    }

    return NextResponse.json({ preferences: data?.preferences || null });
  } catch (err) {
    console.error('Settings.GET error', err);
    return isoError();
  }
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for settings POST', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, preferences } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    if (typeof preferences !== 'object' || preferences === null) {
      return NextResponse.json({ error: 'invalid preferences' }, { status: 400 });
    }

    const supabase = createAdminClient();
    const { data, error } = await supabase.from('profiles').update({ preferences }).eq('id', userId).select('preferences').maybeSingle();
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      if (msg.includes('column') && msg.includes('preferences') && msg.includes('does not exist')) {
        // Preferences column isn't present yet. Return the posted preferences to the client
        // so the UI can continue to operate; log a warning so maintainers can run a migration.
        console.warn('Preferences column missing on profiles table; preferences not persisted', error);
        return NextResponse.json({ preferences, warning: 'preferences column missing; changes not persisted to DB' });
      }

      console.error('Settings update error', error);
      return isoError(error.message);
    }
    return NextResponse.json({ preferences: data?.preferences || null });
  } catch (err) {
    console.error('Settings.POST error', err);
    return isoError();
  }
}
