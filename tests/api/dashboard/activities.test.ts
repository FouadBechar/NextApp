/* globals describe, it, expect, vi, beforeEach */
import { vi as vitestMock } from 'vitest';

beforeEach(() => {
  vitestMock.resetModules();
});

function createRequest(body: Record<string, unknown>) {
  return {
    json: async () => body,
    headers: {
      get: (name: string) => {
        if (name === 'user-agent') return 'Unit Test Browser';
        if (name === 'x-forwarded-for') return '127.0.0.1';
        return null;
      },
    },
    cookies: { getAll: () => [] },
    url: 'http://localhost',
  } as any;
}

describe('dashboard activities route', () => {
  it('sends and audits a security alert for security activity', async () => {
    const inserts: Array<{ table: string; value: unknown }> = [];
    const adminStub = {
      from: (table: string) => ({
        insert: async (value: unknown) => {
          inserts.push({ table, value });
          return { data: null, error: null };
        },
        select: function () {
          return this;
        },
        eq: function () {
          return this;
        },
        maybeSingle: async () => ({
          data: {
            email: 'user@example.com',
            full_name: 'User Example',
            username: 'user',
            preferences: {
              emailNotifications: true,
              securityAlerts: true,
              marketingEmails: true,
            },
          },
          error: null,
        }),
      }),
    };
    const sendEmailMock = vitestMock.fn().mockResolvedValue({ ok: true });

    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({
      verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'user@example.com' } }),
    }));
    vitestMock.doMock('@/lib/resend', () => ({ sendEmail: sendEmailMock }));

    const { POST } = await import('@/app/api/dashboard/activities/route');
    const res = await POST(
      createRequest({
        userId: 'u1',
        title: 'Enabled 2FA',
        description: 'User enabled two-factor authentication',
      })
    );

    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ success: true });
    expect(sendEmailMock).toHaveBeenCalledTimes(1);
    expect(sendEmailMock.mock.calls[0][0]).toMatchObject({
      to: 'user@example.com',
      subject: 'Security alert: Enabled 2FA',
    });
    expect(inserts.some((entry) => entry.table === 'notifications_sent')).toBe(true);
  });

  it('does not send an alert for non-security activity', async () => {
    const adminStub = {
      from: () => ({
        insert: async () => ({ data: null, error: null }),
      }),
    };
    const sendEmailMock = vitestMock.fn();

    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({
      verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'user@example.com' } }),
    }));
    vitestMock.doMock('@/lib/resend', () => ({ sendEmail: sendEmailMock }));

    const { POST } = await import('@/app/api/dashboard/activities/route');
    const res = await POST(
      createRequest({
        userId: 'u1',
        title: 'Updated profile',
        description: 'User updated profile information',
      })
    );

    expect(res.status).toBe(200);
    expect(sendEmailMock).not.toHaveBeenCalled();
  });
});
