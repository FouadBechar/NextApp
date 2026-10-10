import { test, expect } from '@playwright/test';
import { AxeBuilder } from '@axe-core/playwright';

test.describe('E2E accessibility', () => {
  test('Home page should have no critical a11y violations', async ({ page, baseURL }) => {
    await page.goto('/');
    const results = await new AxeBuilder({ page }).analyze();
    expect(results.violations.length).toBe(0);
  });

  test('Dashboard drawer accessibility (skipped if no creds)', async ({ page }) => {
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
    // wait for redirect to dashboard
    await page.waitForURL('**/dashboard', { timeout: 10000 });

    // ensure the mobile toggle exists; set mobile viewport
    await page.setViewportSize({ width: 375, height: 800 });
    await page.click('button[aria-label="Open menu"]');
    const a11yResults = await new AxeBuilder({ page }).include('#mobile-sidebar').analyze();
    expect(a11yResults.violations.length).toBe(0);
    // ensure aria-hidden is toggled on main
    const main = page.locator('main');
    await expect(main).toHaveAttribute('aria-hidden', 'true');
    // close and assert main is visible again
    await page.keyboard.press('Escape');
    await expect(main).toHaveAttribute('aria-hidden', 'false');
  });
});
