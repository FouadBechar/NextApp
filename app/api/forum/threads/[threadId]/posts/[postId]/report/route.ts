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
    const postId = params?.postId ?? params?.postid;
    if (!threadId || !postId) return NextResponse.json({ error: 'Missing threadId or postId' }, { status: 400 });

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
    const { data: post, error: pErr } = await admin.from('forum_posts').select('id,thread_id').eq('id', postId).maybeSingle();
    if (pErr) {
      console.error('Failed to fetch post for report', pErr);
      return NextResponse.json({ error: 'Failed to fetch post' }, { status: 500 });
    }
    if (!post) return NextResponse.json({ error: 'Post not found' }, { status: 404 });
    if (String(post.thread_id) !== String(threadId)) return NextResponse.json({ error: 'Post does not belong to thread' }, { status: 400 });

    const { error: insErr } = await admin.from('forum_reports').insert([{ reporter_id: userId, target_type: 'post', thread_id: threadId, post_id: postId, reason }]);
    if (insErr) {
      console.error('Failed to create post report', insErr);
      return NextResponse.json({ error: 'Failed to create report' }, { status: 500 });
    }

    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error('Post report error', err);
    return NextResponse.json({ error: 'Unable to report post' }, { status: 500 });
  }
}
