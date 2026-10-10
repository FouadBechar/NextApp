import { NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';

type VerifyRequest = {
  token?: string | null;
};

async function auditRecaptchaFailure(request: Request, opts: { action?: string; reason: string; score?: number | null; token?: string | null }) {
  try {
    const admin = createAdminClient();
    const { action, reason, score, token } = opts;
    const userAgent = request.headers.get('user-agent') || null;
    const xff = request.headers.get('x-forwarded-for') || request.headers.get('x-real-ip') || null;
    let userId: string | null = null;

    // Try to resolve user id from bearer token if available
    try {
      const authHeader = request.headers.get('authorization');
      if (authHeader && authHeader.startsWith('Bearer ')) {
        const bearer = authHeader.split(' ')[1];
        const userIdFromToken = getUserIdFromToken(bearer);
        if (userIdFromToken) {
          const res = await getAdminUserById(admin, userIdFromToken);
          const fetchedUser = extractUserFromAdminResponse(res);
          if (fetchedUser) userId = fetchedUser.id;
        }
      }
    } catch (e) {
      // ignore
    }

    const insertRow: Record<string, any> = {
      title: 'reCAPTCHA verification failure',
      description: `${action || 'recaptcha'} failure: ${String(reason).slice(0, 200)}`,
      metadata: {
        action: action || null,
        reason: String(reason),
        score: score ?? null,
        token_stub: token ? String(token).slice(0, 10) : null,
      },
    };
    if (userAgent) insertRow.user_agent = String(userAgent).slice(0, 2000);
    if (xff) insertRow.ip = String(xff).split(',')[0].trim();
    if (userId) insertRow.user_id = userId;

    await admin.from('activities').insert([insertRow]);
  } catch (e) {
    // If logging fails for any reason — do not interrupt the recaptcha flow
    // eslint-disable-next-line no-console
    console.warn('Failed to log reCAPTCHA failure activity', e);
  }
}

export async function POST(request: Request) {
  try {
    const body: VerifyRequest & { action?: string } = await request.json();
    const token = body?.token;
    const action = body?.action;
    if (!token) {
      // Audit missing token attempt
      await auditRecaptchaFailure(request, { action: action, reason: 'Missing token', score: null, token: null });
      return NextResponse.json({ success: false, message: 'Missing token' }, { status: 400 });
    }

    const secret = process.env.RECAPTCHA_SECRET;
    if (!secret) {
      // Audit missing secret (misconfiguration)
      await auditRecaptchaFailure(request, { action: action, reason: 'reCAPTCHA not configured', score: null, token });
      return NextResponse.json({ success: false, message: 'reCAPTCHA not configured' }, { status: 500 });
    }

    const params = new URLSearchParams();
    params.append('secret', secret);
    params.append('response', token);

    const res = await fetch('https://www.google.com/recaptcha/api/siteverify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: params.toString(),
    });

    const json = await res.json();
    // reCAPTCHA v3 returns a score (0.0 - 1.0). Choose threshold (e.g., 0.5)
    const score = typeof json.score === 'number' ? json.score : null;
    const success = Boolean(json.success);

    const threshold = Number(process.env.RECAPTCHA_THRESHOLD ?? 0.5);
    if (!success) {
      await auditRecaptchaFailure(request, { action: action, reason: 'reCAPTCHA verification failed', score, token });
      return NextResponse.json({ success: false, message: 'reCAPTCHA verification failed' }, { status: 403 });
    }

    if (score !== null && score < threshold) {
      await auditRecaptchaFailure(request, { action: action, reason: 'Low reCAPTCHA score', score, token });
      return NextResponse.json({ success: false, message: 'Low reCAPTCHA score' }, { status: 403 });
    }

    return NextResponse.json({ success: true, score });
  } catch (err) {
    return NextResponse.json({ success: false, message: (err as Error).message }, { status: 500 });
  }
}
