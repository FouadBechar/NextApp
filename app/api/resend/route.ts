import PasswordResetConfirmationEmail from '@/lib/emails/password-reset-confirmation-email';
import VerificationEmail from '@/lib/emails/verification-email';
import WelcomeEmail from '@/lib/emails/welcome-email';
import { createAdminClient } from '@/utils/supabase/client';
import { NextRequest, NextResponse } from 'next/server';
import { sendEmail } from '@/lib/resend';
import { z } from 'zod';

const resendEmailRequestSchema = z.object({
  type: z.enum(['verification', 'welcome', 'password-reset-confirmation']),
  email: z.string().trim().min(1, 'Email is required'),
  password: z.string().optional(),
  username: z.string().nullable().optional(),
  isPasswordReset: z.boolean().optional(),
});

function getAppOrigin(request: NextRequest) {
  const configuredUrl =
    process.env.NEXT_PUBLIC_SITE_URL ||
    process.env.NEXT_PUBLIC_APP_URL ||
    (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : undefined);

  const fallbackOrigin = new URL(request.url).origin;
  const candidate = configuredUrl ?? fallbackOrigin;

  try {
    return new URL(candidate).origin;
  } catch {
    return fallbackOrigin;
  }
}

function createAppUrl(request: NextRequest, path: string) {
  return new URL(path, `${getAppOrigin(request)}/`).toString();
}

export async function POST(request: NextRequest) {
  try {
    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }

    const parsed = resendEmailRequestSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: parsed.error.issues[0]?.message ?? 'Invalid request body' },
        { status: 400 }
      );
    }

    const { type, email, password, username, isPasswordReset } = parsed.data;

    let data;
    const hasKey = Boolean(process.env.RESEND_API_KEY);
    if (!hasKey) {
      return NextResponse.json({ error: 'RESEND_API_KEY missing; cannot send emails' }, { status: 500 });
    }

    // If username is missing, try to look it up from the profiles table by email
    let resolvedUsername: string | null = username ?? null;
    if (!resolvedUsername && email) {
      try {
        const supabase = createAdminClient();
        const { data: profile, error } = await supabase.from('profiles').select('username,full_name').eq('email', email).maybeSingle();
        if (!error && profile) {
          resolvedUsername = profile.username ?? profile.full_name ?? null;
        }
      } catch (e) {
        // ignore lookup errors — username will simply be null
      }
    }

    switch (type) {
      case 'verification': {
        const supabase = createAdminClient();
        let res;
        if (isPasswordReset) {
          res = await supabase.auth.admin.generateLink({
            type: 'recovery',
            email,
          });
        } else {
          if (!password) {
            return NextResponse.json(
              { error: 'Password is required for signup verification emails' },
              { status: 400 }
            );
          }

          res = await supabase.auth.admin.generateLink({
            type: 'signup',
            email,
            password,
          });
        }

        if (res.data.properties?.email_otp) {
          const result = await sendEmail({
            from: 'Fouad Bechar <fouad@bechar.x10.network>',
            to: email,
            subject: isPasswordReset
              ? 'Reset your password'
              : 'Verify your email',
            react: VerificationEmail({
                otp: res.data.properties?.email_otp,
                isPasswordReset: !!isPasswordReset,
                username: resolvedUsername,
              }),
          });
          if (!result.ok) throw result.error ?? new Error('sendEmail failed');
          data = result.data;
        } else {
          return NextResponse.json(
            {
              error:
                res.error?.message ??
                'No account was found for that email address',
            },
            { status: isPasswordReset ? 404 : 400 }
          );
        }

        break;
      }

      case 'welcome': {
        const dashboardUrl = createAppUrl(request, '/dashboard');
        const result = await sendEmail({
          from: 'Fouad Bechar <fouad@bechar.x10.network>',
          to: email,
          subject: 'Welcome to our platform!',
          react: WelcomeEmail({
            dashboardUrl,
            username: resolvedUsername,
          }),
        });
        if (!result.ok) throw result.error ?? new Error('sendEmail failed');
        data = result.data;
        break;
      }

      case 'password-reset-confirmation': {
        const loginUrl = createAppUrl(request, '/auth/login');
        const result = await sendEmail({
          from: 'Fouad Bechar <fouad@bechar.x10.network>',
          to: email,
          subject: 'Your password has been reset',
          react: PasswordResetConfirmationEmail({
            username: resolvedUsername,
            email,
            loginUrl,
          }),
        });
        if (!result.ok) throw result.error ?? new Error('sendEmail failed');
        data = result.data;
        break;
      }

      default:
        return NextResponse.json(
          { error: 'Invalid email type' },
          { status: 400 }
        );
    }

    return NextResponse.json({ data });
  } catch (error) {
    return NextResponse.json(
      { error: (error as Error).message },
      { status: 500 }
    );
  }
}
