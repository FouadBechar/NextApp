/* globals describe, it, expect, vi, beforeEach */

beforeEach(() => {
  vi.resetModules();
});

describe('verifyUserFromRequest', () => {
  it('returns user via cookie when createServerClient returns a user', async () => {
    vi.doMock('@supabase/ssr', () => ({ createServerClient: () => ({ auth: { getUser: async () => ({ data: { user: { id: 'u_cookie' } } }) } }) }));
    vi.doMock('@/utils/jwt', () => ({ getUserIdFromToken: () => 'u_token' }));
    vi.doMock('@/utils/supabase/get-admin-user', () => ({ getAdminUserById: () => ({ user: { id: 'u_token' } }) }));
    vi.doMock('@/utils/supabase/extract-user', () => ({ extractUserFromAdminResponse: (x: unknown) => ({ id: 'u_token' }) }));
    vi.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => ({}) }));

    const { verifyUserFromRequest } = await import('@/utils/supabase/verify-user');
    const req = { headers: { get: (k: string) => null }, cookies: { getAll: () => [] }, url: 'http://localhost' } as any;
    const res = await verifyUserFromRequest(req);
    expect(res.ok).toBe(true);
    if (res.ok) expect(res.user.id).toBe('u_cookie');
  });

  it('returns user via token when cookie is absent but Authorization header present', async () => {
    vi.doMock('@supabase/ssr', () => ({ createServerClient: () => ({ auth: { getUser: async () => ({ data: { user: null } }) } }) }));
    vi.doMock('@/utils/jwt', () => ({ getUserIdFromToken: () => 'u_token' }));
    vi.doMock('@/utils/supabase/get-admin-user', () => ({ getAdminUserById: () => ({ user: { id: 'u_token' } }) }));
    vi.doMock('@/utils/supabase/extract-user', () => ({ extractUserFromAdminResponse: (x: unknown) => ({ id: 'u_token' }) }));
    vi.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => ({}) }));

    const { verifyUserFromRequest } = await import('@/utils/supabase/verify-user');
    const req = { headers: { get: (k: string) => 'Bearer sometoken' }, cookies: { getAll: () => [] }, url: 'http://localhost' } as any;
    const res = await verifyUserFromRequest(req);
    expect(res.ok).toBe(true);
    if (res.ok) expect(res.user.id).toBe('u_token');
  });

  it('returns a bad result if Authorization header missing', async () => {
    vi.doMock('@supabase/ssr', () => ({ createServerClient: () => ({ auth: { getUser: async () => ({ data: { user: null } }) } }) }));
    vi.doMock('@/utils/jwt', () => ({ getUserIdFromToken: () => null }));
    vi.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => ({}) }));

    const { verifyUserFromRequest } = await import('@/utils/supabase/verify-user');
    const req = { headers: { get: (k: string) => null }, cookies: { getAll: () => [] }, url: 'http://localhost' } as any;
    const res = await verifyUserFromRequest(req);
    expect(res.ok).toBe(false);
    if (!res.ok) expect(res.status).toBe(401);
  });
});
// The tests below use `vi.doMock` and dynamic imports to isolate module dependencies
// per test. We avoid `vi.mocked` style reassignments and rely on per-test mocks.
