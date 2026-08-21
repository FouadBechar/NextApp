import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';

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

    const admin = createAdminClient();
    const { data: post, error: pErr } = await admin.from('forum_posts').select('id,author_id,pinned,thread_id').eq('id', postId).maybeSingle();
    if (pErr) {
      console.error('Failed to fetch post for pin', pErr);
      return NextResponse.json({ error: 'Failed to fetch post' }, { status: 500 });
    }
    if (!post) return NextResponse.json({ error: 'Post not found' }, { status: 404 });
    if (String(post.thread_id) !== String(threadId)) return NextResponse.json({ error: 'Post does not belong to thread' }, { status: 400 });

    if (post.author_id !== userId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

    const newPinned = !Boolean(post.pinned);
    const { data: updated, error: uErr } = await admin.from('forum_posts').update({ pinned: newPinned }).eq('id', postId).select().maybeSingle();
    if (uErr) {
      console.error('Failed to update pinned state for post', uErr);
      return NextResponse.json({ error: 'Failed to update pinned state' }, { status: 500 });
    }

    return NextResponse.json({ post: updated });
  } catch (err) {
    console.error('Post pin error', err);
    return NextResponse.json({ error: 'Unable to toggle pinned state' }, { status: 500 });
  }
}
