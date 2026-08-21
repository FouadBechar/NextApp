import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';

export default async function LoginRedirectPage() {
  const supabase = await createClient();
  const {
    data: { session },
  } = await supabase.auth.getSession();

  if (session) {
    redirect('/dashboard');
  }

  redirect('/auth/login');
}
