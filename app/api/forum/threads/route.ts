import { NextResponse } from 'next/server';
import { createClient as createServerClient } from '@/utils/supabase/server';
import { createAdminClient } from '@/utils/supabase/client';
import { sanitizeText, truncate } from '@/utils/sanitizer';
import parseJsonOrEmpty from '@/utils/parse-request';

export async function GET() {
  try {
    const admin = createAdminClient();
    const { data: threads, error } = await admin
      .from('forum_threads')
      .select('id, title, content, author_id, author_display, author_avatar_url, pinned, created_at')
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

    // enrich threads with author profile info when available
    const authorIds = Array.from(new Set((threads || []).map((t: any) => t.author_id).filter(Boolean))) as string[];
    let profilesMap: Record<string, any> = {};
    if (authorIds.length) {
      const { data: profiles } = await admin
        .from('profiles')
          .select('id, username, avatar_url')
        .in('id', authorIds);
      if (profiles && Array.isArray(profiles)) {
        // compute usable avatar URL for each profile
        for (const p of profiles) {
          const resolvedAvatar: string | null = p.avatar_url ?? null;
          profilesMap[p.id] = { ...p, resolvedAvatar };
        }
      }
    }

    // Note: we previously normalized storage-based avatar URLs to ensure
    // consistent formats. As we now standardize on `avatar_url` across
    // profiles and forum rows (backfilled as needed), we no longer need
    // storage-specific normalizations here.

    const enriched = (threads || []).map((t: any) => {
      const prof = t.author_id ? profilesMap[t.author_id] : null;
      return {
        ...t,
        reply_count: counts[t.id] || 0,
        author_display: prof?.username ?? null,
        // prefer denormalized author_avatar_url from the row when available
        author_avatar_url: t.author_avatar_url ?? prof?.avatar_url ?? prof?.resolvedAvatar ?? null,
        // removed author_full_name, frontends should use username only
      };
    });

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

  let body: any = {};
  try {
    body = await parseJsonOrEmpty(req);
  } catch (e) {
    console.error('Invalid JSON body for creating thread', e);
    return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
  }

  let title = String(body.title || '').trim();
  let content = String(body.content || '').trim();

  // Basic validation
  if (!title) return NextResponse.json({ error: 'Title required' }, { status: 400 });
  if (title.length > 300) title = title.slice(0, 300);
  content = truncate(content, 20000);


    const admin = createAdminClient();
    // derive author_display and resolved avatar from profile so threads carry stable display and avatar
    let authorDisplay: string | null = null;
    let authorAvatarUrl: string | null = null;
    try {
      const { data: prof } = await admin.from('profiles').select('username, email, avatar_path, avatar_url').eq('id', userId).maybeSingle();
      if (prof) {
        // only use username for display; full_name is deprecated
        authorDisplay = prof.username || null;
        // resolve avatar from avatar_path
        // const path = prof.avatar_path ?? null;
        // if (path) {
        //   try {
        //     const parts = String(path).split('/');
        //     const bucket = parts.length > 1 ? parts[0] : 'avatars';
        //     const filePath = parts.length > 1 ? parts.slice(1).join('/') : String(path);
        //     const { data: urlData } = admin.storage.from(bucket).getPublicUrl(filePath);
        //     if (urlData?.publicUrl) authorAvatarUrl = urlData.publicUrl;
        //     else {
        //       try {
        //         const { data: signed } = await admin.storage.from(bucket).createSignedUrl(filePath, 60 * 60);
        //         if (signed?.signedUrl) authorAvatarUrl = signed.signedUrl;
        //       } catch (e) {
        //         // ignore
        //       }
        //     }
        //   } catch (e) {
        //     // ignore
        //   }
        // }
        // prefer explicitly stored avatar_url from the profile if present
        if (prof?.avatar_url) authorAvatarUrl = prof.avatar_url;
      }
    } catch (e) {
      // ignore
    }

    const insert = await admin.from('forum_threads').insert([{ title, content, author_id: userId, author_display: authorDisplay, author_avatar_url: authorAvatarUrl }]).select().single();
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


