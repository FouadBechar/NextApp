/* globals describe, it, expect */
import { getAdminUserById } from '@/utils/supabase/get-admin-user';

describe('getAdminUserById', () => {
  it('calls auth.admin.getUserById if available', async () => {
    const sentinel = { data: { user: { id: 'u1' } } };
    const adminClient = {
      auth: {
        admin: { getUserById: async (id: string) => sentinel },
      },
    } as unknown as any;
    const res = await getAdminUserById(adminClient, 'u1');
    expect(res).toBe(sentinel);
  });

  it('falls back to auth.getUserById when admin is not present', async () => {
    const sentinel = { user: { id: 'u2' } };
    const adminClient = {
      auth: {
        getUserById: async (id: string) => sentinel,
      },
    } as unknown as any;
    const res = await getAdminUserById(adminClient, 'u2');
    expect(res).toBe(sentinel);
  });
});
