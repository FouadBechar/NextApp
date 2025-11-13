import { NextResponse, type NextRequest } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';
import { createServerClient } from '@supabase/ssr';

export const runtime = 'edge';

export async function POST(req: NextRequest) {
  try {
    const AVATAR_BUCKET = process.env.SUPABASE_AVATAR_BUCKET ?? 'avatars';
    const AVATAR_PUBLIC = (process.env.SUPABASE_AVATAR_PUBLIC ?? 'true').toLowerCase() !== 'false' && (process.env.SUPABASE_AVATAR_PUBLIC ?? 'true') !== '0';
    const AVATAR_SIGNED_URL_TTL = parseInt(process.env.SUPABASE_AVATAR_SIGNED_URL_TTL || '60', 10) || 60;

    // Verify session via cookies (preferred)
    const serverSupabase = createServerClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
      {
        cookies: {
          getAll() {
            return req.cookies.getAll();
          },
          setAll() {
            /* no-op */
          },
        },
      }
    );

    const {
      data: { user },
    } = await serverSupabase.auth.getUser();

    if (!user) {
      return NextResponse.json({ error: 'unauthenticated' }, { status: 401 });
    }

    const form = await req.formData();
    const file = form.get('file') as File | null;
    if (!file) {
      return NextResponse.json(
        { error: { code: 'MISSING_FILE', message: 'No file was attached under the "file" field.' } },
        { status: 400 }
      );
    }

    // Server-side validation
    const MAX_BYTES = 5 * 1024 * 1024; // 5 MB
    const ALLOWED_MIMES = new Set([
      'image/png',
      'image/jpeg',
      'image/webp',
      'image/gif',
      'image/svg+xml',
    ]);

    const size = (file as any).size ?? 0;
    const mime = (file as any).type ?? '';

    if (size === 0) {
      return NextResponse.json(
        { error: { code: 'EMPTY_FILE', message: 'The uploaded file appears to be empty.' } },
        { status: 400 }
      );
    }

    if (size > MAX_BYTES) {
      return NextResponse.json(
        { error: { code: 'FILE_TOO_LARGE', message: `File is too large. Maximum allowed size is ${Math.round(MAX_BYTES / 1024 / 1024)} MB.` } },
        { status: 413 }
      );
    }

    if (!mime || !ALLOWED_MIMES.has(mime)) {
      // try to infer from filename extension as a best-effort
      const filenameRaw = (form.get('filename') as string) || (file as any).name || '';
      const ext = filenameRaw.split('.').pop()?.toLowerCase() || '';
      const extToMime: Record<string, string> = {
        png: 'image/png',
        jpg: 'image/jpeg',
        jpeg: 'image/jpeg',
        webp: 'image/webp',
        gif: 'image/gif',
        svg: 'image/svg+xml',
      };
      const inferred = extToMime[ext] ?? null;
      if (!inferred) {
        return NextResponse.json(
          { error: { code: 'UNSUPPORTED_FILE_TYPE', message: 'Unsupported or missing file type. Please upload a PNG, JPG, WEBP, GIF or SVG image.' } },
          { status: 415 }
        );
      }
    }

  const filenameRaw = (form.get('filename') as string) || (file as any).name || 'upload';
  const filename = filenameRaw.replace(/[^a-zA-Z0-9.\-_]/g, '_').slice(0, 200);
  const path = `${AVATAR_BUCKET}/${user.id}/${Date.now()}-${filename}`;

    const arrayBuffer = await file.arrayBuffer();
    // Use Uint8Array instead of Buffer for Edge compatibility
    const uint8 = new Uint8Array(arrayBuffer);

  const admin = createAdminClient();
  const { error: uploadError } = await admin.storage.from(AVATAR_BUCKET).upload(path, uint8, { upsert: true });

    if (uploadError) {
      console.error('Avatar upload failed', uploadError);
      return NextResponse.json(
        { error: { code: 'UPLOAD_FAILED', message: `Upload failed: ${uploadError.message || 'unknown error'}` } },
        { status: 500 }
      );
    }

  let publicUrl: string | null = null;
  try {
    if (AVATAR_PUBLIC) {
      const { data } = admin.storage.from(AVATAR_BUCKET).getPublicUrl(path);
      publicUrl = data?.publicUrl || null;
    } else {
      // private bucket: create a short-lived signed URL
      const { data, error } = await admin.storage.from(AVATAR_BUCKET).createSignedUrl(path, AVATAR_SIGNED_URL_TTL);
      if (error) {
        console.error('createSignedUrl error', error);
      } else {
        publicUrl = (data as any)?.signedUrl || null;
      }
    }
  } catch (e) {
    console.error('Error generating avatar URL', e);
  }

  return NextResponse.json({ publicUrl, path });
  } catch (err) {
    console.error('avatar.route error', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error' } }, { status: 500 });
  }
}
