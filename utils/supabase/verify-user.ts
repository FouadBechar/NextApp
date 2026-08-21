import type { User } from '@supabase/supabase-js';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from './get-admin-user';
import type { NextRequest } from 'next/server';

export type VerifiedUserOk = { ok: true; user: User; via: 'cookie' | 'token' };
export type VerifiedUserBad = { ok: false; status?: number; reason?: string };
export type VerifiedUserResult = VerifiedUserOk | VerifiedUserBad;

/** Verify a NextRequest and return a discriminated union for type-safe handling.
 *  This prefers cookie-based verification (server-side) and falls back to
 *  Authorization header Bearer token verification (admin client).
 */
export async function verifyUserFromRequest(req: NextRequest, expectedUserId?: string): Promise<VerifiedUserResult> {
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

    const { data: { user } } = await serverSupabase.auth.getUser();
    if (user && (!expectedUserId || user.id === expectedUserId)) return { ok: true, user, via: 'cookie' };
  } catch (e) {
    // ignore & fallback to token
  }

  const authHeader = req.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) return { ok: false, status: 401, reason: 'missing authorization' };
  const token = authHeader.split(' ')[1];
  try {
    const admin = createAdminClient();
    const userIdFromToken = getUserIdFromToken(token);
    if (!userIdFromToken) return { ok: false, status: 401, reason: 'invalid token' };
    const fetchedUserRes = await getAdminUserById(admin, userIdFromToken);
    const fetchedUser = extractUserFromAdminResponse(fetchedUserRes);
    if (!fetchedUser) return { ok: false, status: 401, reason: 'invalid token' };
    if (expectedUserId && fetchedUser.id !== expectedUserId) return { ok: false, status: 403, reason: 'forbidden' };
    return { ok: true, user: fetchedUser, via: 'token' };
  } catch (e) {
    return { ok: false, status: 401, reason: 'invalid token' };
  }
}

export default verifyUserFromRequest;
