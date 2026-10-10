/* globals describe, it, expect, vi, beforeEach */
import { vi as vitestMock } from 'vitest';

beforeEach(() => {
  vitestMock.resetModules();
  // Clear relevant env values between tests
  delete process.env.ADMIN_BROADCAST_TOKEN;
  delete process.env.ADMIN_BROADCAST_EMAILS;
  delete process.env.BROADCAST_SENDER_EMAIL;
});

describe('admin broadcast route', () => {
  it('dryRun with admin token previews recipients and does not call sendEmail, inserts audit row', async () => { /* increased timeout for CI flakiness */
    const profiles = [
      { id: '1', email: 'a@example.com', preferences: { emailNotifications: true } },
      { id: '2', email: 'b@example.com', preferences: { emailNotifications: false } },
      { id: '3', email: 'c@example.com', preferences: JSON.stringify({ emailNotifications: true }) },
    ];

    let insertedPayload: any = null;
    const adminStub = {
      from: (table: string) => ({
        select: async () => ({ data: profiles, error: null }),
        insert: async (payload: any) => { insertedPayload = payload; return { data: payload }; },
      }),
    };

    const sendEmailMock = vitestMock.fn().mockResolvedValue({ ok: true });
    const getResendMock = vitestMock.fn().mockReturnValue({});

    vitestMock.doMock('@/lib/resend', () => ({ getResend: getResendMock, sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    // Do not mock verify-user; token auth will be used

    process.env.ADMIN_BROADCAST_TOKEN = 'admintoken';
    process.env.BROADCAST_SENDER_EMAIL = 'ci@company.com';

    const { default: POST } = await import('@/app/api/admin/broadcast/route');

    const req = {
      headers: { get: (k: string) => 'Bearer admintoken' },
      cookies: { getAll: () => [] },
      json: async () => ({ subject: 'hello', text: 'body text', dryRun: true }),
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    const body = await res.json();
    expect(body.sent).toBe(2); // two recipients (a and c)
    // sendEmail mocked should not be called due to dryRun
    expect(sendEmailMock).toHaveBeenCalledTimes(0);
    // audit inserted and recorded as dry run
    expect(insertedPayload).not.toBeNull();
    expect(insertedPayload.dry_run).toBe(true);
    expect(insertedPayload.recipients_count).toBe(2);
    expect(insertedPayload.sent_by).toBe('ci@company.com');
  }, 10000);

  it('token auth routes invokes sendEmail and inserts audit', async () => {
    const profiles = [
      { id: '1', email: 'a@example.com', preferences: { emailNotifications: true } },
    ];
    let insertedPayload: any = null;
    const adminStub = {
      from: (table: string) => ({
        select: async () => ({ data: profiles, error: null }),
        insert: async (payload: any) => { insertedPayload = payload; return { data: payload }; },
      }),
    };
    const sendEmailMock = vitestMock.fn().mockResolvedValue({ ok: true });
    const getResendMock = vitestMock.fn().mockReturnValue({});

    vitestMock.doMock('@/lib/resend', () => ({ getResend: getResendMock, sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));

    process.env.ADMIN_BROADCAST_TOKEN = 'admintoken';
    process.env.BROADCAST_SENDER_EMAIL = 'ci@company.com';

    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = {
      headers: { get: (k: string) => 'Bearer admintoken' },
      cookies: { getAll: () => [] },
      json: async () => ({ subject: 'hello', text: 'body text' }),
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    const body = await res.json();
    expect(body.sent).toBe(1);
    expect(sendEmailMock).toHaveBeenCalledTimes(1);
    expect(insertedPayload).not.toBeNull();
    expect(insertedPayload.dry_run).toBe(false);
    expect(insertedPayload.sent_by).toBe('ci@company.com');
  });

  it('verifyUserFromRequest fallback works and uses allowed admin email', async () => {
    const profiles = [
      { id: '1', email: 'a@example.com', preferences: { emailNotifications: true } },
    ];
    let insertedPayload: any = null;
    const adminStub = {
      from: (table: string) => ({
        select: async () => ({ data: profiles, error: null }),
        insert: async (payload: any) => { insertedPayload = payload; return { data: payload }; },
      }),
    };
    const sendEmailMock = vitestMock.fn().mockResolvedValue({ ok: true });
    const getResendMock = vitestMock.fn().mockReturnValue({});
    vitestMock.doMock('@/lib/resend', () => ({ getResend: getResendMock, sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({ verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'admin@example.com' } }) }));

    process.env.ADMIN_BROADCAST_EMAILS = 'admin@example.com';

    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = {
      headers: { get: (k: string) => null },
      cookies: { getAll: () => [] },
      json: async () => ({ subject: 'hi', text: 'body' }),
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    const body = await res.json();
    expect(body.sent).toBe(1);
    expect(sendEmailMock).toHaveBeenCalledTimes(1);
    expect(insertedPayload.sent_by).toBe('admin@example.com');
  });

  it('returns 400 if required fields are missing', async () => {
    const sendEmailMock = vitestMock.fn();
    const getResendMock = vitestMock.fn().mockReturnValue({});
    const adminStub = { from: (_: string) => ({ select: async () => ({ data: [], error: null }) }) };
    vitestMock.doMock('@/lib/resend', () => ({ getResend: getResendMock, sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));

    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = { headers: { get: () => 'Bearer admintoken' }, cookies: { getAll: () => [] }, json: async () => ({}) } as any;
    process.env.ADMIN_BROADCAST_TOKEN = 'admintoken';
    const res = await POST(req);
    const body = await res.json();
    expect(res.status).toBe(400);
    expect(body.error).toBeDefined();
  });

  it('forbidden when verified user not in allowed list', async () => {
    const profiles = [{ id: '1', email: 'a@example.com', preferences: { emailNotifications: true } }];
    const adminStub = { from: (t: string) => ({ select: async () => ({ data: profiles, error: null }) }) };
    const sendEmailMock = vitestMock.fn();
    vitestMock.doMock('@/lib/resend', () => ({ getResend: () => ({}), sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    vitestMock.doMock('@/utils/supabase/verify-user', () => ({ verifyUserFromRequest: async () => ({ ok: true, user: { id: 'u1', email: 'not-admin@example.com' } }) }));

    process.env.ADMIN_BROADCAST_EMAILS = 'admin@example.com';
    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = { headers: { get: () => null }, cookies: { getAll: () => [] }, json: async () => ({ subject: 'x', text: 'y' }) } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(res.status).toBe(403);
    expect(body.error).toBe('forbidden');
  });

  it('returns 500 when Resend API key missing', async () => {
    const profiles = [{ id: '1', email: 'a@example.com', preferences: { emailNotifications: true } }];
    let insertedPayload: any = null;
    const adminStub = { from: (table: string) => ({ select: async () => ({ data: profiles, error: null }), insert: async (p: any) => (insertedPayload = p) }) };
    // getResend returns null to simulate missing key
    const sendEmailMock = vitestMock.fn();
    const getResendMock = vitestMock.fn().mockReturnValue(null);
    vitestMock.doMock('@/lib/resend', () => ({ getResend: getResendMock, sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    process.env.ADMIN_BROADCAST_TOKEN = 'admintoken';

    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = { headers: { get: () => 'Bearer admintoken' }, cookies: { getAll: () => [] }, json: async () => ({ subject: 'x', text: 'y' }) } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(res.status).toBe(500);
    expect(body.error).toBe('RESEND_API_KEY missing');
  });

  it('returns 500 on DB select error', async () => {
    const adminStub = { from: (table: string) => ({ select: async () => ({ data: null, error: { message: 'nope' } }) }) };
    const sendEmailMock = vitestMock.fn();
    vitestMock.doMock('@/lib/resend', () => ({ getResend: () => ({}), sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    process.env.ADMIN_BROADCAST_TOKEN = 'admintoken';
    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = { headers: { get: () => 'Bearer admintoken' }, cookies: { getAll: () => [] }, json: async () => ({ subject: 'x', text: 'y' }) } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(res.status).toBe(500);
  });

  it('counts failed sends when sendEmail returns not ok', async () => {
    const profiles = [
      { id: '1', email: 'a@example.com', preferences: { emailNotifications: true } },
      { id: '2', email: 'b@example.com', preferences: { emailNotifications: true } },
    ];
    let insertedPayload: any = null;
    const adminStub = { from: (table: string) => ({ select: async () => ({ data: profiles, error: null }), insert: async (p: any) => (insertedPayload = p) }) };
    // first send ok, second fails
    const sendEmailMock = vitestMock.fn().mockResolvedValueOnce({ ok: true }).mockResolvedValueOnce({ ok: false, error: 'oops' });
    vitestMock.doMock('@/lib/resend', () => ({ getResend: () => ({}), sendEmail: sendEmailMock }));
    vitestMock.doMock('@/utils/supabase/client', () => ({ createAdminClient: () => adminStub }));
    process.env.ADMIN_BROADCAST_TOKEN = 'admintoken';
    const { default: POST } = await import('@/app/api/admin/broadcast/route');
    const req = { headers: { get: () => 'Bearer admintoken' }, cookies: { getAll: () => [] }, json: async () => ({ subject: 'x', text: 'y' }) } as any;
    const res = await POST(req);
    const body = await res.json();
    expect(body.sent).toBe(1); // one succeeded
    expect(body.failed).toBe(1);
    expect(insertedPayload.sent_count).toBe(1);
    expect(insertedPayload.failed_count).toBe(1);
  });
});
