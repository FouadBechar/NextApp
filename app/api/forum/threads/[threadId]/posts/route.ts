import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';
import { sanitizeText, truncate } from '@/utils/sanitizer';

export async function GET(req: Request, context: any) {
  try {
    // context.params may be a plain object or a Promise depending on runtime/type-gen.
    let params = context?.params;
    if (params && typeof params.then === 'function') {
      params = await params;
    }
    const threadId = params?.threadId ?? params?.threadid;
    const admin = createAdminClient();
    const { data: posts, error } = await admin
      .from('forum_posts')
      .select('id, thread_id, content, author_id, author_display, created_at')
      .eq('thread_id', threadId)
      .order('created_at', { ascending: true });

    if (error) {
      console.error('Failed to fetch posts', error);
      return NextResponse.json({ posts: [] }, { status: 500 });
    }

    return NextResponse.json({ posts });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ posts: [] }, { status: 500 });
  }
}

export async function POST(req: Request, context: any) {
  try {
    let params = context?.params;
    if (params && typeof params.then === 'function') {
      params = await params;
    }
    const threadId = params?.threadId ?? params?.threadid;
    const server = await createServerClient();
    const { data: sessionData } = await server.auth.getSession();
    const userId = sessionData?.session?.user?.id;
    if (!userId) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json();
  let content = String(body.content || '').trim();
  content = truncate(content, 20000);
  content = sanitizeText(content);

    const admin = createAdminClient();
    const insert = await admin.from('forum_posts').insert([{ thread_id: threadId, content, author_id: userId }]).select().single();
    if (insert.error) {
      console.error('Failed to create post', insert.error);
      return NextResponse.json({ error: insert.error.message }, { status: 500 });
    }

    // Optionally update thread reply_count if you maintain it
    try {
      await admin.from('forum_threads').update({}).eq('id', threadId);
    } catch (e) {
      // non-fatal
    }

    return NextResponse.json({ post: insert.data });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ error: 'Unable to post reply' }, { status: 500 });
  }
}
