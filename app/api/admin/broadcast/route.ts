import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { getResend, sendEmail } from '@/lib/resend';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';

/**
 * Admin broadcast endpoint — sends a simple subject/body (or react template payload)
 * to all users who have `preferences.emailNotifications` enabled.
 *
 * Security: requires an admin bearer token in the Authorization header to run.
 * The token can be one or more admin emails defined in `ADMIN_BROADCAST_EMAILS` env var.
 */
export async function POST(req: NextRequest) {
  try {
    const authHeader = req.headers.get('authorization');
    // Two modes of auth are supported for convenience: either a bearer token that matches the
    // ADMIN_BROADCAST_TOKEN env var, or a logged-in admin user (via verifyUserFromRequest) whose
    // email exists in ADMIN_BROADCAST_EMAILS.
    const body = await req.json();
    const { subject, text, react, dryRun } = body || {};

    if (!subject || (!text && !react)) {
      return NextResponse.json({ error: 'subject and text (or react) required' }, { status: 400 });
    }

    // Simple bearer token check (CI or server job can call with this token).
    // If the token matches, we proceed and mark the sender as 'token' or a configured sender.
    const adminToken = process.env.ADMIN_BROADCAST_TOKEN || null;
    let sentBy: string | null = null;
    if (adminToken && authHeader && authHeader.startsWith('Bearer ') && authHeader.split(' ')[1] === adminToken) {
      sentBy = process.env.BROADCAST_SENDER_EMAIL || 'admin-token';
    } else {
      // fallback: verify the request as a user and check the user's email is allowed
      const verified = await verifyUserFromRequest(req as any);
      if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });
      const allowed = (process.env.ADMIN_BROADCAST_EMAILS || '').split(',').map(s => s.trim()).filter(Boolean);
      // `verified.user.email` can be undefined; ensure it's present before checking the allow list
      const verifiedEmail = verified.user.email;
      if (!verifiedEmail || !allowed.includes(verifiedEmail)) {
        return NextResponse.json({ error: 'forbidden' }, { status: 403 });
      }
      sentBy = verifiedEmail ?? null;
    }

    // Verify resend available
    const resend = getResend();
    if (!resend) {
      return NextResponse.json({ error: 'RESEND_API_KEY missing' }, { status: 500 });
    }

    const admin = createAdminClient();
    // Fetch profiles; only select id, email, preferences. We handle DB missing column gracefully.
    const { data, error } = await admin.from('profiles').select('id,email,preferences');
    if (error) {
      console.error('Error fetching profiles for broadcast', error);
      return NextResponse.json({ error: 'failed to fetch profiles' }, { status: 500 });
    }

    const rows = (data ?? []) as Array<{ id?: string; email?: string | null; preferences?: unknown | null }>; 
    const recipients = rows
      .filter(r => r.email && typeof r.email === 'string')
      .filter(r => {
        try {
          // Preferences may be an object or a JSON string depending on how the
          // profile row was inserted. Normalize by parsing strings first.
          let prefs: any = r.preferences;
          if (typeof prefs === 'string') {
            try {
              prefs = JSON.parse(prefs);
            } catch (e) {
              return false;
            }
          }
          return !!(prefs && prefs.emailNotifications);
        } catch (e) {
          return false;
        }
      })
      .map(r => r.email as string);

    // Send in batches so we don't risk spamming the provider or hitting rate limits.
    const batchSize = parseInt(process.env.BROADCAST_BATCH_SIZE || '25', 10) || 25;
    const results: any[] = [];
    for (let i = 0; i < recipients.length; i += batchSize) {
      const batch = recipients.slice(i, i + batchSize);
      if (dryRun) {
        // for preview we will not actually send emails, only log and return recipients
        results.push(...batch.map((to) => ({ ok: true, data: null, to } as any)));
        continue;
      }
      const sendPromises = batch.map((to) => sendEmail({
        from: process.env.BROADCAST_FROM || 'noreply@example.com',
        to,
        subject,
        ...(react ? { react } : { text }),
      }));
      const settled = await Promise.all(sendPromises);
      results.push(...settled);
      // small delay between batches (if provided) to further reduce rapid burst traffic
      const delayMs = parseInt(process.env.BROADCAST_BATCH_DELAY_MS || '300', 10) || 300;
      if (i + batchSize < recipients.length) await new Promise((r) => setTimeout(r, delayMs));
    }

    const numSent = results.filter((r) => r?.ok).length;
    const numFailed = results.length - numSent;

    // Persist an audit record with the results.
    try {
      const meta = {
        batchSize,
        batchDelayMs: parseInt(process.env.BROADCAST_BATCH_DELAY_MS || '300', 10) || 300,
      } as Record<string, unknown>;
      await admin.from('notifications_sent').insert({
        subject,
        body: text ?? (react ? JSON.stringify(react) : null),
        sent_by: sentBy ?? null,
        recipients_count: recipients.length,
        sent_count: numSent,
        failed_count: numFailed,
        dry_run: !!dryRun,
        meta,
      });
      
    } catch (e) {
      console.error('Failed to insert audit log into notifications_sent', e);
    }
    return NextResponse.json({ sent: numSent, failed: numFailed, totalRecipients: recipients.length });
  } catch (err: unknown) {
    console.error('admin broadcast error', err);
    return NextResponse.json({ error: (err as Error).message }, { status: 500 });
  }
}

export default POST;
