import { NextResponse, type NextRequest } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import parseJsonOrEmpty from '@/utils/parse-request';
import { verifyUserFromRequest } from '@/utils/supabase/verify-user';
import { getResend, sendEmail } from '@/lib/resend';
import ExportEmail from '@/lib/emails/export-email';

export async function POST(req: NextRequest) {
  try {
    let body: any = {};
    try {
      body = await parseJsonOrEmpty(req as unknown as Request);
    } catch (e) {
      return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 });
    }
    const userId = body?.userId;
    if (!userId) return NextResponse.json({ error: 'missing userId' }, { status: 400 });

    const verified = await verifyUserFromRequest(req, userId);
    if (!verified.ok) return NextResponse.json({ error: verified.reason || 'unauthorized' }, { status: verified.status || 401 });

    const admin = createAdminClient();
    const [profileRes, activitiesRes] = await Promise.all([
      admin.from('profiles').select('id,full_name,username,email,preferences,avatar_url,avatar_path').eq('id', userId).maybeSingle(),
      admin.from('activities').select('id,title,description,metadata,created_at').eq('user_id', userId).order('created_at', { ascending: false }).limit(1000),
    ]);

    if (profileRes.error) {
      const msg = String(profileRes.error.message || '').toLowerCase();
      if (msg.includes('column') && msg.includes('preferences')) {
        // preferences missing — proceed and warn
      } else {
        console.error('Export profile error', profileRes.error);
        return NextResponse.json({ error: 'Failed to export profile' }, { status: 500 });
      }
    }
    if (activitiesRes.error) {
      const msg = String(activitiesRes.error.message || '').toLowerCase();
      if (msg.includes('does not exist') || msg.includes('relation')) {
        // activities missing — continue
      } else {
        console.error('Export activities error', activitiesRes.error);
        return NextResponse.json({ error: 'Failed to export activities' }, { status: 500 });
      }
    }

    const payload: Record<string, unknown> = {
      profile: profileRes.data ?? null,
      activities: (activitiesRes.data ?? []).map((a: any) => ({
        id: a.id,
        title: a.title,
        description: a.description,
        metadata: a.metadata || null,
        timestamp: a.created_at,
      })),
    };

    const sendEmailRequested = Boolean(body?.sendEmail);
    if (!sendEmailRequested) {
      return NextResponse.json({ success: true, export: payload });
    }

    // send via email
    const recipientEmail = profileRes?.data?.email;
    if (!recipientEmail) return NextResponse.json({ error: 'email not available for this user', emailSent: false }, { status: 400 });

    const jsonString = JSON.stringify(payload, null, 2);
    const MAX_ATTACHMENT_BYTES = parseInt(process.env.EXPORT_EMAIL_MAX_BYTES || '10485760', 10);
    const jsonBytes = Buffer.byteLength(jsonString, 'utf8');

    const resend = getResend();
    if (!resend) return NextResponse.json({ error: 'RESEND_API_KEY missing', emailSent: false }, { status: 500 });

    const filename = `export-${userId}-${Date.now()}.json`;

    if (jsonBytes <= MAX_ATTACHMENT_BYTES) {
      // send as attachment
      const base64 = Buffer.from(jsonString, 'utf8').toString('base64');
      const result = await sendEmail({
        from: process.env.EXPORT_FROM || process.env.BROADCAST_FROM || 'fouad@bechar.x10.network',
        to: recipientEmail,
        subject: 'Your data export',
        react: ExportEmail({ filename }),
        attachments: [{ filename, contentType: 'application/json', content: base64 }],
      });
      if (!result.ok) {
        console.error('failed to send export email', result);
        return NextResponse.json({ success: false, emailSent: false, error: 'failed to send' }, { status: 500 });
      }
      return NextResponse.json({ success: true, export: null, emailSent: true });
    }

    // Large export: upload to Supabase storage and send signed link
    const bucket = process.env.EXPORT_BUCKET || 'exports';
    const path = `${bucket}/${userId}/${Date.now()}-${filename}`;
    try {
      const { error: uploadError } = await admin.storage.from(bucket).upload(path, Buffer.from(jsonString, 'utf8'), { upsert: true });
      if (uploadError) {
        console.error('Upload error', uploadError);
        return NextResponse.json({ success: false, emailSent: false, error: 'failed to upload' }, { status: 500 });
      }
      const urlTtl = parseInt(process.env.EXPORT_SIGNED_URL_TTL || '3600', 10) || 3600;
      const { data: signedData, error: signedErr } = await admin.storage.from(bucket).createSignedUrl(path, urlTtl);
      if (signedErr) {
        console.error('signed url error', signedErr);
        return NextResponse.json({ success: false, emailSent: false, error: 'failed to create signed URL' }, { status: 500 });
      }
      const signedUrl = signedData?.signedUrl ?? null;
      const result = await sendEmail({
        from: process.env.EXPORT_FROM || process.env.BROADCAST_FROM || 'fouad@bechar.x10.network',
        to: recipientEmail,
        subject: 'Your data export is ready',
        react: ExportEmail({ filename, dashboardUrl: signedUrl ?? undefined }),
      });
      if (!result.ok) {
        console.error('failed to send export link', result);
        return NextResponse.json({ success: false, emailSent: false, error: 'failed to send' }, { status: 500 });
      }
      return NextResponse.json({ success: true, export: null, emailSent: true, signedUrl });
    } catch (e) {
      console.error('large export error', e);
      return NextResponse.json({ success: false, emailSent: false, error: 'internal error' }, { status: 500 });
    }
  } catch (err) {
    console.error('Export POST error', err);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

// Named POST export provided by the function above.

