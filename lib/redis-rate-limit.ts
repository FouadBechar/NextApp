import Redis from 'ioredis';

export type RateLimitResult = {
  count: number;
  remaining: number;
  retryAfter: number;
};

const EMAIL_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const IP_WINDOW_MS = 60 * 60 * 1000; // 1 hour

const emailAttempts = new Map<string, { count: number; windowStart: number }>();
const ipAttempts = new Map<string, { count: number; windowStart: number }>();

const redisUrl = process.env.REDIS_URL;
let redisClient: Redis | null = null;
let redisReady = false;

function now() {
  return Date.now();
}

function getRedisClient(): Redis | null {
  if (!redisUrl) return null;
  if (redisClient) return redisClient;

  redisClient = new Redis(redisUrl, {
    lazyConnect: true,
    maxRetriesPerRequest: 0,
    connectTimeout: 2000,
  });

  redisClient.on('ready', () => {
    redisReady = true;
  });

  redisClient.on('error', () => {
    redisReady = false;
  });

  redisClient.on('end', () => {
    redisReady = false;
  });

  return redisClient;
}

async function getReadyRedisClient(): Promise<Redis | null> {
  const client = getRedisClient();
  if (!client) return null;
  if (redisReady && client.status === 'ready') return client;

  try {
    await client.connect();
    redisReady = client.status === 'ready';
    return redisReady ? client : null;
  } catch (err) {
    redisReady = false;
    return null;
  }
}

async function tryRedisRateLimit(key: string, windowMs: number, max: number): Promise<RateLimitResult | null> {
  const client = await getReadyRedisClient();
  if (!client) return null;

  try {
    const count = await client.incr(key);
    if (count === 1) {
      await client.pexpire(key, windowMs);
    }

    let ttl = await client.pttl(key);
    if (ttl < 0) ttl = windowMs;

    return {
      count,
      remaining: Math.max(0, max - count),
      retryAfter: count > max ? Math.ceil(ttl / 1000) : 0,
    };
  } catch (error) {
    console.error('Redis rate limiter error', error);
    return null;
  }
}

async function tryRedisRateLimitState(key: string, windowMs: number, max: number): Promise<RateLimitResult | null> {
  const client = await getReadyRedisClient();
  if (!client) return null;

  try {
    const rawCount = await client.get(key);
    const count = rawCount ? Number(rawCount) : 0;
    let ttl = await client.pttl(key);
    if (ttl < 0) ttl = count > 0 ? windowMs : 0;

    return {
      count,
      remaining: Math.max(0, max - count),
      retryAfter: count >= max && ttl > 0 ? Math.ceil(ttl / 1000) : 0,
    };
  } catch (error) {
    console.error('Redis rate limiter state error', error);
    return null;
  }
}

function incrMap(map: Map<string, { count: number; windowStart: number }>, key: string, windowMs: number) {
  const timestamp = now();
  const existing = map.get(key);
  if (!existing || existing.windowStart + windowMs <= timestamp) {
    const entry = { count: 1, windowStart: timestamp };
    map.set(key, entry);
    return entry;
  }

  existing.count += 1;
  map.set(key, existing);
  return existing;
}

export async function recordAttempt(prefix: 'ip' | 'email', identifier: string, max: number, windowMs: number): Promise<RateLimitResult> {
  const key = `rate:${prefix}:${identifier}`;
  const redisResult = await tryRedisRateLimit(key, windowMs, max);

  if (redisResult) {
    return redisResult;
  }

  const map = prefix === 'ip' ? ipAttempts : emailAttempts;
  const entry = incrMap(map, identifier, windowMs);
  const elapsed = now() - entry.windowStart;
  const retryAfter = entry.count > max ? Math.ceil((windowMs - elapsed) / 1000) : 0;

  return {
    count: entry.count,
    remaining: Math.max(0, max - entry.count),
    retryAfter,
  };
}

export async function getAttemptState(prefix: 'ip' | 'email', identifier: string, max: number, windowMs: number): Promise<RateLimitResult> {
  const key = `rate:${prefix}:${identifier}`;
  const redisResult = await tryRedisRateLimitState(key, windowMs, max);

  if (redisResult) {
    return redisResult;
  }

  const map = prefix === 'ip' ? ipAttempts : emailAttempts;
  const entry = map.get(identifier);

  if (!entry) {
    return { count: 0, remaining: max, retryAfter: 0 };
  }

  const elapsed = now() - entry.windowStart;
  if (entry.windowStart + windowMs <= now()) {
    map.delete(identifier);
    return { count: 0, remaining: max, retryAfter: 0 };
  }

  return {
    count: entry.count,
    remaining: Math.max(0, max - entry.count),
    retryAfter: entry.count >= max ? Math.ceil((windowMs - elapsed) / 1000) : 0,
  };
}

export function resetRateLimiterState() {
  emailAttempts.clear();
  ipAttempts.clear();
}
