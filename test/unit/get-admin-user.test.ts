import { describe, it, expect, vi } from 'vitest';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';

describe('getAdminUserById', () => {
  it('calls auth.admin.getUserById when available', async () => {
    const user = { id: 'u1' };
    const adminClient = { auth: { admin: { getUserById: vi.fn().mockResolvedValue({ data: { user } }) } } } as unknown as any;
    const res = await getAdminUserById(adminClient, 'u1');
    expect(res).toEqual({ data: { user } });
    expect(adminClient.auth.admin.getUserById).toHaveBeenCalledWith('u1');
  });

  it('calls auth.getUserById when admin shape is not available', async () => {
    const user = { id: 'u2' };
    const adminClient = { auth: { getUserById: vi.fn().mockResolvedValue({ user }) } } as unknown as any;
    const res = await getAdminUserById(adminClient, 'u2');
    expect(res).toEqual({ user });
  });

  it('returns null when no supported shape is present', async () => {
    const adminClient = { foo: 'bar' } as unknown as any;
    const res = await getAdminUserById(adminClient, 'u3');
    expect(res).toBeNull();
  });
});
