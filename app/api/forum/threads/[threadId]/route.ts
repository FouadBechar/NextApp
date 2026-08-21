import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';
import { sanitizeText, truncate } from '@/utils/sanitizer';
import parseJsonOrEmpty from '@/utils/parse-request';

export async function DELETE(req: Request, context: any) {
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
    const { data: thread, error: tErr } = await admin.from('forum_threads').select('id,author_id').eq('id', threadId).maybeSingle();
    if (tErr) {
      console.error('Failed to fetch thread for delete', tErr);
      return NextResponse.json({ error: 'Failed to fetch thread' }, { status: 500 });
    }
    if (!thread) return NextResponse.json({ error: 'Thread not found' }, { status: 404 });

    // Only author may delete the thread (you can extend with admin checks)
    if (thread.author_id !== userId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

    // delete posts then thread
    try {
      await admin.from('forum_posts').delete().eq('thread_id', threadId);
    } catch (e) {
      console.error('Failed to delete posts for thread', e);
      // continue to attempt deleting thread row nonetheless
    }

    const { error: delErr } = await admin.from('forum_threads').delete().eq('id', threadId);
    if (delErr) {
      console.error('Failed to delete thread', delErr);
      return NextResponse.json({ error: 'Failed to delete thread' }, { status: 500 });
    }

    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error('Thread DELETE error', err);
    return NextResponse.json({ error: 'Unable to delete thread' }, { status: 500 });
  }
}

export async function PATCH(req: Request, context: any) {
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
      console.error('Invalid JSON for thread PATCH', e);
      return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 });
    }

    const title = typeof body.title === 'string' ? String(body.title).trim().slice(0, 300) : undefined;
    const content = typeof body.content === 'string' ? truncate(String(body.content).trim(), 20000) : undefined;
    if (!title && !content) return NextResponse.json({ error: 'No fields to update' }, { status: 400 });

    const admin = createAdminClient();
    const { data: thread, error: tErr } = await admin.from('forum_threads').select('id,author_id').eq('id', threadId).maybeSingle();
    if (tErr) {
      console.error('Failed to fetch thread for patch', tErr);
      return NextResponse.json({ error: 'Failed to fetch thread' }, { status: 500 });
    }
    if (!thread) return NextResponse.json({ error: 'Thread not found' }, { status: 404 });

    if (thread.author_id !== userId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

    const updatePayload: any = {};
    if (title !== undefined) updatePayload.title = title;
    if (content !== undefined) updatePayload.content = content;

    const { data: updated, error: uErr } = await admin.from('forum_threads').update(updatePayload).eq('id', threadId).select().maybeSingle();
    if (uErr) {
      console.error('Failed to update thread', uErr);
      return NextResponse.json({ error: 'Failed to update thread' }, { status: 500 });
    }

    return NextResponse.json({ thread: updated });
  } catch (err) {
    console.error('Thread PATCH error', err);
    return NextResponse.json({ error: 'Unable to update thread' }, { status: 500 });
  }
}
