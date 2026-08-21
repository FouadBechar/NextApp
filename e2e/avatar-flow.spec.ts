import { test, expect } from '@playwright/test';
// path module not needed

test.describe('Avatar flow', () => {
  test('Upload avatar updates profile and forum author avatar', async ({ page }) => {
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

    // navigate to profile settings
    await page.goto('/dashboard/profile');
    await page.waitForSelector('input[type=file]');
    // Use a tiny 1x1 PNG as test payload — avoid relying on repo fixture files
    const base64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgwJ/l6gqvQAAAABJRU5ErkJggg==';
    const buffer = Buffer.from(base64, 'base64');
    await page.setInputFiles('input[type=file]', { name: 'avatar.png', mimeType: 'image/png', buffer });
    // wait for preview Upload button and click it
    const uploadBtn = page.getByRole('button', { name: 'Upload' });
    const originalHeaderSrc = await page.locator(`img[alt="${E2E_EMAIL}"]`).getAttribute('src');
    const uploadResponse = page.waitForResponse((resp) => resp.url().includes('/api/dashboard/avatar-sharp') && resp.status() >= 200);
    await uploadBtn.click();
    await uploadResponse;
    // wait for header avatar to update
    const headerImgUpdated = page.locator(`img[alt="${E2E_EMAIL}"]`);
    await page.waitForFunction(({ sel, orig }: { sel: string; orig: string | null }) => {
      const el = document.querySelector(sel) as HTMLImageElement | null;
      if (!el) return false;
      return el.src !== (orig ?? '') && el.complete;
    }, { sel: `img[alt=\"${E2E_EMAIL}\"]`, orig: originalHeaderSrc ?? '' });
    // wait for the avatar to update in the UI (observe header avatar image)
    const headerImg = page.locator('img[data-slot="avatar-image"]').first();
    await expect(headerImg).toBeVisible();
    await expect(headerImg).toHaveAttribute('src', /avatar|avatar/);
    const headerSrc = await headerImg.getAttribute('src');
    const headerBase = headerSrc ? headerSrc.split('?')[0] : null;

    // Verify that forum entry avatar updates when navigating to forum page
    await page.goto('/dashboard/forum');
    // Wait for a thread card, then check the first thread avatar image
    await page.waitForSelector('article');
    const threadAvatar = page.locator('article img[data-slot="avatar-image"]').first();
    const threadSrc = await threadAvatar.getAttribute('src');
    if (headerBase && threadSrc) {
      expect(threadSrc.includes(headerBase)).toBeTruthy();
    } else {
      await expect(threadAvatar).toHaveAttribute('src', /avatar/);
    }
  });
});
