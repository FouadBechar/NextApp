import type { Page } from "@playwright/test";

async function gotoWithRetries(
  page: Page,
  path: string,
  opts: { retries?: number; timeout?: number } = {}
) {
  const retries = opts.retries ?? 3;
  const timeout = opts.timeout ?? 120_000;
  let lastErr: unknown;

  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      await page.goto(path, { waitUntil: "networkidle", timeout });
      return;
    } catch (error) {
      lastErr = error;
      await page.waitForTimeout(1000 * (attempt + 1));
    }
  }

  throw lastErr;
}

export async function ensureE2EUser(page: Page) {
  const configuredEmail = process.env.E2E_TEST_EMAIL;
  const E2E_EMAIL = configuredEmail ?? `e2e+${Date.now()}@example.test`;
  const E2E_PASSWORD = process.env.E2E_TEST_PASSWORD ?? "P@ssw0rd!";

  if (configuredEmail) {
    await gotoWithRetries(page, "/auth/login");

    try {
      await page.getByPlaceholder("you@example.com").fill(E2E_EMAIL);
      await page.getByPlaceholder("••••••••").fill(E2E_PASSWORD);
      await page.getByRole("button", { name: /sign in/i }).click();
      await page.waitForURL("**/dashboard", { timeout: 10000 });
      return { email: E2E_EMAIL, password: E2E_PASSWORD, created: false };
    } catch {
      // Fall back to sign-up if the configured login path fails.
    }
  }

  await gotoWithRetries(page, "/auth/signup");

  let recaptchaRouteAdded = false;
  try {
    await page.route("**/api/recaptcha", async (route) => {
      recaptchaRouteAdded = true;
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ success: true, score: 0.9 }),
      });
    });
  } catch {
    // Ignore route registration failures and continue.
  }

  await page.getByPlaceholder("you@example.com").fill(E2E_EMAIL);
  await page.getByPlaceholder("yourusername").fill(`e2e_user_${Date.now()}`);
  await page.getByPlaceholder("••••••••").first().fill(E2E_PASSWORD);
  await page.getByPlaceholder("••••••••").nth(1).fill(E2E_PASSWORD);
  await page.getByRole("button", { name: /create account/i }).click();

  try {
    await page.waitForURL("**/dashboard", { timeout: 30000 });
  } catch {
    await page.waitForTimeout(2000);
    await page.waitForURL("**/dashboard", { timeout: 30000 });
  }

  if (recaptchaRouteAdded) {
    try {
      await page.unroute("**/api/recaptcha");
    } catch {
      // Ignore cleanup failures.
    }
  }

  return { email: E2E_EMAIL, password: E2E_PASSWORD, created: true };
}

export default ensureE2EUser;
