import { NextResponse, type NextRequest } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import parseJsonOrEmpty from '@/utils/parse-request';
import { createServerClient } from '@supabase/ssr';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

// Using shared `verifyUserFromRequest` helper

export async function GET(req: NextRequest) {
  try {
    const url = new URL(req.url);
    let userId = url.searchParams.get('userId');

    // If caller omitted userId, attempt to verify the request (cookie or token)
    // and derive the user id from the authenticated session. This supports
    // client-side calls that rely on cookies instead of passing the id.
    if (!userId) {
      const verifiedSession = await verifyUserFromRequest(req);
      if (!verifiedSession.ok) return NextResponse.json({ error: verifiedSession.reason || 'unauthorized' }, { status: verifiedSession.status || 401 });
      userId = verifiedSession.user.id;
    } else {
      const verified = await verifyUserFromRequest(req, userId);
      if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });
    }

    const supabase = createAdminClient();
    let profileData: any = null;
    const { data, error } = await supabase.from('profiles').select('full_name,username,avatar_path,avatar_url,preferences').eq('id', userId).maybeSingle();
    if (error) {
      console.error('Profile query error', error);
      return isoError(error.message);
    }
    profileData = data || null;

    // Compute public URL when we have an avatar_path (respecting config for public/private buckets)
    try {
      const AVATAR_BUCKET = process.env.SUPABASE_AVATAR_BUCKET ?? 'avatars';
      const AVATAR_PUBLIC = (process.env.SUPABASE_AVATAR_PUBLIC ?? 'true').toLowerCase() !== 'false' && (process.env.SUPABASE_AVATAR_PUBLIC ?? 'true') !== '0';
      const AVATAR_SIGNED_URL_TTL = parseInt(process.env.SUPABASE_AVATAR_SIGNED_URL_TTL || '60', 10) || 60;

      const admin = createAdminClient();
      let avatarUrl: string | null = profileData?.avatar_url ?? null;
      let avatar_path: string | null = profileData?.avatar_path || null;
      if (!avatarUrl && avatar_path) {
        try {
          if (AVATAR_PUBLIC) {
            const { data } = admin.storage.from(AVATAR_BUCKET).getPublicUrl(String(avatar_path));
            avatarUrl = data?.publicUrl || null;
          } else {
            const { data, error } = await admin.storage.from(AVATAR_BUCKET).createSignedUrl(String(avatar_path), AVATAR_SIGNED_URL_TTL);
            if (!error) avatarUrl = data?.signedUrl || null;
            else console.error('createSignedUrl error', error);
          }
        } catch (e) {
          console.error('Error generating avatar URL', e);
        }
      }

      const prefs = profileData?.preferences as { theme?: unknown; totp?: any } | undefined;
      const totp = prefs?.totp ?? null;
      const theme =
        prefs?.theme === 'light' || prefs?.theme === 'dark' || prefs?.theme === 'system'
          ? prefs.theme
          : null;

      // Validate trusted-device cookie using only DB-backed token hashes.
      let trustedDevice = false;
      try {
        const cookie = req.cookies.get('trusted_device');
        const raw = cookie ? (typeof cookie === 'string' ? cookie : ((cookie as { value?: string }).value ?? null)) : null;
        if (raw && typeof raw === 'string') {
          try {
            const crypto = await import('crypto');
            const hash = crypto.createHash('sha256').update(raw).digest('hex');
            const admin = createAdminClient();
            const { data: matched, error: matchErr } = await admin.from('trusted_devices').select('id').eq('user_id', userId).eq('token_hash', hash).maybeSingle();
            if (matchErr) {
              const msg = String(matchErr.message || '').toLowerCase();
              if (!(msg.includes('relation') && msg.includes('does not exist'))) {
                console.error('trusted_devices select error', matchErr);
              }
            } else if (matched) {
              trustedDevice = true;
            }
          } catch (e) {
            console.warn('trusted_device validation failed', e);
          }
        }
      } catch (e) {
        // ignore cookie parsing errors
      }

      const out = {
        id: userId,
        full_name: profileData?.full_name || null,
        username: profileData?.username || null,
        avatar: avatarUrl,
        avatar_url: (profileData?.avatar_url ?? avatarUrl) || null,
        avatar_path,
        preferences: { theme },
        totp,
        trustedDevice,
      };

      return NextResponse.json({ profile: out });
    } catch (e) {
      console.error('Profile GET URL generation error', e);
      return NextResponse.json({ profile: { id: userId, full_name: profileData?.full_name || null, username: profileData?.username || null, avatar: null, avatar_path: profileData?.avatar_path || null } });
    }
  } catch (err) {
    console.error('Profile.route GET error', err);
    return isoError();
  }
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for profile POST', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, full_name, username, avatar_path } = body || {};

    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const updates: Record<string, any> = {};
    if (typeof full_name === 'string') updates.full_name = full_name;
    if (typeof username === 'string') updates.username = username;

    // Accept avatar_path only (storage path)
    if (typeof avatar_path === 'string') {
      const MAX_PATH = 1000;
      if (avatar_path.length > MAX_PATH) return NextResponse.json({ error: { code: 'AVATAR_PATH_TOO_LONG', message: `avatar_path must be <= ${MAX_PATH} characters` } }, { status: 400 });
      const trimmed = avatar_path.trim().replace(/^\//, '');
      if (!/^avatars\/.+/.test(trimmed)) return NextResponse.json({ error: { code: 'INVALID_AVATAR_PATH', message: 'avatar_path must start with "avatars/"' } }, { status: 400 });
      updates.avatar_path = trimmed;
    }

    // Username uniqueness validation
    if (typeof username === 'string' && username.trim()) {
      try {
        const supabase = createAdminClient();
        const { data: existing, error: existingError } = await supabase.from('profiles').select('id').eq('username', username).neq('id', userId).limit(1).maybeSingle();
        if (existingError) {
          console.error('Username uniqueness check error', existingError);
          return isoError(existingError.message);
        }
        if (existing) return NextResponse.json({ error: { code: 'USERNAME_TAKEN', message: 'That username is already taken' } }, { status: 409 });
      } catch (e) {
        console.error('Username check unexpected error', e);
        return isoError();
      }
    }

    if (Object.keys(updates).length === 0) return NextResponse.json({ error: 'no updatable fields provided' }, { status: 400 });

    const supabase = createAdminClient();
    const { data, error } = await supabase.from('profiles').update(updates).eq('id', userId).select('full_name,username,avatar_path,avatar_url').maybeSingle();
    if (error) {
      console.error('Profile update error', error);
      return isoError(error.message);
    }

    // Compute a public avatar URL when avatar_path is present
    try {
      const AVATAR_BUCKET = process.env.SUPABASE_AVATAR_BUCKET ?? 'avatars';
      const AVATAR_PUBLIC = (process.env.SUPABASE_AVATAR_PUBLIC ?? 'true').toLowerCase() !== 'false' && (process.env.SUPABASE_AVATAR_PUBLIC ?? 'true') !== '0';
      const AVATAR_SIGNED_URL_TTL = parseInt(process.env.SUPABASE_AVATAR_SIGNED_URL_TTL || '60', 10) || 60;

      const admin = createAdminClient();
      const avatar_path_res = data?.avatar_path || null;
      let avatarUrl: string | null = null;
      if (avatar_path_res) {
        try {
          if (AVATAR_PUBLIC) {
            const { data: urlData } = admin.storage.from(AVATAR_BUCKET).getPublicUrl(String(avatar_path_res));
            avatarUrl = urlData?.publicUrl || null;
          } else {
            const { data: urlData, error } = await admin.storage.from(AVATAR_BUCKET).createSignedUrl(String(avatar_path_res), AVATAR_SIGNED_URL_TTL);
              if (!error) avatarUrl = urlData?.signedUrl || null;
            else console.error('createSignedUrl error', error);
          }
        } catch (e) {
          console.error('Error generating avatar URL', e);
        }
      }

      // Persist computed avatar_url in the profiles table so clients can read a stable URL
      try {
        if (avatarUrl !== null) {
          const { error: avatarUpdateErr } = await supabase.from('profiles').update({ avatar_url: avatarUrl }).eq('id', userId);
          if (avatarUpdateErr) console.error('Failed to persist avatar_url to profiles', avatarUpdateErr);
        } else {
          // If there is no computed avatarUrl but the row has an avatar_url set, ensure we clear it
          if (data?.avatar_url) {
            const { error: avatarClearErr } = await supabase.from('profiles').update({ avatar_url: null }).eq('id', userId);
            if (avatarClearErr) console.error('Failed to clear avatar_url from profiles', avatarClearErr);
          }
        }
      } catch (e) {
        console.error('Failed to persist avatar_url in profiles', e);
      }

      // After updating the profile, sync denormalized forum rows so display and avatars stay current
      try {
        const admin = createAdminClient();
        const authorDisplay = data?.full_name || data?.username || null;
        const authorAvatarUrl = avatarUrl || null;
        // update threads and posts for this user
        try {
          await admin.from('forum_threads').update({ author_display: authorDisplay, author_avatar_url: authorAvatarUrl, author_avatar_path: avatar_path_res }).eq('author_id', userId);
        } catch (e) {
          console.error('Failed to update forum_threads during profile sync', e);
        }
        try {
          await admin.from('forum_posts').update({ author_display: authorDisplay, author_avatar_url: authorAvatarUrl, author_avatar_path: avatar_path_res }).eq('author_id', userId);
        } catch (e) {
          console.error('Failed to update forum_posts during profile sync', e);
        }
      } catch (e) {
        console.error('Profile sync to forum rows failed', e);
      }

      return NextResponse.json({ profile: { id: userId, full_name: data?.full_name || null, username: data?.username || null, avatar: avatarUrl, avatar_path: data?.avatar_path || null, avatar_url: avatarUrl } });
    } catch (e) {
      console.error('Profile update URL generation error', e);
      return NextResponse.json({ profile: data || null });
    }
  } catch (err) {
    console.error('Profile.route POST error', err);
    return isoError();
  }
}
 
