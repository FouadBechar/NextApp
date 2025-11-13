import { NextRequest, NextResponse } from 'next/server';
import { createAdminClient } from '@/utils/supabase/client';

function isoError(msg = 'Internal server error') {
  return NextResponse.json({ error: msg }, { status: 500 });
}

export async function POST(req: NextRequest) {
  try {
    // Read trusted_device cookie (raw token)
    const cookie = req.cookies.get('trusted_device');
    const raw = cookie ? (typeof cookie === 'string' ? cookie : (cookie as any).value) : null;
    if (!raw) return NextResponse.json({ updated: false, reason: 'no cookie' });

    // Hash token and attempt to update last_seen
    try {
      const crypto = await import('crypto');
      const hash = crypto.createHash('sha256').update(String(raw)).digest('hex');
      const admin = createAdminClient();
      const now = new Date().toISOString();
      const { data, error } = await admin.from('trusted_devices').update({ last_seen: now }).eq('token_hash', hash).select('id,user_id').maybeSingle();
      if (error) {
        const msg = String(error.message || '').toLowerCase();
        if (msg.includes('relation') && msg.includes('does not exist')) {
          return NextResponse.json({ updated: false, warning: 'trusted_devices table missing' });
        }
        console.error('trusted_devices update error', error);
        return isoError(error.message);
      }
      if (!data) return NextResponse.json({ updated: false, reason: 'no match' });
      return NextResponse.json({ updated: true, id: data.id, userId: data.user_id });
    } catch (e) {
      console.warn('Failed to refresh trusted device last_seen', e);
      return NextResponse.json({ updated: false, reason: 'internal' });
    }
  } catch (err) {
    console.error('trusted-devices refresh error', err);
    return isoError();
  }
}
