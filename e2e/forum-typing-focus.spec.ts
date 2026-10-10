import { test, expect } from '@playwright/test';

// Simple test to ensure continuous typing in the DiscussionForum title input
// does not lose focus during typing (regression for broken focus behavior).

test('typing in thread title should not lose focus', async ({ page }) => {
  await page.goto('/');
  await page.waitForLoadState('networkidle');

  const titleInput = page.getByPlaceholder('Thread title');
  await titleInput.click();
  // Type with a small delay and check focus after each character
  const text = 'Continuous typing test 123';
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    await titleInput.type(char, { delay: 50 });
    // After typing char, assert focus remains on the input and value includes typed prefix
    await expect(titleInput).toBeFocused();
    // Check captured value
    const value = await titleInput.inputValue();
    expect(value).toBe(text.slice(0, i + 1));
  }
});
