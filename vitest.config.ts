import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    // Only run unit tests in `test`/`tests` folders; exclude Playwright E2E tests
    environment: 'node',
    globals: true,
    include: ['test/**/*.{test,spec}.{ts,tsx,js,jsx}', 'tests/**/*.{test,spec}.{ts,tsx,js,jsx}'],
    exclude: ['e2e/**', 'e2e/**/*'],
    coverage: {
      provider: 'v8',
    },
  },
});
