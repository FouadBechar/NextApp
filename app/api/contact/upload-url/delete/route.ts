import { NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';

export async function POST(request: Request) {
  try {
    const body = await request.json().catch(() => null);
    const bucket = typeof body?.bucket === 'string' ? body.bucket : '';
    const objectPath = typeof body?.objectPath === 'string' ? body.objectPath : '';

    if (!bucket || !objectPath) {
      return NextResponse.json({ message: 'Bucket and object path are required.' }, { status: 400 });
    }

    const supabase = createAdminClient();
    const { error } = await supabase.storage.from(bucket).remove([objectPath]);

    if (error) {
      console.error('Contact upload cleanup error', error);
      return NextResponse.json({ message: 'Unable to remove uploaded file.' }, { status: 500 });
    }

    return NextResponse.json({ status: 'success' });
  } catch (error) {
    console.error('Contact upload cleanup route error', error);
    return NextResponse.json({ message: 'Unable to remove uploaded file.' }, { status: 500 });
  }
}
