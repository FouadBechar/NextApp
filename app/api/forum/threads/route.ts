import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';
import { sanitizeText, truncate } from '@/utils/sanitizer';

export async function GET() {
  try {
    const admin = createAdminClient();
    const { data: threads, error } = await admin
      .from('forum_threads')
      .select('id, title, content, author_id, author_display, created_at')
      .order('created_at', { ascending: false })
      .limit(200);

    if (error) {
      console.error('Failed to fetch threads', error);
      return NextResponse.json({ threads: [] }, { status: 500 });
    }

    // compute reply counts
    const ids = (threads || []).map((t: any) => t.id);
    let counts: Record<string, number> = {};
    if (ids.length) {
      const { data: posts, error: pErr } = await admin
        .from('forum_posts')
        .select('thread_id')
        .in('thread_id', ids);
      if (!pErr && posts) {
        counts = posts.reduce((acc: any, p: any) => {
          acc[p.thread_id] = (acc[p.thread_id] || 0) + 1;
          return acc;
        }, {});
      }
    }

    const enriched = (threads || []).map((t: any) => ({ ...t, reply_count: counts[t.id] || 0 }));
    return NextResponse.json({ threads: enriched });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ threads: [] }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    const server = await createServerClient();
    const { data: sessionData } = await server.auth.getSession();
    const userId = sessionData?.session?.user?.id;
    if (!userId) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const body = await req.json();
  let title = String(body.title || '').trim();
  let content = String(body.content || '').trim();

  // Basic validation
  if (!title) return NextResponse.json({ error: 'Title required' }, { status: 400 });
  if (title.length > 300) title = title.slice(0, 300);
  content = truncate(content, 20000);

  // Sanitize to plain text/HTML-escaped to avoid XSS
  title = sanitizeText(title);
  content = sanitizeText(content);

    const admin = createAdminClient();
  const insert = await admin.from('forum_threads').insert([{ title, content, author_id: userId }]).select().single();
    if (insert.error) {
      console.error('Failed to create thread', insert.error);
      return NextResponse.json({ error: insert.error.message }, { status: 500 });
    }

    return NextResponse.json({ thread: insert.data });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ error: 'Unable to create thread' }, { status: 500 });
  }
}
