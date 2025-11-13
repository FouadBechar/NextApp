import { NextResponse, type NextRequest } from 'next/server';
import sharp from 'sharp';
import { createAdminClient } from '@/utils/supabase/client';
import { createServerClient } from '@supabase/ssr';

export const runtime = 'nodejs';

// Node-based avatar processing route using sharp.
// Accepts multipart/form-data with field `file` and optional `filename`.
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

    // Use Request.formData() to parse multipart (supported in Node runtime polyfill)
    const form = await req.formData();
    const file = form.get('file') as File | null;
    if (!file) {
      return NextResponse.json(
        { error: { code: 'MISSING_FILE', message: 'No file was attached under the "file" field.' } },
        { status: 400 }
      );
    }

    // validation
    const MAX_BYTES = 5 * 1024 * 1024; // 5 MB
    const ALLOWED_MIMES = new Set(['image/png', 'image/jpeg', 'image/webp', 'image/gif', 'image/svg+xml']);

    const size = (file as any).size ?? 0;
    const mime = (file as any).type ?? '';

    if (size === 0) {
      return NextResponse.json({ error: { code: 'EMPTY_FILE', message: 'The uploaded file appears to be empty.' } }, { status: 400 });
    }
    if (size > MAX_BYTES) {
      return NextResponse.json({ error: { code: 'FILE_TOO_LARGE', message: `File is too large. Maximum allowed size is ${Math.round(MAX_BYTES / 1024 / 1024)} MB.` } }, { status: 413 });
    }
    if (!mime || !ALLOWED_MIMES.has(mime)) {
      const filenameRaw = (form.get('filename') as string) || (file as any).name || '';
      const ext = filenameRaw.split('.').pop()?.toLowerCase() || '';
      const extToMime: Record<string, string> = { png: 'image/png', jpg: 'image/jpeg', jpeg: 'image/jpeg', webp: 'image/webp', gif: 'image/gif', svg: 'image/svg+xml' };
      const inferred = extToMime[ext] ?? null;
      if (!inferred) {
        return NextResponse.json({ error: { code: 'UNSUPPORTED_FILE_TYPE', message: 'Unsupported or missing file type. Please upload a PNG, JPG, WEBP, GIF or SVG image.' } }, { status: 415 });
      }
    }

    // Read file buffer
    const arrayBuffer = await file.arrayBuffer();
    const inputBuffer = Buffer.from(arrayBuffer);

    // Process with sharp: center-crop to square and resize to 512x512, convert to webp for good compression
    const SIZE = 512;
    let processedBuffer: Buffer;
    try {
      // Honor EXIF orientation; produce a canonical WebP (metadata stripped by default)
      processedBuffer = await sharp(inputBuffer)
        .rotate()
        .resize(SIZE, SIZE, { fit: 'cover', position: 'centre' })
        .webp({ quality: 85 })
        .toBuffer();
    } catch (err) {
      console.error('sharp processing error', err);
      return NextResponse.json({ error: { code: 'PROCESSING_FAILED', message: 'Image processing failed' } }, { status: 500 });
    }

    // upload to Supabase Storage (admin client)
    const admin = createAdminClient();
    const filenameRaw = (form.get('filename') as string) || (file as any).name || `${Date.now()}.webp`;
    const base = filenameRaw.replace(/[^a-zA-Z0-9._-]/g, '_').replace(/\.[^.]+$/, '');
    const path = `${AVATAR_BUCKET}/${user.id}/${Date.now()}-${base}.webp`;

    const { error: uploadError } = await admin.storage.from(AVATAR_BUCKET).upload(path, processedBuffer, {
      contentType: 'image/webp',
      upsert: true,
    });

    if (uploadError) {
      console.error('Avatar upload failed', uploadError);
      return NextResponse.json({ error: { code: 'UPLOAD_FAILED', message: `Upload failed: ${uploadError.message || 'unknown error'}` } }, { status: 500 });
    }

    // Persist path to profiles table
    try {
      const { data, error } = await admin.from('profiles').update({ avatar_path: path }).eq('id', user.id).select('avatar_path').maybeSingle();
      if (error) {
        console.error('Failed to persist avatar_path', error);
      }
    } catch (e) {
      console.error('DB update error', e);
    }

    // generate public or signed URL
    let publicUrl: string | null = null;
    try {
      if (AVATAR_PUBLIC) {
        const { data } = admin.storage.from(AVATAR_BUCKET).getPublicUrl(path);
        publicUrl = data?.publicUrl || null;
      } else {
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
    console.error('avatar-sharp.route error', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error' } }, { status: 500 });
  }
}
