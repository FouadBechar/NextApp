import { test, expect } from '@playwright/test';

test('signup email availability - already registered blocks submit and server 409 is shown', async ({ page }) => {
  await page.goto('/auth/signup');
  await page.waitForLoadState('networkidle');

  const emailInput = page.getByPlaceholder('you@example.com');
  const submitButton = page.getByRole('button', { name: /create account/i });

  // Mock the email-availability endpoint to return unavailable
  await page.route('**/api/auth/email-availability**', (route) => route.fulfill({ status: 200, body: JSON.stringify({ available: false }), headers: { 'content-type': 'application/json' } }));

  await emailInput.click();
  await emailInput.fill('already@exists.test');
  // Wait for checking to finish and message to appear
  await page.waitForSelector('text=That email is already registered');
  await expect(submitButton).toBeDisabled();

  // Now simulate server response on submit with 409 and an error
  await page.route('**/api/resend**', (route) => route.fulfill({ status: 409, body: JSON.stringify({ error: { code: 'EMAIL_IN_USE', message: 'That email is already registered' } }), headers: { 'content-type': 'application/json' } }));

  // Fill in the rest of the form (username, password, confirm)
  await page.getByPlaceholder('yourusername').fill('testuser');
  await page.getByPlaceholder('••••••••').first().fill('Password123');
  await page.getByPlaceholder('••••••••').nth(1).fill('Password123');

  // Make sure the submit button remains disabled due to email not available
  await expect(submitButton).toBeDisabled();

  // Now change mocked email-availability to available and fill again
  await page.unroute('**/api/auth/email-availability**');
  await page.route('**/api/auth/email-availability**', (route) => route.fulfill({ status: 200, body: JSON.stringify({ available: true }), headers: { 'content-type': 'application/json' } }));

  await emailInput.fill('new@example.test');
  // Wait for the available message
  await page.waitForSelector('text=Email available');
  // Ensure submit is enabled now
  await expect(submitButton).toBeEnabled();

  // Setup resend to return 409 again to ensure server error handling on submit
  await page.unroute('**/api/resend**');
  await page.route('**/api/resend**', (route) => route.fulfill({ status: 409, body: JSON.stringify({ error: { code: 'EMAIL_IN_USE', message: 'That email is already registered' } }), headers: { 'content-type': 'application/json' } }));

  // Submit form
  await submitButton.click();
  // Wait for the server error alert to appear with our message
  await page.waitForSelector('text=That email is already registered');
});
