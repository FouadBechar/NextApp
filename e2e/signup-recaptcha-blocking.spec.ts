import { test, expect } from '@playwright/test';

// Test that sign up is blocked when /api/recaptcha returns a failure
test('signup recaptcha blocking - server-side verification fails', async ({ page }) => {
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

  // ensure username availability request returns available
  await page.route('**/api/auth/username-availability**', (route) => {
    route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify({ available: true }) });
  });

  await page.goto('/auth/signup');
  await page.waitForLoadState('networkidle');

  await page.getByPlaceholder('you@example.com').fill('test@example.com');
  await page.getByPlaceholder('yourusername').fill('testuser1');
  await page.getByPlaceholder('••••••••').first().fill('P@ssw0rd!');
  await page.getByPlaceholder('••••••••').nth(1).fill('P@ssw0rd!');

  const submitButton = page.getByRole('button', { name: /create account/i });
  await submitButton.click();

  // Should show the recaptcha failure error
  await expect(page.locator('text=reCAPTCHA verification failed')).toBeVisible();
  // Should remain on signup page
  await expect(page).toHaveURL(/\/auth\/signup/i);
});
