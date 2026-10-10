import { test, expect } from '@playwright/test';

// Test that the signup username validation shows pattern message and disables submit

test('signup username validation - invalid characters show message and disables submit', async ({ page }) => {
  await page.goto('/auth/signup');
  await page.waitForLoadState('networkidle');

  const usernameInput = page.getByPlaceholder('yourusername');
  const submitButton = page.getByRole('button', { name: /create account/i });

  // invalid characters
  await usernameInput.click();
  await usernameInput.type('bad*name');
  // should show validation message from schema
  const message = page.locator('text=Username may only contain letters, numbers and underscores');
  await expect(message).toBeVisible();

  // submit should be disabled
  await expect(submitButton).toBeDisabled();
});
