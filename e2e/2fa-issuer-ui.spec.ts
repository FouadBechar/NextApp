import { test, expect } from '@playwright/test';

test.describe('2FA Setup UI issuer checks', () => {
  test('Clicking Enable triggers setup and returns otpauth with expected issuer', async ({ page }) => {
    const E2E_EMAIL = process.env.E2E_TEST_EMAIL;
    const E2E_PASSWORD = process.env.E2E_TEST_PASSWORD;
    if (!E2E_EMAIL || !E2E_PASSWORD) {
      test.skip(true, 'No E2E credentials set');
      return;
    }

    // Login
    await page.goto('/auth/login');
    await page.fill('input[name="email"]', E2E_EMAIL);
    await page.fill('input[name="password"]', E2E_PASSWORD);
    await page.click('button[type=submit]');
    await page.waitForURL('**/dashboard', { timeout: 10000 });

    // Visit profile page
    await page.goto('/dashboard/profile');
    // If 2FA is already enabled, skip to avoid disabling in test
    const enabledText = await page.locator('text=Enabled').first().count();
    if (enabledText > 0) {
      test.skip(true, '2FA already enabled for E2E user');
      return;
    }

    // Wait for the Enable button to appear
    const enableBtn = page.getByRole('button', { name: /Enable/i });
    await expect(enableBtn).toBeVisible();

    // Wait for the API response triggered by clicking Enable
    const responsePromise = page.waitForResponse((resp) => resp.url().includes('/api/dashboard/2fa/setup') && resp.status() === 200);
    await enableBtn.click();
    const resp = await responsePromise;
    const data = await resp.json();
    expect(data?.otpauth).toBeTruthy();
    const otpauth: string = data.otpauth;
    const query = otpauth.split('?')[1] || '';
    const params = new URLSearchParams(query);
    const issuerParam = params.get('issuer') || '';
    const decoded = decodeURIComponent(issuerParam);
    const expected = process.env.NEXT_PUBLIC_SITE_URL || 'https://fbweb.vercel.app';
    expect(decoded, `issuer=${decoded}`).toBe(expected);
  });
});
