/* globals describe, it, expect, beforeEach */
import { vi as vitestMock } from 'vitest';

beforeEach(() => {
  vitestMock.resetModules();
});

describe('login attempt route', () => {
  it('returns 429 when IP rate limit is exceeded', async () => {
    const recordAttemptMock = vitestMock.fn().mockResolvedValue({ count: 201, remaining: 0, retryAfter: 3600 });
    const getAttemptStateMock = vitestMock.fn();
    vitestMock.doMock('@/lib/redis-rate-limit', () => ({
      getAttemptState: getAttemptStateMock,
      recordAttempt: recordAttemptMock,
    }));

    const { POST } = await import('@/app/api/auth/login-attempt/route');
    const req = {
      json: async () => ({ email: 'user@example.com' }),
      headers: { get: () => '1.2.3.4' },
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    expect(res.status).toBe(429);
    expect(await res.json()).toEqual({ error: 'Too many requests from this IP', retryAfter: 3600 });
    expect(recordAttemptMock).toHaveBeenCalledWith('ip', '1.2.3.4', 200, 3600000);
    expect(getAttemptStateMock).not.toHaveBeenCalled();
  });

  it('returns 429 when email rate limit is exceeded', async () => {
    const recordAttemptMock = vitestMock.fn().mockResolvedValue({ count: 1, remaining: 199, retryAfter: 0 });
    const getAttemptStateMock = vitestMock.fn().mockResolvedValue({ count: 5, remaining: 0, retryAfter: 900 });
    vitestMock.doMock('@/lib/redis-rate-limit', () => ({
      getAttemptState: getAttemptStateMock,
      recordAttempt: recordAttemptMock,
    }));

    const { POST } = await import('@/app/api/auth/login-attempt/route');
    const req = {
      json: async () => ({ email: 'user@example.com' }),
      headers: { get: () => '1.2.3.4' },
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    expect(res.status).toBe(429);
    expect(await res.json()).toEqual({ error: 'Too many login attempts for this account', retryAfter: 900 });
    expect(recordAttemptMock).toHaveBeenCalledTimes(1);
    expect(recordAttemptMock).toHaveBeenCalledWith('ip', '1.2.3.4', 200, 3600000);
    expect(getAttemptStateMock).toHaveBeenCalledWith('email', 'user@example.com', 5, 900000);
  });

  it('returns remaining quota when under limits', async () => {
    const recordAttemptMock = vitestMock.fn().mockResolvedValue({ count: 1, remaining: 199, retryAfter: 0 });
    const getAttemptStateMock = vitestMock.fn().mockResolvedValue({ count: 1, remaining: 4, retryAfter: 0 });
    vitestMock.doMock('@/lib/redis-rate-limit', () => ({
      getAttemptState: getAttemptStateMock,
      recordAttempt: recordAttemptMock,
    }));

    const { POST } = await import('@/app/api/auth/login-attempt/route');
    const req = {
      json: async () => ({ email: 'user@example.com' }),
      headers: { get: () => '1.2.3.4' },
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true, remaining: { ip: 199, email: 4 } });
    expect(recordAttemptMock).toHaveBeenCalledWith('ip', '1.2.3.4', 200, 3600000);
    expect(getAttemptStateMock).toHaveBeenCalledWith('email', 'user@example.com', 5, 900000);
  });

  it('records email quota only for failed login attempts', async () => {
    const recordAttemptMock = vitestMock.fn().mockResolvedValue({ count: 1, remaining: 4, retryAfter: 0 });
    const getAttemptStateMock = vitestMock.fn();
    vitestMock.doMock('@/lib/redis-rate-limit', () => ({
      getAttemptState: getAttemptStateMock,
      recordAttempt: recordAttemptMock,
    }));

    const { POST } = await import('@/app/api/auth/login-attempt/route');
    const req = {
      json: async () => ({ email: 'user@example.com', phase: 'failed' }),
      headers: { get: () => '1.2.3.4' },
      url: 'http://localhost',
    } as any;

    const res = await POST(req);
    expect(res.status).toBe(200);
    expect(await res.json()).toEqual({ ok: true, remaining: { email: 4 } });
    expect(recordAttemptMock).toHaveBeenCalledWith('email', 'user@example.com', 5, 900000);
    expect(getAttemptStateMock).not.toHaveBeenCalled();
  });
});
