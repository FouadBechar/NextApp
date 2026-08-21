import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';
import { sanitizeText, truncate } from '@/utils/sanitizer';

export async function DELETE(req: Request, context: any) {
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
    const { data: post, error: pErr } = await admin.from('forum_posts').select('id,author_id,thread_id').eq('id', postId).maybeSingle();
    if (pErr) {
      console.error('Failed to fetch post for delete', pErr);
      return NextResponse.json({ error: 'Failed to fetch post' }, { status: 500 });
    }
    if (!post) return NextResponse.json({ error: 'Post not found' }, { status: 404 });
    if (String(post.thread_id) !== String(threadId)) return NextResponse.json({ error: 'Post does not belong to thread' }, { status: 400 });

    // Only author may delete their post (extend to admin if needed)
    if (post.author_id !== userId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

    const { error: delErr } = await admin.from('forum_posts').delete().eq('id', postId);
    if (delErr) {
      console.error('Failed to delete post', delErr);
      return NextResponse.json({ error: 'Failed to delete post' }, { status: 500 });
    }

    // note: reply counts are computed on read; if you store a denormalized count, update here

    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error('Post DELETE error', err);
    return NextResponse.json({ error: 'Unable to delete post' }, { status: 500 });
  }
}

export async function PATCH(req: Request, context: any) {
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
      const text = await req.text();
      body = text ? JSON.parse(text) : {};
    } catch (e) {
      console.error('Invalid JSON body for patching post', e);
      return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 });
    }

    const content = typeof body.content === 'string' ? truncate(String(body.content).trim(), 20000) : undefined;
    if (!content) return NextResponse.json({ error: 'No fields to update' }, { status: 400 });

    const admin = createAdminClient();
    const { data: post, error: pErr } = await admin.from('forum_posts').select('id,author_id,thread_id').eq('id', postId).maybeSingle();
    if (pErr) {
      console.error('Failed to fetch post for patch', pErr);
      return NextResponse.json({ error: 'Failed to fetch post' }, { status: 500 });
    }
    if (!post) return NextResponse.json({ error: 'Post not found' }, { status: 404 });
    if (String(post.thread_id) !== String(threadId)) return NextResponse.json({ error: 'Post does not belong to thread' }, { status: 400 });

    if (post.author_id !== userId) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

    const { data: updated, error: uErr } = await admin.from('forum_posts').update({ content }).eq('id', postId).select().maybeSingle();
    if (uErr) {
      console.error('Failed to update post', uErr);
      return NextResponse.json({ error: 'Failed to update post' }, { status: 500 });
    }

    return NextResponse.json({ post: updated });
  } catch (err) {
    console.error('Post PATCH error', err);
    return NextResponse.json({ error: 'Unable to update post' }, { status: 500 });
  }
}
