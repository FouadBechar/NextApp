import { NextRequest, NextResponse } from 'next/server';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';
import parseJsonOrEmpty from '@/utils/parse-request';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

// Using shared `verifyUserFromRequest` helper

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
      // call the admin delete user API — new SDK exposes `admin.deleteUser(userId)`
      const adminRes = await admin.auth.admin.deleteUser(userId);
      if (adminRes?.error) {
        console.error('Admin delete user error', adminRes.error);
        return NextResponse.json({ error: adminRes.error.message || 'failed to delete user' }, { status: 500 });
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
