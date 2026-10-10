# Architecture Overview

## App Router structure

The project uses Next.js App Router with `app/` as the main entry point.

- `app/`: contains top-level pages, route layouts, and API routes.
- `app/api/`: server route handlers using Next.js route handlers.
- `app/auth/`: auth layouts and flows separate from public pages.
- `app/dashboard/`: protected dashboard pages and API routes.
- `app/(home)/`: marketing/home experience pages.

### Routes and pages

- Static pages use standard App Router pages and layouts.
- API routes are implemented under `app/api/<service>/route.ts`.
- Dynamic API segments use file names like `[threadId]` and `[postId]`.

## Auth flow

Authentication is built around Supabase and includes:

- Login, signup, reset-password, and 2FA flows in `app/auth/`.
- `app/api/auth/login-attempt/route.ts` for login rate limiting and attempt tracking.
- Routes under `app/auth/` are used to render auth pages and intermediate states.

### Key auth pieces

- `components/auth/login-form.tsx`: client form for login.
- `components/auth/signup-form.tsx`: signup form.
- `app/api/auth/login-attempt/route.ts`: rate-limit API for login attempts.
- Supabase utilities in `utils/supabase/` for session verification and helper methods.

## Data flow and Supabase

Supabase is the primary backend for authentication and data operations.

- `utils/supabase/client.ts`: shared Supabase client setup.
- `utils/supabase/verify-user.ts`: verifies auth tokens and session state.
- `utils/supabase/middleware.ts`: request middleware helpers.

Supabase is used for:

- user authentication and session validation
- storing forum threads and posts
- dashboard-related user data and profile activity

## External services

The app integrates with several external services:

- `Resend` email service for verification, password reset, and broadcast emails.
- `reCAPTCHA` to protect signup/login flows and form submissions.
- A chat backend at `https://chat-779e.onrender.com/chat` for chat widget interactions.

## Important project files

- `next.config.ts`: Next.js configuration and development origin handling.
- `tsconfig.json`: TypeScript config and path aliases.
- `package.json`: scripts, dependencies, and available commands.
- `scripts/generate-sitemap.mjs`: sitemap generation after build.

## Where to edit what

- Add a new page: edit or add a new `app/` page under the desired route.
- Add a new API endpoint: create `app/api/<name>/route.ts`.
- Add a new auth guard: implement middleware or use Supabase verification helpers in `utils/supabase/`.
- Change global styles: update `app/globals.css` or `app/globals2.css`.
- Add a new shared UI component: place it in `components/`.
- Add unit tests: use `tests/` and `test/` for API and utility coverage.
- Add end-to-end tests: use `e2e/` with Playwright scenarios.

## Recommended contribution flow

1. Create a feature branch.
2. Add or update tests for new behavior.
3. Run `npm run test:unit:run` locally.
4. Run `npm run build` to validate production output.
5. Open a PR and verify CI status.
