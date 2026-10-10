import { test, expect } from '@playwright/test';

test.describe('Kebab Menu keyboard navigation', () => {
  test('open menu, keyboard nav, and delete confirm flow', async ({ page }) => {
    const E2E_EMAIL = process.env.E2E_TEST_EMAIL;
    const E2E_PASSWORD = process.env.E2E_TEST_PASSWORD;
    if (!E2E_EMAIL || !E2E_PASSWORD) {
      test.skip(true, 'No E2E credentials set');
      return;
    }

    // login
    await page.goto('/auth/login');
    await page.fill('input[name="email"]', E2E_EMAIL);
    await page.fill('input[name="password"]', E2E_PASSWORD);
    await page.click('button[type=submit]');
    await page.waitForURL('**/dashboard', { timeout: 10000 });

    // create a thread to act on
    await page.goto('/dashboard/forum');
    const title = `E2E Menu Test ${Date.now()}`;
    const body = 'Testing kebab menu delete flow via keyboard';
    await page.fill('input[placeholder="Thread title"]', title);
    await page.fill('textarea[placeholder="Start a discussion..."]', body);
    await page.click('button:has-text("Start Thread")');
    const article = page.locator('article', { hasText: title }).first();
    await expect(article).toBeVisible();

    // open the menu in the same article
    const menuBtn = article.getByRole('button', { name: 'Thread actions' });
    await menuBtn.click();
    // menu items should include Edit, Pin, Report, Delete
    await expect(page.getByText('Edit')).toBeVisible();
    await expect(page.getByText('Pin')).toBeVisible();
    await expect(page.getByText('Report')).toBeVisible();
    // Try to open the Edit modal using keyboard navigation (ArrowDown)
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');
    await expect(page.getByPlaceholder('Thread title')).toBeVisible();
    // Close the modal cancel button
    await page.getByRole('button', { name: 'Cancel' }).click();

    // open the menu again and proceed to Delete flow
    await menuBtn.click();
    // keyboard navigation: ArrowDown then Enter to activate Delete
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');

    // Wait for confirm modal and click Delete
    const confirmModal = page.getByText('Delete this thread?');
    await expect(confirmModal).toBeVisible();
    const confirmDelete = confirmModal.locator('button', { hasText: 'Delete' }).first();
    await confirmDelete.click();

    // the article should be removed after deletion
    await page.waitForSelector(`article:has-text("${title}")`, { state: 'detached' });
  });

  test('Escape closes menu and returns focus to trigger', async ({ page }) => {
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

    // ensure we have a thread to act on
    await page.goto('/dashboard/forum');
    const title = `E2E Menu Focus Test ${Date.now()}`;
    const body = 'Testing focus return on Escape';
    await page.fill('input[placeholder="Thread title"]', title);
    await page.fill('textarea[placeholder="Start a discussion..."]', body);
    await page.click('button:has-text("Start Thread")');
    const article = page.locator('article', { hasText: title }).first();
    await expect(article).toBeVisible();

    const menuBtn = article.getByRole('button', { name: 'Thread actions' });
    await menuBtn.focus();
    await page.keyboard.press('Enter');
    // menu should open and first item should be focused
    // Close with Escape
    await page.keyboard.press('Escape');
    await expect(menuBtn).toBeFocused();
  });
});
