import { NextResponse, type NextRequest } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { createServerClient } from '@supabase/ssr';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

async function verifyUserFromRequest(req: NextRequest, expectedUserId?: string) {
  // Try cookie-based verification first (preferred)
  try {
    const serverSupabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return req.cookies.getAll();
          },
          setAll() {
            /* no-op for API */
          },
        },
      }
    );

    const {
      data: { user },
    } = await serverSupabase.auth.getUser();

    if (user && (!expectedUserId || user.id === expectedUserId)) {
      return { ok: true, user, via: 'cookie' };
    }
  } catch (e) {
    // ignore and try header
  }

  // Fallback to Authorization header token verification
  const authHeader = req.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { ok: false, status: 401, reason: 'missing authorization' };
  }
  const token = authHeader.split(' ')[1];
  try {
    const admin = createAdminClient();
    const userRes = await (admin.auth as any).getUser(token);
    const fetchedUser = userRes?.data?.user;
    if (!fetchedUser) return { ok: false, status: 401, reason: 'invalid token' };
    if (expectedUserId && fetchedUser.id !== expectedUserId) {
      return { ok: false, status: 403, reason: 'forbidden' };
    }
    return { ok: true, user: fetchedUser, via: 'token' };
  } catch (e) {
    return { ok: false, status: 401, reason: 'invalid token' };
  }
}

export async function GET(req: NextRequest) {
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');

    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const supabase = createAdminClient();
    let profileData: any = null;
    const { data, error } = await supabase.from('profiles').select('full_name,username,avatar_path,preferences').eq('id', userId).maybeSingle();
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
      let avatarUrl: string | null = null;
      let avatar_path: string | null = null;

      avatar_path = profileData?.avatar_path || null;
      if (avatar_path) {
        try {
          if (AVATAR_PUBLIC) {
            const { data } = admin.storage.from(AVATAR_BUCKET).getPublicUrl(String(avatar_path));
            avatarUrl = data?.publicUrl || null;
          } else {
            const { data, error } = await admin.storage.from(AVATAR_BUCKET).createSignedUrl(String(avatar_path), AVATAR_SIGNED_URL_TTL);
            if (!error) avatarUrl = (data as any)?.signedUrl || null;
            else console.error('createSignedUrl error', error);
          }
        } catch (e) {
          console.error('Error generating avatar URL', e);
        }
      }

      const totp = (profileData?.preferences && (profileData.preferences as any).totp) || null;

      // Validate trusted-device cookie. Prefer DB-backed validation by hashing the
      // cookie token and comparing to the token_hash in `trusted_devices` table.
      // If the table is missing or DB check fails, fall back to the legacy prefix check.
      let trustedDevice = false;
      try {
        const cookie = req.cookies.get('trusted_device');
        const raw = cookie ? (typeof cookie === 'string' ? cookie : (cookie as any).value) : null;
        if (raw && typeof raw === 'string') {
          try {
            const crypto = await import('crypto');
            const hash = crypto.createHash('sha256').update(raw).digest('hex');
            const admin = createAdminClient();
            const { data: matched, error: matchErr } = await admin.from('trusted_devices').select('id').eq('user_id', userId).eq('token_hash', hash).maybeSingle();
            if (matchErr) {
              const msg = String(matchErr.message || '').toLowerCase();
              // If the table does not exist, fall back to the legacy prefix behavior.
              if (msg.includes('relation') && msg.includes('does not exist')) {
                if (raw.startsWith(`${userId}:`)) trustedDevice = true;
              } else {
                console.error('trusted_devices select error', matchErr);
              }
            } else if (matched) {
              trustedDevice = true;
            } else {
              // no db match — fall back to prefix check for compatibility
              if (raw.startsWith(`${userId}:`)) trustedDevice = true;
            }
          } catch (e) {
            // crypto or DB failures — fallback to prefix check
            try { if (raw.startsWith(`${userId}:`)) trustedDevice = true; } catch (ev) { /* ignore */ }
          }
        }
      } catch (e) {
        // ignore cookie parsing errors
      }

      const out = {
        full_name: profileData?.full_name || null,
        username: profileData?.username || null,
        avatar: avatarUrl,
        avatar_path,
        totp,
        trustedDevice,
      };

      return NextResponse.json({ profile: out });
    } catch (e) {
      console.error('Profile GET URL generation error', e);
      return NextResponse.json({ profile: { full_name: profileData?.full_name || null, username: profileData?.username || null, avatar: null, avatar_path: profileData?.avatar_path || null } });
    }
  } catch (err) {
    console.error('Profile.route GET error', err);
    return isoError();
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
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
    const { data, error } = await supabase.from('profiles').update(updates).eq('id', userId).select('full_name,username,avatar_path').maybeSingle();
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
            if (!error) avatarUrl = (urlData as any)?.signedUrl || null;
            else console.error('createSignedUrl error', error);
          }
        } catch (e) {
          console.error('Error generating avatar URL', e);
        }
      }

      return NextResponse.json({ profile: { full_name: data?.full_name || null, username: data?.username || null, avatar: avatarUrl, avatar_path: data?.avatar_path || null } });
    } catch (e) {
      console.error('Profile update URL generation error', e);
      return NextResponse.json({ profile: data || null });
    }
  } catch (err) {
    console.error('Profile.route POST error', err);
    return isoError();
  }
}
 
