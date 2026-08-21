import { NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';

// POST /api/dashboard/profile/sync-avatars
// body: { userId: string }
export async function POST(req: Request) {
  try {
    const body = await req.json().catch(() => ({}));
    const userId = String(body?.userId || '').trim();
    if (!userId) return NextResponse.json({ error: 'userId required' }, { status: 400 });

    const admin = createAdminClient();

    // load profile
    const { data: prof, error: profErr } = await admin
      .from('profiles')
      .select('avatar_path')
      .eq('id', userId)
      .maybeSingle();

    if (profErr) {
      console.error('Failed to load profile for sync', profErr);
      return NextResponse.json({ error: 'Failed to load profile' }, { status: 500 });
    }

    let resolvedAvatar: string | null = null;
    const path = prof?.avatar_path ?? null;
    if (!resolvedAvatar && path) {
      try {
        const parts = String(path).split('/');
        const bucket = parts.length > 1 ? parts[0] : 'avatars';
        // If path already includes the bucket prefix (e.g. "avatars/xxx"), keep it
        const filePath = String(path).startsWith(`${bucket}/`) ? String(path) : parts.length > 1 ? parts.slice(1).join('/') : String(path);
        const { data: urlData } = admin.storage.from(bucket).getPublicUrl(filePath);
        if (urlData?.publicUrl) resolvedAvatar = urlData.publicUrl;
        else {
          try {
            const { data: signed } = await admin.storage.from(bucket).createSignedUrl(filePath, 60 * 60);
            if (signed?.signedUrl) resolvedAvatar = signed.signedUrl;
          } catch (e) {
            // ignore
          }
        }
      } catch (e) {
        // ignore
      }
    }

    // Persist resolved avatar_url to profiles table (so GET requests can read it directly)
    try {
      await admin.from('profiles').update({ avatar_url: resolvedAvatar }).eq('id', userId);
    } catch (e) {
      console.error('Failed to persist avatar_url to profiles', e);
      // continue; this is non-fatal to the sync operation
    }

    // Update forum tables to set denormalized avatar URL and original path
    try {
      await admin.from('forum_threads').update({ author_avatar_url: resolvedAvatar, author_avatar_path: path }).eq('author_id', userId);
      await admin.from('forum_posts').update({ author_avatar_url: resolvedAvatar, author_avatar_path: path }).eq('author_id', userId);
    } catch (e) {
      console.error('Failed to update forum rows for avatar sync', e);
      return NextResponse.json({ error: 'Failed to update forum rows' }, { status: 500 });
    }

    return NextResponse.json({ success: true, avatar: resolvedAvatar });
  } catch (err) {
    console.error('Sync avatars error', err);
    return NextResponse.json({ error: 'Unexpected error' }, { status: 500 });
  }
}
