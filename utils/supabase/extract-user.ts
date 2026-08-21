import type { User } from "@supabase/supabase-js";

// Small helper to extract a User from various Supabase Admin auth responses.
// Supabase's JS client sometimes returns different shapes depending on version,
// so this normalizes the check. We avoid broad 'any' use by inspecting known
// shapes using the 'in' operator and local narrowing.
type ResWithDataUser = { data?: { user?: User } };
type ResWithUser = { user?: User };

export function extractUserFromAdminResponse(res: unknown): User | null {
  if (!res || typeof res !== 'object') return null;

  // Check shape: { data: { user } }
  if ('data' in res) {
    const r = res as ResWithDataUser;
    if (r.data && typeof r.data === 'object' && 'user' in r.data) {
      const maybeUser = (r.data as { user?: unknown }).user;
      if (maybeUser && typeof maybeUser === 'object') return maybeUser as User;
      return null;
    }
  }

  // Check shape: { user }
  if ('user' in res && typeof (res as ResWithUser).user === 'object') {
    return (res as ResWithUser).user ?? null;
  }

  return null;
}

export default extractUserFromAdminResponse;
