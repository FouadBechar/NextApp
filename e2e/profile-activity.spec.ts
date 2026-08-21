import { test, expect } from '@playwright/test';

test('Profile: Login Activity - toggle recent & refresh', async ({ page }) => {
  const E2E_EMAIL = process.env.E2E_TEST_EMAIL;
  const E2E_PASSWORD = process.env.E2E_TEST_PASSWORD;
  if (!E2E_EMAIL || !E2E_PASSWORD) {
    test.skip(true, 'No E2E credentials set');
    return;
  }

  await page.goto('/auth/login');
  await page.fill('input[name="email"]', E2E_EMAIL);
  await page.fill('input[name="password"]', E2E_PASSWORD);
  await page.click('button[type=submit]');
  await page.waitForURL('**/dashboard', { timeout: 10000 });

  await page.goto('/dashboard/profile');
  await page.waitForSelector('text=Login Activity');

  // Show recent toggle
  const toggleBtn = page.getByRole('button', { name: /show recent/i });
  await toggleBtn.click();
  await page.waitForSelector('text=Recent Activity');
  await expect(page.locator('text=Recent Activity')).toBeVisible();

  // Click refresh to ensure the activity list updates and respond to activities endpoint
  const responsePromise = page.waitForResponse((resp) => resp.url().includes('/api/dashboard/activities') && resp.status() === 200);
  const refreshBtn = page.getByRole('button', { name: /refresh/i });
  await refreshBtn.click();
  await responsePromise;

  // Confirm that at least one activity is shown in the recent list
  const count = await page.locator('ul.divide-y li').count();
  expect(count).toBeGreaterThan(0);
});
