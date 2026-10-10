# E2E Tests

This folder contains Playwright end-to-end tests and accessibility checks.

## Run tests

- Run all tests (will use Playwright `webServer` to start/stop the app if configured):

```bash
npx playwright test
```

- Run tests with dev server (helper) — this will start dev server, run Playwright tests, then kill the server:

```bash
npm run test:e2e:serve
```

- Run Chromium-only tests:

```bash
npm run test:e2e:chromium
```

- Run tests in headed mode (open browser window):

```bash
npm run test:e2e:headed
```

- Run tests in debug mode (useful for pausing on failures):

```bash
npm run test:e2e:debug
```

## Environment Variables

- `E2E_TEST_EMAIL` — test user email; required for some tests.
- `E2E_TEST_PASSWORD` — test user password; required for some tests.
- `PLAYWRIGHT_BASE_URL` or `E2E_BASE_URL` — alternate base URL for tests (defaults to http://localhost:3000).

## Debugging

- To view traces when a test fails, run `npx playwright show-trace path/to/trace.zip` and follow the UI.
- If Playwright reports a server connection issue, ensure you can reach the server at `http://localhost:3000` or start it manually:

```powershell
npm run dev
npx playwright test
```

If you'd like me to add more debug aids (video artifacts, test output, or CI integration), I can add those next.
