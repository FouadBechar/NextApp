import { NextRequest, NextResponse } from 'next/server';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

async function verifyUserFromRequest(req: NextRequest, expectedUserId?: string) {
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
            /* no-op */
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
    // ignore and try header token
  }

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

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for delete-account', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId } = body || {};

    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();

    // Fetch profile to find avatar_path (if any)
    try {
      const db = createAdminClient();
      const { data: profile, error: profileErr } = await db.from('profiles').select('avatar_path').eq('id', userId).maybeSingle();
      if (profileErr) {
        console.error('Error fetching profile for delete', profileErr);
      } else if (profile?.avatar_path) {
        try {
          const AVATAR_BUCKET = process.env.SUPABASE_AVATAR_BUCKET ?? 'avatars';
          let path = String(profile.avatar_path);
          if (path.startsWith('avatars/')) path = path.replace(/^avatars\//, '');
          await admin.storage.from(AVATAR_BUCKET).remove([path]);
        } catch (e) {
          console.warn('Failed to remove avatar from storage', e);
        }
      }
    } catch (e) {
      console.error('Profile/avatar cleanup error', e);
    }

    // Delete profile row
    try {
      // Log deletion activity before removing the profile (best-effort)
      try {
        const { error: logErr } = await admin.from('activities').insert([{ user_id: userId, title: 'Deleted account', description: 'User requested account deletion' }]);
        if (logErr) {
          const msg = String(logErr.message || '').toLowerCase();
          if (msg.includes('relation') && msg.includes('does not exist')) {
            console.warn('activities table missing; deletion activity not recorded');
          } else {
            console.warn('Failed to insert deletion activity', logErr);
          }
        }
      } catch (e) {
        console.warn('Failed to log account deletion activity', e);
      }

      const db = createAdminClient();
      const { error: delProfileErr } = await db.from('profiles').delete().eq('id', userId);
      if (delProfileErr) console.warn('profiles delete error', delProfileErr);
    } catch (e) {
      console.error('Error deleting profile row', e);
    }

    // Delete auth user via admin
    try {
      const res = await (admin.auth as any).admin.deleteUser(userId);
      if (res?.error) {
        console.error('Admin delete user error', res.error);
        return NextResponse.json({ error: res.error.message || 'failed to delete user' }, { status: 500 });
      }
    } catch (e) {
      console.error('Error deleting auth user', e);
      return isoError('Failed to delete auth user');
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error('Delete account route error', err);
    return isoError();
  }
}
