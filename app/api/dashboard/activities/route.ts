import { NextResponse, type NextRequest } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { getUserIdFromToken } from '@/utils/jwt';
import { extractUserFromAdminResponse } from '@/utils/supabase/extract-user';
import { getAdminUserById } from '@/utils/supabase/get-admin-user';
import parseJsonOrEmpty from '@/utils/parse-request';
import { createServerClient } from '@supabase/ssr';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';
import { sendEmail } from '@/lib/resend';

// Using shared `verifyUserFromRequest` helper

function parsePreferences(value: unknown): Record<string, unknown> {
  if (!value) return {};
  if (typeof value === 'string') {
    try {
      return JSON.parse(value) as Record<string, unknown>;
    } catch {
      return {};
    }
  }
  return typeof value === 'object' ? (value as Record<string, unknown>) : {};
}

function isSecurityActivity(title: string) {
  return /password|2fa|two-factor|sign-?in|login|export|trusted device/i.test(title);
}

async function sendSecurityActivityAlert(
  admin: ReturnType<typeof createAdminClient>,
  activity: Record<string, any>
) {
  const title = String(activity.title || '');
  if (!isSecurityActivity(title)) return;

  try {
    const { data: profile, error } = await admin
      .from('profiles')
      .select('email,full_name,username,preferences')
      .eq('id', activity.user_id)
      .maybeSingle();

    if (error) {
      console.error('Failed to load profile for security alert', error);
      return;
    }

    const email = typeof profile?.email === 'string' ? profile.email : null;
    if (!email) return;

    const preferences = parsePreferences(profile?.preferences);
    if (preferences.securityAlerts === false) return;

    const displayName = profile?.full_name || profile?.username || email;
    const happenedAt = new Date().toLocaleString();
    const details = [
      activity.description ? `Details: ${activity.description}` : null,
      activity.ip ? `IP address: ${activity.ip}` : null,
      activity.user_agent ? `Device: ${activity.user_agent}` : null,
    ].filter(Boolean);

    const subject = `Security alert: ${title}`;
    const text = [
      `Hello ${displayName},`,
      '',
      `We recorded this security activity on your account: ${title}.`,
      `Time: ${happenedAt}`,
      ...details,
      '',
      'If this was you, no action is needed. If you do not recognize this activity, please review your account security settings immediately.',
    ].join('\n');

    const result = await sendEmail({
      from:
        process.env.SECURITY_ALERTS_FROM ||
        process.env.BROADCAST_FROM ||
        'noreply@example.com',
      to: email,
      subject,
      text,
    });

    try {
      await admin.from('notifications_sent').insert({
        subject,
        body: text,
        sent_by: 'system-security-alert',
        recipients_count: 1,
        sent_count: result.ok ? 1 : 0,
        failed_count: result.ok ? 0 : 1,
        dry_run: false,
        meta: {
          category: 'security-alert',
          userId: activity.user_id,
          activityTitle: title,
          missingApiKey: 'missingApiKey' in result ? result.missingApiKey : false,
        },
      });
    } catch (auditError) {
      console.error('Failed to audit security alert notification', auditError);
    }

    if (!result.ok) {
      console.error('Failed to send security activity alert', result);
    }
  } catch (alertError) {
    console.error('Security activity alert error', alertError);
  }
}

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const userId = url.searchParams.get('userId');

    const supabase = createAdminClient();

    const selectStr = 'id,title,description,metadata,created_at';
    const query = userId
      ? supabase.from('activities').select(selectStr).eq('user_id', String(userId)).order('created_at', { ascending: false }).limit(50)
      : supabase.from('activities').select(selectStr).order('created_at', { ascending: false }).limit(50);

    const { data, error } = await query;
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      // If the activities table doesn't exist yet, return an empty list instead of 500
      if (
        msg.includes('does not exist') ||
        msg.includes('no such table') ||
        (msg.includes('relation') && msg.includes('does not exist')) ||
        msg.includes('undefined_table')
      ) {
        console.warn('Activities table missing; returning empty activities list');
        return NextResponse.json({ activities: [] });
      }

      console.error('Activities query error', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    const payload = (data || []).map((a: any) => ({
      id: a.id,
      title: a.title,
      description: a.description,
      metadata: a.metadata || null,
      timestamp: a.created_at,
    }));

    return NextResponse.json({ activities: payload });
  } catch (err) {
    console.error('Activities.route error', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      console.error('Invalid JSON body for activities POST', e);
      return NextResponse.json({ error: 'Invalid JSON body' }, { status: 400 });
    }
    const { userId, title, description } = body || {};
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });
    if (!title) return NextResponse.json({ error: 'missing title' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();
    const insertRow: Record<string, any> = { user_id: userId, title: String(title) };
    if (typeof description === 'string') insertRow.description = description;

    // capture optional metadata (user agent and forward IP) when available
    try {
      const ua = req.headers.get('user-agent');
      if (ua) insertRow.user_agent = String(ua).slice(0, 2000);
      const xff = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip');
      if (xff) insertRow.ip = String(xff).split(',')[0].trim();
    } catch (e) {
      // headers may not be available in some runtimes — ignore
    }

    const { error } = await admin.from('activities').insert([insertRow]);
    if (error) {
      const msg = String(error.message || '').toLowerCase();
      if (msg.includes('relation') && msg.includes('does not exist')) {
        // activities table missing — don't fail, return a warning
        console.warn('activities table missing; activity not recorded');
        return NextResponse.json({ success: true, warning: 'activities table missing; not recorded' });
      }
      console.error('Activities insert error', error);
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    await sendSecurityActivityAlert(admin, insertRow);

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error('Activities.POST error', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}
