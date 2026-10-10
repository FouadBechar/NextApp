import { NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';

const MAX_FILE_SIZE_BYTES = 18 * 1024 * 1024;

function sanitizeFileName(fileName: string) {
  const trimmed = fileName.trim();
  const lastDotIndex = trimmed.lastIndexOf('.');
  const hasExtension = lastDotIndex > 0 && lastDotIndex < trimmed.length - 1;
  const rawBaseName = hasExtension ? trimmed.slice(0, lastDotIndex) : trimmed;
  const rawExtension = hasExtension ? trimmed.slice(lastDotIndex + 1) : '';

  const safeBaseName = rawBaseName
    .replace(/[^a-zA-Z0-9_-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^[-_]+|[-_]+$/g, '');

  const safeExtension = rawExtension.replace(/[^a-zA-Z0-9]+/g, '').toLowerCase();
  const finalBaseName = safeBaseName || `upload-${Date.now()}`;

  return safeExtension ? `${finalBaseName}.${safeExtension}` : finalBaseName;
}

export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => null);
    const fileName = typeof body?.fileName === 'string' ? body.fileName : '';
    const fileType = typeof body?.fileType === 'string' ? body.fileType : 'application/octet-stream';
    const fileSize = typeof body?.fileSize === 'number' ? body.fileSize : 0;

    if (!fileName) {
      return NextResponse.json({ message: 'File name is required.' }, { status: 400 });
    }

    if (!Number.isFinite(fileSize) || fileSize <= 0) {
      return NextResponse.json({ message: 'File size is required.' }, { status: 400 });
    }

    if (fileSize > MAX_FILE_SIZE_BYTES) {
      return NextResponse.json({ message: 'File too large (max 18MB).' }, { status: 413 });
    }

    const safeName = sanitizeFileName(fileName);
    const objectPath = `contact-uploads/${Date.now()}_${Math.random().toString(36).slice(2, 8)}_${safeName}`;
    const bucket = process.env.SUPABASE_STORAGE_BUCKET ?? 'contacts';

    const supabase = createAdminClient();
    const { data, error } = await supabase.storage.from(bucket).createSignedUploadUrl(objectPath);

    if (error || !data) {
      console.error('Signed upload URL error', error);
      return NextResponse.json({ message: 'Unable to prepare file upload.' }, { status: 500 });
    }

    const { data: publicData } = supabase.storage.from(bucket).getPublicUrl(objectPath);

    return NextResponse.json({
      bucket,
      objectPath,
      token: data.token,
      publicUrl: publicData.publicUrl,
      contentType: fileType,
    });
  } catch (error) {
    console.error('Contact upload-url error', error);
    return NextResponse.json({ message: 'Unable to prepare file upload.' }, { status: 500 });
  }
}
