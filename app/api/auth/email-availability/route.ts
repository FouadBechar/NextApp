/*
  The legacy approach used admin.auth.admin.listUsers which required casting
  to the admin API shape; we safely query the 'profiles' table instead which
  avoids admin API shape assumptions and is more predictable.
*/


import { NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';

export async function GET(req: Request) {
  try {
    const url = new URL(req.url);
    const email = url.searchParams.get('email') || '';
    if (!email) return NextResponse.json({ available: false }, { status: 200 });

    const admin = createAdminClient();
    const { data, error } = await admin
      .from('profiles')
      .select('id')
      .eq('email', email)
      .limit(1)
      .maybeSingle();

    if (error) {
      console.error('Email check error', error);
      return NextResponse.json({ available: false }, { status: 500 });
    }

    return NextResponse.json({ available: !data });
  } catch (err) {
    console.error(err);
    return NextResponse.json({ available: false }, { status: 500 });
  }
}
