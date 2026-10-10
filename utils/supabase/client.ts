import { createBrowserClient } from '@supabase/ssr';
import { createClient as createNewClient } from '@supabase/supabase-js';

export const createClient = () =>
  createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

export const createAdminClient = () =>
  // Prefer a server-only service role key. For backwards compatibility we fall back to
  // NEXT_PUBLIC_SUPABASE_SRK if present, but that's not recommended for production.
  (() => {
    const url = process.env.NEXT_PUBLIC_SUPABASE_URL!;
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_SRK;
    if (!serviceKey) {
      throw new Error('Supabase service role key is not configured. Set SUPABASE_SERVICE_ROLE_KEY in server env.');
    }
    if (process.env.NEXT_PUBLIC_SUPABASE_SRK && !process.env.SUPABASE_SERVICE_ROLE_KEY) {
      // If the only available SRK is exposed as NEXT_PUBLIC_... warn in server logs.
      // This helps catch accidental exposure of the service role key to the client.
      // eslint-disable-next-line no-console
      console.warn('Using NEXT_PUBLIC_SUPABASE_SRK as a fallback for admin client. For security, set SUPABASE_SERVICE_ROLE_KEY in server-only env.');
    }
    return createNewClient(url, serviceKey!);
  })();
