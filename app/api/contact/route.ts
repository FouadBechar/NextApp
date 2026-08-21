import { createAdminClient } from '@/utils/supabase/client';
import { NextResponse } from 'next/server';
import { sendEmail } from '@/lib/resend';

const MAX_FILE_SIZE_BYTES = 18 * 1024 * 1024;

function escapeHtml(s: string) {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

export async function POST(request: Request) {
  try {
    const form = await request.formData();
    const prenom = String(form.get('prenom') ?? '');
    const nom = String(form.get('nom') ?? '');
    const email = String(form.get('email') ?? '');
    const message = String(form.get('textarea') ?? '');
    const submittedFileName = String(form.get('fileName') ?? '');
    const submittedFileUrl = String(form.get('fileUrl') ?? '');
    const file = form.get('file') as File | null;

    if (!email) {
      return NextResponse.json({ error: 'Email is required' }, { status: 400 });
    }

    if (file && file.size > MAX_FILE_SIZE_BYTES) {
      return NextResponse.json(
        { status: 'error', message: 'File too large (max 18MB).' },
        { status: 413 }
      );
    }

    const supabase = createAdminClient();

    // If a file was attached, upload it to Supabase Storage and obtain a public URL
    let fileUrl: string | null = submittedFileUrl || null;
    let fileNameStored: string | null = submittedFileName || null;
    if (file && file.size > 0) {
      try {
        const arrayBuffer = await (file as File).arrayBuffer();
        const buffer = Buffer.from(arrayBuffer);
        const originalName = file.name ?? `upload-${Date.now()}`;
        // make a safe unique path
        const safeName = `${Date.now()}_${Math.random().toString(36).slice(2, 8)}_${originalName.replace(/[^a-zA-Z0-9._-]/g, '')}`;
        const bucket = process.env.SUPABASE_STORAGE_BUCKET ?? 'contacts';

        const uploadResult = await supabase.storage.from(bucket).upload(safeName, buffer, {
          contentType: file.type || 'application/octet-stream',
          upsert: false,
        });

        if (uploadResult.error) {
          console.error('Supabase upload error', uploadResult.error);
        } else {
          fileNameStored = originalName;
          const publicRes = await supabase.storage.from(bucket).getPublicUrl(safeName);
          fileUrl = publicRes.data?.publicUrl ?? null;
        }
      } catch (upErr) {
        console.error('File upload error', upErr);
      }
    }

    // Insert contact record into Supabase `contacts` table.
    const insertPayload: Record<string, unknown> = {
      first_name: prenom,
      last_name: nom,
      email,
      message,
      file_name: fileNameStored,
      file_url: fileUrl,
      created_at: new Date().toISOString(),
    };

    const { data, error } = await supabase.from('contacts').insert([insertPayload]);

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // Send confirmation email to the sender using Resend
    const safeFirst = escapeHtml(prenom || nom || 'there');
    const safeMessage = escapeHtml(message || '');

    try {
      const html = `
        <div>
          <p>Hi ${safeFirst},</p>
          <p>Thanks for contacting us. We received your message:</p>
          <blockquote>${safeMessage}</blockquote>
          <p>We'll process your request as soon as possible and get back to you at ${escapeHtml(email)}.</p>
          <p>— The team</p>
        </div>
      `;

      // Use the centralized wrapper to send confirmation emails. Wrapper returns a
      // normalized result so we can gracefully handle missing API key at runtime.
      const result = await sendEmail({
        from: 'Fouad Bechar <fouad@bechar.x10.network>',
        to: email,
        subject: 'We received your message',
        html,
      });
      if (!result.ok) {
        if (result.missingApiKey) {
          console.warn('Skipping confirmation email: RESEND_API_KEY not configured');
        } else {
          console.error('Resend sendEmail error', result.error);
          // Return a partial success (the DB insert succeeded)
          return NextResponse.json({ status: 'stored', message: 'Saved but failed to send confirmation email' });
        }
      }
    } catch (mailErr) {
      // log but don't fail the whole request; return partial success
      console.error('Resend error', mailErr);
      return NextResponse.json({ status: 'stored', message: 'Saved but failed to send confirmation email' });
    }

    return NextResponse.json({ status: 'success', message: 'Submission complete' });
  } catch (err: unknown) {
    console.error('Contact API error', err);
    return NextResponse.json({ error: err instanceof Error ? err.message : 'Internal server error' }, { status: 500 });
  }
}
