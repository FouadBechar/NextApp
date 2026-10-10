import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';

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

    const admin = createAdminClient();
    const { data: thread, error: tErr } = await admin.from('forum_threads').select('id,author_id,pinned').eq('id', threadId).maybeSingle();
    if (tErr) {
      console.error('Failed to fetch thread for pin', tErr);
      return NextResponse.json({ error: 'Failed to fetch thread' }, { status: 500 });
    }
    if (!thread) return NextResponse.json({ error: 'Thread not found' }, { status: 404 });

    // Only author may pin/unpin their threads (mirror UI behavior)
    if (thread.author_id !== userId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

    const newPinned = !Boolean(thread.pinned);
    const { data: updated, error: uErr } = await admin.from('forum_threads').update({ pinned: newPinned }).eq('id', threadId).select().maybeSingle();
    if (uErr) {
      console.error('Failed to update pinned state', uErr);
      return NextResponse.json({ error: 'Failed to update pinned state' }, { status: 500 });
    }

    return NextResponse.json({ thread: updated });
  } catch (err) {
    console.error('Thread pin error', err);
    return NextResponse.json({ error: 'Unable to toggle pinned state' }, { status: 500 });
  }
}
