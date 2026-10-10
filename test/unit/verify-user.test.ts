import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock the modules imported by verify-user so we can control behavior
vi.mock('@supabase/ssr', () => ({
  createServerClient: vi.fn(),
}));
vi.mock('@/utils/supabase/client', () => ({
  createAdminClient: vi.fn(),
}));
vi.mock('@/utils/jwt', () => ({
  getUserIdFromToken: vi.fn(),
}));
vi.mock('@/utils/supabase/get-admin-user', () => ({
  getAdminUserById: vi.fn(),
}));

import { verifyUserFromRequest } from '@/utils/supabase/verify-user';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';

describe('verifyUserFromRequest', () => {
  beforeEach(() => {
    vi.resetAllMocks();
  });

  it('returns ok via cookie when server client auth returns a user', async () => {
    // Mock createServerClient to return an object with auth.getUser() resolved
    (createServerClient as unknown as any).mockImplementation(() => ({
      auth: {
        getUser: async () => ({ data: { user: { id: 'cookieUser' } } }),
      },
    }));

    const req = { cookies: { getAll: () => [] }, headers: { get: () => null } } as unknown as any;
    const res = await verifyUserFromRequest(req);
    expect(res.ok).toBe(true);
    if (res.ok) expect(res.user.id).toBe('cookieUser');
  });

  it('falls back to token and admin client and returns ok via token', async () => {
    (createServerClient as unknown as any).mockImplementation(() => ({
      auth: {
        getUser: async () => ({ data: { user: null } }),
      },
    }));
    (getUserIdFromToken as unknown as any).mockReturnValue('u2');
    (getAdminUserById as unknown as any).mockResolvedValue({ data: { user: { id: 'u2' } } });
    (createAdminClient as unknown as any).mockReturnValue({});

    const req = { cookies: { getAll: () => [] }, headers: { get: (k: string) => (k === 'authorization' ? 'Bearer abc' : null) } } as unknown as any;
    const res = await verifyUserFromRequest(req as any);
    expect(res.ok).toBe(true);
    if (res.ok) expect(res.user.id).toBe('u2');
  });

  it('returns invalid token when header is missing', async () => {
    (createServerClient as unknown as any).mockImplementation(() => ({
      auth: { getUser: async () => ({ data: { user: null } }) },
    }));
    const req = { cookies: { getAll: () => [] }, headers: { get: () => null } } as unknown as any;
    const res = await verifyUserFromRequest(req);
    expect(res.ok).toBe(false);
    if (!res.ok) expect(res.status).toBe(401);
  });
});
