import { NextRequest, NextResponse } from 'next/server';
import { authenticator } from 'otplib';
import QRCode from 'qrcode';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

async function verifyUserFromRequest(req: NextRequest, expectedUserId?: string) {
  try {
    const serverSupabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return req.cookies.getAll();
          },
          setAll() {},
        },
      }
    );

    const {
      data: { user },
    } = await serverSupabase.auth.getUser();

    if (user && (!expectedUserId || user.id === expectedUserId)) {
      return { ok: true, user, via: 'cookie' };
    }
  } catch (e) {
    // ignore
  }

  const authHeader = req.headers.get('authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { ok: false, status: 401, reason: 'missing authorization' };
  }
  const token = authHeader.split(' ')[1];
  try {
    const admin = createAdminClient();
    const userRes = await (admin.auth as any).getUser(token);
    const fetchedUser = userRes?.data?.user;
    if (!fetchedUser) return { ok: false, status: 401, reason: 'invalid token' };
    if (expectedUserId && fetchedUser.id !== expectedUserId) return { ok: false, status: 403, reason: 'forbidden' };
    return { ok: true, user: fetchedUser, via: 'token' };
  } catch (e) {
    return { ok: false, status: 401, reason: 'invalid token' };
  }
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for 2fa setup', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const email = verified.user.email || 'user@example.com';

    // Generate secret and otpauth URL
    const secret = authenticator.generateSecret();
    const serviceName = process.env.NEXT_PUBLIC_APP_NAME || 'FouadBechar';
    const otpauth = authenticator.keyuri(email, serviceName, secret);

    // Generate QR code data URL
    let qrDataUrl: string | null = null;
    try {
      qrDataUrl = await QRCode.toDataURL(otpauth);
    } catch (e) {
      console.warn('Failed to generate QR code', e);
    }

    // Return secret and otpauth; the client should verify a code then request verification
    return NextResponse.json({ secret, otpauth, qrDataUrl });
  } catch (err) {
    console.error('2FA setup error', err);
    return isoError();
  }
}
