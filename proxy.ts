import { type NextRequest, NextResponse } from 'next/server';
import { detectBrowser, isBot, isSupportedBrowser } from '@/lib/browser-support';
import { updateSession } from '@/utils/supabase/middleware';

const SKIP_PATHS = ['/unsupported'];

export async function proxy(request: NextRequest) {
  const pathname = request.nextUrl.pathname;
  const isPageRequest =
    !pathname.startsWith('/_next') && !pathname.startsWith('/api') && !pathname.startsWith('/static');
  const userAgent = request.headers.get('user-agent') ?? '';

  if (isPageRequest && !SKIP_PATHS.includes(pathname) && !isBot(userAgent)) {
    if (!isSupportedBrowser(detectBrowser(userAgent))) {
      return NextResponse.redirect(new URL('/unsupported', request.url));
    }
  }

  return updateSession(request);
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
