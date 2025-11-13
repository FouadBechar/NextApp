import { NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const username = url.searchParams.get('username') || '';
    if (!username) return NextResponse.json({ available: false }, { status: 200 });

    const admin = createAdminClient();
    const { data, error } = await admin
      .from('profiles')
      .select('id')
      .eq('username', username)
      .limit(1)
      .maybeSingle();

    if (error) {
      console.error('Username check error', error);
      return NextResponse.json({ available: false }, { status: 500 });
    }

    return NextResponse.json({ available: !data });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ available: false }, { status: 500 });
  }
}
