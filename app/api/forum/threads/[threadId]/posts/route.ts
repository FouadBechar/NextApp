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

    // Add basic pagination support to the posts API to avoid overly large
    // responses that can slow the dev server / tests. Clients may pass
    // ?limit=N&offset=M to control the page.
    const url = new URL(req.url);
    const limitParam = Number(url.searchParams.get('limit') || '200');
    const offsetParam = Number(url.searchParams.get('offset') || '0');
    // validate and clamp values
    const limit = Number.isFinite(limitParam) ? Math.min(Math.max(1, Math.floor(limitParam)), 1000) : 200;
    const offset = Number.isFinite(offsetParam) ? Math.max(0, Math.floor(offsetParam)) : 0;

    const { data: posts, error } = await admin
      .from('forum_posts')
      .select('id, thread_id, content, author_id, author_display, author_avatar_url, pinned, created_at')
      .eq('thread_id', threadId)
      .order('created_at', { ascending: true })
      .range(offset, offset + (limit - 1));

    if (error) {
      console.error('Failed to fetch posts', error);
      return NextResponse.json({ posts: [] }, { status: 500 });
    }

    // enrich posts with author profile info when available
    const authorIds = Array.from(new Set((posts || []).map((p: any) => p.author_id).filter(Boolean))) as string[];
    let profilesMap: Record<string, any> = {};
    if (authorIds.length) {
      const { data: profiles } = await admin
        .from('profiles')
          .select('id, username, avatar_url')
        .in('id', authorIds);
      if (profiles && Array.isArray(profiles)) {
        for (const p of profiles) {
          const resolvedAvatar: string | null = p.avatar_url ?? null;
          profilesMap[p.id] = { ...p, resolvedAvatar };
        }
      }
    }

    // We no longer perform storage-specific normalization here. The API
    // will prefer `author_avatar_url` (or `profile.avatar_url`) which should
    // already be canonical. If any DB rows lack `avatar_url`, backfilling
    // should be done rather than trying to reformat storage URLs here.

    const enrichedPosts = (posts || []).map((p: any) => {
      const prof = p.author_id ? profilesMap[p.author_id] : null;
      return {
        ...p,
        author_display: prof?.username ?? null,
        // prefer denormalized avatar URL from the row when available
        author_avatar_url: p.author_avatar_url ?? prof?.avatar_url ?? prof?.resolvedAvatar ?? null,
        // removed author_full_name, frontends should use username only
      };
    });

    return NextResponse.json({ posts: enrichedPosts });
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

  let body: any = {};
  try {
    const text = await req.text();
    if (!text) {
      console.error('Empty request body for creating forum post');
      return NextResponse.json({ error: 'Empty request body' }, { status: 400 });
    }
    body = JSON.parse(text);
  } catch (e) {
    console.error('Invalid JSON body for creating forum post', e);
    return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
  }

  let content = String(body.content || '').trim();
  content = truncate(content, 20000);

    const admin = createAdminClient();

    // Validate that the thread exists and avoid attempts to insert replies
    // for optimistic-temporary client-side IDs like `temp-...` which will
    // otherwise cause a DB foreign key error and a 500 response.
    if (!threadId || String(threadId).startsWith('temp-')) {
      console.error('Invalid thread id for post', { threadId });
      return NextResponse.json({ error: 'Invalid or missing thread id' }, { status: 400 });
    }
    try {
      const { data: existingThread } = await admin.from('forum_threads').select('id').eq('id', threadId).maybeSingle();
      if (!existingThread) {
        console.error('Attempt to post reply to non-existing thread', { threadId });
        return NextResponse.json({ error: 'Thread not found' }, { status: 404 });
      }
    } catch (e) {
      console.error('Error checking thread existence', { threadId, error: e });
      // proceed — we'll still attempt insert and return any DB error; this check
      // is just a helpful early-return to make client errors friendlier.
    }

    // derive author_display and resolved avatar from profile for stable display and faster reads
    let authorDisplay: string | null = null;
    let authorAvatarUrl: string | null = null;
    let prof: any = null;
    try {
      console.debug('Creating forum post', { threadId, userId, content, authorDisplay });
      const { data } = await admin.from('profiles').select('username, email, avatar_path, avatar_url').eq('id', userId).maybeSingle();
      prof = data;
      if (prof) {
        // only use username  for display; full_name is deprecated
        authorDisplay = prof.username || null;
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
        // prefer explicit profile avatar_url if present
        if (prof?.avatar_url) authorAvatarUrl = prof.avatar_url;
      }
    } catch (e) {
      // ignore
    }

      const insert = await admin.from('forum_posts').insert([{ thread_id: threadId, content, author_id: userId, author_display: authorDisplay, author_avatar_url: authorAvatarUrl }]).select('id, thread_id, content, author_id, author_display, author_avatar_url, created_at').single();
      if (insert.error) {
        console.error('Failed to create post', { threadId, error: insert.error, payload: { content, author_id: userId, author_display: authorDisplay, author_avatar_url: authorAvatarUrl } });
        return NextResponse.json({ error: insert.error.message, details: insert.error }, { status: 500 });
      }

    // NOTE: reply_count maintenance should be handled atomically in the
    // database (trigger/RPC) or by an explicit increment. Removed the
    // no-op update that previously attempted to touch the thread row.

    return NextResponse.json({ post: insert.data });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ error: 'Unable to post reply' }, { status: 500 });
  }
}
