/* globals describe, it, expect, vi, beforeEach */
import { vi as vitestMock } from 'vitest';

beforeEach(() => {
  vitestMock.resetModules();
});

describe('dashboard export route', () => {
  it('sends an email with the export when sendEmail=true', async () => {
    const activities = [{ id: 'a1', title: 't', description: 'd', metadata: null, created_at: new Date().toISOString() }];
    const profile = { id: 'u1', email: 'u1@example.com', full_name: 'User', username: 'u1' };

    const adminStub = {
      from: (table: string) => {
        const query: any = {
          select: function () { return this; },
          eq: function () { return this; },
          order: function () { return this; },
          limit: async function () { return { data: table === 'profiles' ? profile : activities, error: null }; },
          maybeSingle: async function () { return { data: table === 'profiles' ? profile : null, error: null }; },
        };
        return query;
      },
      storage: {
        from: (bucket: string) => ({
          upload: async (path: string, data: any, opts: any) => ({ data: null, error: null }),
          createSignedUrl: async (path: string, ttl: number) => ({ data: { signedUrl: 'https://signed.example/export.json' }, error: null }),
        }),
      },
    } as any;

    const sendEmailMock = vitestMock.fn().mockResolvedValue({ ok: true });
    const getResendMock = vitestMock.fn().mockReturnValue({});

    vitestMock.doMock('@/lib/resend', () => ({ getResend: getResendMock, sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({ verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'u1@example.com' } }) }));

    const { POST } = await import('@/app/api/dashboard/export/route');
    const req = {
      json: async () => ({ userId: 'u1', sendEmail: true }),
      headers: { get: () => null },
      cookies: { getAll: () => [] },
      url: 'http://localhost',
    } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(body.emailSent).toBe(true);
    // sendEmail called once
    expect(sendEmailMock).toHaveBeenCalledTimes(1);
    const call = sendEmailMock.mock.calls[0][0];
    expect(call.to).toBe('u1@example.com');
    // attachments include a JSON file
    expect(call.attachments && call.attachments[0] && call.attachments[0].filename.endsWith('.json')).toBe(true);
  }, 15000);

  it('returns payload and does not send email when sendEmail=false', async () => {
    const activities = [{ id: 'a1', title: 't', description: 'd', metadata: null, created_at: new Date().toISOString() }];
    const profile = { id: 'u1', email: 'u1@example.com', full_name: 'User', username: 'u1' };
    const adminStub = { from: (table: string) => ({
      select: function () { return this; },
      eq: function () { return this; },
      order: function () { return this; },
      limit: async function () { return { data: table === 'profiles' ? profile : activities, error: null }; },
      maybeSingle: async function () { return { data: table === 'profiles' ? profile : null, error: null }; },
    }) } as any;
    const sendEmailMock = vitestMock.fn();
    vitestMock.doMock('@/lib/resend', () => ({ getResend: () => ({}), sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({ verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'u1@example.com' } }) }));
    const { POST } = await import('@/app/api/dashboard/export/route');
    const req = { json: async () => ({ userId: 'u1' }), headers: { get: () => null }, cookies: { getAll: () => [] }, url: 'http://localhost' } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(body.success).toBe(true);
    expect(body.export).toBeTruthy();
    expect(sendEmailMock).toHaveBeenCalledTimes(0);
  });

  it('uploads large export and sends a signed link when over email limit', async () => {
    process.env.EXPORT_EMAIL_MAX_BYTES = '100'; // force small limit so payload is considered large
    const activities = [{ id: 'a1', title: 't', description: 'd', metadata: null, created_at: new Date().toISOString() }];
    const profile = { id: 'u1', email: 'u1@example.com', full_name: 'User', username: 'u1' };
    const adminStub = {
      from: (table: string) => ({
        select: function () { return this; },
        eq: function () { return this; },
        order: function () { return this; },
        limit: async function () { return { data: table === 'profiles' ? profile : activities, error: null }; },
        maybeSingle: async function () { return { data: table === 'profiles' ? profile : null, error: null }; },
      }),
      storage: {
        from: (bucket: string) => ({
          upload: async (path: string, data: any, opts: any) => ({ data: null, error: null }),
          createSignedUrl: async (path: string, ttl: number) => ({ data: { signedUrl: 'https://signed.example/large-export.json' }, error: null }),
        }),
      },
    } as any;

    const sendEmailMock = vitestMock.fn().mockResolvedValue({ ok: true });
    vitestMock.doMock('@/lib/resend', () => ({ getResend: () => ({}), sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({ verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'u1@example.com' } }) }));

    const { POST } = await import('@/app/api/dashboard/export/route');
    const req = { json: async () => ({ userId: 'u1', sendEmail: true }), headers: { get: () => null }, cookies: { getAll: () => [] }, url: 'http://localhost' } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(body.emailSent).toBe(true);
    expect(body.signedUrl).toBeDefined();
    expect(sendEmailMock).toHaveBeenCalledTimes(1);
  });
});
