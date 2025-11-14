import { NextResponse, type NextRequest } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';
import { createServerClient } from '@supabase/ssr';

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

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');

    const supabase = createAdminClient();

    let query = supabase.from('activities').select('id,title,description,created_at').order('created_at', { ascending: false }).limit(50);
    if (userId) query = query.eq('user_id', userId as string) as any;

    const { data, error } = await query;
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      // If the activities table doesn't exist yet, return an empty list instead of 500
      if (
        msg.includes('does not exist') ||
        msg.includes('no such table') ||
        (msg.includes('relation') && msg.includes('does not exist')) ||
        msg.includes('undefined_table')
      ) {
        console.warn('Activities table missing; returning empty activities list');
        return NextResponse.json({ activities: [] });
      }

      console.error('Activities query error', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    const payload = (data || []).map((a: any) => ({
      id: a.id,
      title: a.title,
      description: a.description,
      timestamp: a.created_at,
    }));

    return NextResponse.json({ activities: payload });
  } catch (err) {
    console.error('Activities.route error', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for activities POST', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, title, description } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });
    if (!title) return NextResponse.json({ error: 'missing title' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();
    const insertRow: Record<string, any> = { user_id: userId, title: String(title) };
    if (typeof description === 'string') insertRow.description = description;

    // capture optional metadata (user agent and forward IP) when available
    try {
      const ua = req.headers.get('user-agent');
      if (ua) insertRow.user_agent = String(ua).slice(0, 2000);
      const xff = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip');
      if (xff) insertRow.ip = String(xff).split(',')[0].trim();
    } catch (e) {
      // headers may not be available in some runtimes — ignore
    }

    const { error } = await admin.from('activities').insert([insertRow]);
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      if (msg.includes('relation') && msg.includes('does not exist')) {
        // activities table missing — don't fail, return a warning
        console.warn('activities table missing; activity not recorded');
        return NextResponse.json({ success: true, warning: 'activities table missing; not recorded' });
      }
      console.error('Activities insert error', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error('Activities.POST error', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
