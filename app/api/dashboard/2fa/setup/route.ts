import { NextRequest, NextResponse } from 'next/server';
import { authenticator } from 'otplib';
import QRCode from 'qrcode';
import { createServerClient } from '@supabase/ssr';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import { verifyUserFromRequest, VerifiedUserResult } from '@/utils/supabase/verify-user';
import parseJsonOrEmpty from '@/utils/parse-request';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

// verifyUserFromRequest provided by utils/supabase/verify-user

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
    const websiteUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://fbweb.vercel.app';

    // For the otpauth issuer we prefer a clean host name (domain) rather than
    // a full URL. This shows up nicely in authenticator apps like Google
    // Authenticator/1Password. Fall back to the configured app name when a
    // host cannot be parsed.
    let issuerHost = '';
    try {
      issuerHost = new URL(websiteUrl).hostname;
    } catch (err) {
      // If parsing fails, try to normalize the string and remove protocol
      // and trailing slashes so we don't accidentally put a long URL into
      // the issuer field.
      issuerHost = websiteUrl.replace(/^https?:\/\//, '').replace(/\/$/, '');
    }
    const issuer = issuerHost || serviceName;

    // The label typically looks like: "AppName:user@example.com" — keep that
    // format and encode properly for inclusion in the otpauth URI.
    const label = `${serviceName}:${email}`;
    const encodedLabel = encodeURIComponent(label);
    const encodedIssuer = encodeURIComponent(issuer);
    const otpauth = `otpauth://totp/${encodedLabel}?secret=${secret}&issuer=${encodedIssuer}`;

    // Generate QR code data URL
    let qrDataUrl: string | null = null;
    try {
      qrDataUrl = await QRCode.toDataURL(otpauth);
    } catch (e) {
      console.warn('Failed to generate QR code', e);
    }

    // Return secret, otpauth, and some helpful metadata; the client should verify
    // a code then request verification. We return `issuer` and `label` so UI and
    // tests can display/re-validate the data.
    return NextResponse.json({ secret, otpauth, qrDataUrl, issuer, label });
  } catch (err) {
    console.error('2FA setup error', err);
    return isoError();
  }
}
