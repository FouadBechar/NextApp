import { test, expect } from '@playwright/test';

// Test that login is blocked when /api/recaptcha returns a failure
test('login recaptcha blocking - server-side verification fails', async ({ page }) => {
  await page.addInitScript({
    content: `window.grecaptcha = { ready: (cb)=> cb(), execute: (siteKey, opts) => Promise.resolve('FAKE_TOKEN') }`,
  });

  await page.route('**/api/recaptcha', (route) => {
    route.fulfill({
      status: 403,
      contentType: 'application/json',
      body: JSON.stringify({ success: false, message: 'reCAPTCHA verification failed' }),
    });
  });
  // stub login rate limit check
  await page.route('**/api/auth/login-attempt', (route) => {
    route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ ok: true }) });
  });

  await page.goto('/auth/login');
  await page.waitForLoadState('networkidle');

  await page.getByPlaceholder('you@example.com').fill('test@example.com');
  await page.getByPlaceholder('••••••••').fill('P@ssw0rd!');

  const submitButton = page.getByRole('button', { name: /sign in/i });
  await submitButton.click();

  // Should show the recaptcha failure error
  await expect(page.locator('text=reCAPTCHA verification failed')).toBeVisible();
  await expect(page).toHaveURL(/\/auth\/login/i);
});
