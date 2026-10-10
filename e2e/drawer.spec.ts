import { test, expect } from '@playwright/test';
import { ensureE2EUser } from './helpers';
import AxeBuilder from '@axe-core/playwright';

test.describe('Mobile Drawer Accessibility', () => {
  test('opens and traps focus, aria attributes set', async ({ page, browserName }) => {
    await ensureE2EUser(page);
    // Emulate mobile viewport
    await page.setViewportSize({ width: 375, height: 812 });

    await page.goto('/dashboard');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('header')).toBeVisible();

    const menuButton = page.getByLabel('Open menu');
    await expect(menuButton).toBeVisible();

    // Open drawer
    await menuButton.click();
    const drawer = page.getByRole('dialog');
    await expect(drawer).toBeVisible();

    // main should be aria-hidden
    const main = page.locator('main');
    await expect(main).toHaveAttribute('aria-hidden', 'true');

    // Focus is trapped inside the drawer; tabbing cycles
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    // Press Escape to close
    await page.keyboard.press('Escape');
    await expect(drawer).toBeHidden();

    // Run axe accessibility scan in the opened state to catch issues
    await menuButton.click();
    const accessibilityScan = await new AxeBuilder({ page }).analyze();
    // assert no violations of level critical/serious idea
    expect(accessibilityScan.violations.filter(v => v.impact === 'critical' || v.impact === 'serious').length).toBe(0);
  });
});
