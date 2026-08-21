import { test, expect } from '@playwright/test';

test.describe('2FA Setup issuer checks', () => {
  test('otpauth includes issuer param with expected site URL', async ({ page }) => {
    const E2E_EMAIL = process.env.E2E_TEST_EMAIL;
    const E2E_PASSWORD = process.env.E2E_TEST_PASSWORD;
    if (!E2E_EMAIL || !E2E_PASSWORD) {
      test.skip(true, 'No E2E credentials set');
      return;
    }

    // Login to obtain session cookies
    await page.goto('/auth/login');
    await page.fill('input[name="email"]', E2E_EMAIL);
    await page.fill('input[name="password"]', E2E_PASSWORD);
    await page.click('button[type=submit]');
    await page.waitForURL('**/dashboard', { timeout: 10000 });

    // Fetch profile (cookie-based) to get the user id
    const profile = await page.evaluate(async () => {
      const res = await fetch('/api/dashboard/profile');
      if (!res.ok) return null;
      return await res.json();
    });
    const userId = profile?.profile?.id;
    expect(userId, 'profile id fetched').toBeTruthy();

    // Call 2FA setup route to get otpauth
    const setup = await page.evaluate(async (id) => {
      const res = await fetch('/api/dashboard/2fa/setup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: id }),
      });
      return await res.json();
    }, userId);

    expect(setup).toBeTruthy();
    expect(setup.otpauth, 'otpauth present').toBeTruthy();
    const otpauth: string = setup.otpauth;
    const query = otpauth.split('?')[1] || '';
    const params = new URLSearchParams(query);
    const issuerParam = params.get('issuer') || '';
    const decoded = decodeURIComponent(issuerParam);
    const expected = process.env.NEXT_PUBLIC_SITE_URL || 'https://fbweb.vercel.app';
    expect(decoded, `issuer=${decoded}`).toBe(expected);
  });
});
