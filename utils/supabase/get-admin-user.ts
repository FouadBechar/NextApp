import type { SupabaseClient } from '@supabase/supabase-js';

/**
 * Attempt to call the admin getUserById method across different client shapes.
 * Supabase's SDK evolved over time and different environments can expose the
 * admin APIs on slightly different nested objects (`auth.admin.*` vs `auth.*`).
 *
 * We centralize the `any` usage here for compatibility and to avoid repeated
 * casting across many server routes.
 */
export async function getAdminUserById(adminClient: SupabaseClient, id: string): Promise<unknown | null> {
  // Many SDK shapes are possible for the admin client; treat the auth property as unknown
  // and use runtime guards to call the available getUserById method when present.
  const adminRecord = adminClient as unknown as Record<string, unknown>;
  const authUnknown: unknown = adminRecord?.auth;

  function hasAdminGet(c: unknown): c is { admin: { getUserById: (id: string) => Promise<unknown> } } {
    if (typeof c !== 'object' || c === null || !('admin' in (c as Record<string, unknown>))) return false;
    const admin = (c as Record<string, unknown>)['admin'];
    if (typeof admin !== 'object' || admin === null) return false;
    if (!('getUserById' in (admin as Record<string, unknown>))) return false;
    return typeof (admin as Record<string, unknown>)['getUserById'] === 'function';
  }
  function hasGet(c: unknown): c is { getUserById: (id: string) => Promise<unknown> } {
    if (typeof c !== 'object' || c === null) return false;
    if (!('getUserById' in (c as Record<string, unknown>))) return false;
    return typeof (c as Record<string, unknown>)['getUserById'] === 'function';
  }

  // Try top-level auth first
  try {
    if (hasAdminGet(authUnknown)) {
      return await authUnknown.admin.getUserById(id);
    }
    if (hasGet(authUnknown)) {
      return await authUnknown.getUserById(id);
    }
  } catch (e) {
    // ignore and continue to fallback attempts below
  }

  // Fallback: some environments might put auth on a nested runtime object — try both shapes again
  const maybeAuth = adminRecord?.auth;
  try {
    if (hasAdminGet(maybeAuth)) return await maybeAuth.admin.getUserById(id);
    if (hasGet(maybeAuth)) return await maybeAuth.getUserById(id);
  } catch (e) {
    // ignore
  }
  return null;
}

export default getAdminUserById;
