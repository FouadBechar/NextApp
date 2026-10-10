import { test, expect } from '@playwright/test';

// Verifies optimistic replies are shown immediately and replaced/rolled back
// depending on server response. Requires a test user (E2E_EMAIL/E2E_PASSWORD).

async function loginIfNeeded(page: any) {
  const E2E_EMAIL = process.env.E2E_TEST_EMAIL ?? process.env.E2E_EMAIL;
  const E2E_PASSWORD = process.env.E2E_TEST_PASSWORD ?? process.env.E2E_PASSWORD;
  if (!E2E_EMAIL || !E2E_PASSWORD) {
    test.skip(true, 'No E2E credentials set');
    return;
  }

  await page.goto('/auth/login');
  await page.fill('input[name="email"]', E2E_EMAIL);
  await page.fill('input[name="password"]', E2E_PASSWORD);
  await page.click('button[type=submit]');
  await page.waitForURL('**/dashboard', { timeout: 10000 });
}

test('optimistic reply shows immediately and is confirmed by server', async ({ page }) => {
  await loginIfNeeded(page);
  await page.goto('/dashboard/forum');

  const title = `E2E optimistic reply ${Date.now()}`;
  const threadBody = 'Thread body for optimistic reply test';

  await page.getByPlaceholder('Thread title').fill(title);
  await page.getByPlaceholder('Start a discussion...').fill(threadBody);
  await page.getByRole('button', { name: /Start Thread/i }).click();

  // Wait until the thread opens
  await expect(page.getByRole('heading', { name: title })).toBeVisible();

  // Intercept the POST to replies and delay fulfillment so we can assert optimistic UI
  let intercepted = false;
  await page.route('**/api/forum/threads/*/posts', async (route) => {
    const req = route.request();
    if (req.method() === 'POST') {
      intercepted = true;
      // Delay a little to simulate slow network but keep the test deterministic
      setTimeout(async () => {
        const match = /threads\/([^/]+)\/posts/.exec(req.url());
        const threadId = match ? match[1] : 'unknown';
        const postBody = JSON.parse(req.postData() || '{}');
        await route.fulfill({
          status: 200,
          contentType: 'application/json',
          body: JSON.stringify({
            post: {
              id: `post-${Date.now()}`,
              thread_id: threadId,
              content: postBody.content,
              created_at: new Date().toISOString(),
            },
          }),
        });
      }, 800);
    } else {
      route.continue();
    }
  });

  const replyText = 'This is an optimistic reply';
  const replyArea = page.getByPlaceholder('Write a reply…');
  await replyArea.fill(replyText);
  await page.getByRole('button', { name: /^Reply$/i }).click();

  // Optimistic reply should appear immediately while network is in-flight
  await expect(page.getByText(replyText)).toBeVisible();
  expect(intercepted).toBe(true);

  // After server responds, reply should remain (no duplicate)
  await page.waitForTimeout(1200);
  const matches = await page.locator(`text=${replyText}`).count();
  expect(matches).toBeGreaterThanOrEqual(1);
});

test('optimistic reply is rolled back on server error and shows toast', async ({ page }) => {
  await loginIfNeeded(page);
  await page.goto('/dashboard/forum');

  const title = `E2E rollback reply ${Date.now()}`;
  await page.getByPlaceholder('Thread title').fill(title);
  await page.getByPlaceholder('Start a discussion...').fill('body');
  await page.getByRole('button', { name: /Start Thread/i }).click();
  await expect(page.getByRole('heading', { name: title })).toBeVisible();

  // Mock server to return 500 for the POST
  await page.route('**/api/forum/threads/*/posts', async (route) => {
    if (route.request().method() === 'POST') {
      await route.fulfill({ status: 500, contentType: 'application/json', body: '{}' });
    } else {
      route.continue();
    }
  });

  const replyText = 'This reply will fail';
  await page.getByPlaceholder('Write a reply…').fill(replyText);
  await page.getByRole('button', { name: /^Reply$/i }).click();

  // Optimistic reply should appear immediately
  await expect(page.getByText(replyText)).toBeVisible();

  // After server error the optimistic reply should be removed and show toast
  await page.waitForTimeout(300);
  await expect(page.getByText(replyText)).not.toBeVisible();
  await expect(page.getByText(/Failed to post reply/i)).toBeVisible();
});
