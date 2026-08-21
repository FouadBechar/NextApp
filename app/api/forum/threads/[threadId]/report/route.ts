import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';
import { sanitizeText } from '@/utils/sanitizer';

export async function POST(req: Request, context: any) {
  try {
    let params = context?.params;
    if (params && typeof params.then === 'function') params = await params;
    const threadId = params?.threadId ?? params?.threadid;
    if (!threadId) return NextResponse.json({ error: 'Missing threadId' }, { status: 400 });

    const server = await createServerClient();
    const { data: sessionData } = await server.auth.getSession();
    const userId = sessionData?.session?.user?.id;
    if (!userId) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req);
    } catch (e) {
      body = {};
    }
    const reason = typeof body.reason === 'string' ? sanitizeText(String(body.reason).trim()) : null;

    const admin = createAdminClient();
    const { data: thread, error: tErr } = await admin.from('forum_threads').select('id').eq('id', threadId).maybeSingle();
    if (tErr) {
      console.error('Failed to fetch thread for report', tErr);
      return NextResponse.json({ error: 'Failed to fetch thread' }, { status: 500 });
    }
    if (!thread) return NextResponse.json({ error: 'Thread not found' }, { status: 404 });

    const { error: insErr } = await admin.from('forum_reports').insert([{ reporter_id: userId, target_type: 'thread', thread_id: threadId, post_id: null, reason }]);
    if (insErr) {
      console.error('Failed to create report', insErr);
      return NextResponse.json({ error: 'Failed to create report' }, { status: 500 });
    }

    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error('Thread report error', err);
    return NextResponse.json({ error: 'Unable to report thread' }, { status: 500 });
  }
}
