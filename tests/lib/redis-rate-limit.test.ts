/* globals describe, it, expect, beforeEach */
import { recordAttempt, resetRateLimiterState } from '@/lib/redis-rate-limit';

describe('redis rate limiter fallback', () => {
  beforeEach(() => {
    resetRateLimiterState();
  });

  it('uses fallback counters when Redis is unavailable', async () => {
    const first = await recordAttempt('ip', '127.0.0.1', 200, 1000);
    expect(first.count).toBe(1);
    expect(first.remaining).toBe(199);
    expect(first.retryAfter).toBe(0);

    const second = await recordAttempt('ip', '127.0.0.1', 200, 1000);
    expect(second.count).toBe(2);
    expect(second.remaining).toBe(198);
    expect(second.retryAfter).toBe(0);
  });

  it('tracks separate email and IP keys independently', async () => {
    const emailResult = await recordAttempt('email', 'user@example.com', 5, 1000);
    const ipResult = await recordAttempt('ip', '127.0.0.1', 200, 1000);

    expect(emailResult.count).toBe(1);
    expect(emailResult.remaining).toBe(4);
    expect(ipResult.count).toBe(1);
    expect(ipResult.remaining).toBe(199);
  });
});
