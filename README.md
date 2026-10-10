# NextApp

NextApp is a Next.js 16 application built with the App Router and Turbopack. The project includes authentication flows, a user dashboard, forum APIs, contact and email features, chat widget configuration, and automated sitemap generation for search engines.

## Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Environment Variables](#environment-variables)
- [Available Scripts](#available-scripts)
- [Sitemap Generation](#sitemap-generation)
- [Local Network Development](#local-network-development)
- [CI and GitHub Actions Secrets](#ci-and-github-actions-secrets)
- [Chat Model Configuration](#chat-model-configuration)
- [Tech Stack](#tech-stack)

## Features

- Next.js 16 App Router application
- Supabase-backed auth and server-side integrations
- Dashboard, profile, settings, and activity endpoints
- Forum thread and post APIs
- Chat widget with configurable default model
- Automatic sitemap generation during production builds
- Playwright end-to-end tests and Vitest unit tests

## Quick Start

1. Install dependencies:

```bash
npm install
```

2. Create a local environment file:

```bash
cp .env.example .env.local
```

3. Add the required values to `.env.local`.

4. Start the development server:

```bash
npm run dev
```

5. Open `http://localhost:3000`.

## Project Structure

These directories are the main places to look when working in the repo:

- `app/`: App Router pages, layouts, and API routes
- `components/`: reusable UI components
- `cli/`: command-line entry points, including the sitemap CLI
- `lib/`: generated files and shared internal utilities
- `scripts/`: maintenance and build-time scripts
- `utils/`: supporting helpers such as Supabase utilities
- `e2e/`, `test/`, `tests/`: automated test coverage
- `docs/`: architecture and contributor documentation
- `public/`: static assets, including generated sitemap files

For a developer-facing overview of app structure, auth flow, and supabase integrations, see `docs/architecture.md`.

## Environment Variables

### Common local variables

These are the most important variables for local development and builds:

```bash
NEXT_PUBLIC_SITE_URL=https://your-site.example
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
REDIS_URL=redis://:password@hostname:6379
```

If you use Upstash, set `REDIS_URL` to the connection string provided by Upstash.

### Development-only helpers

Use `ALLOWED_DEV_ORIGINS` when testing the site from another device on your local network:

```bash
ALLOWED_DEV_ORIGINS=http://localhost:3000,http://192.168.100.3:3000
```

Enable client-side chat debug logging locally with:

```bash
NEXT_PUBLIC_CHAT_DEBUG=true
```

### Important notes

- Do not commit secrets.
- Do not set `NODE_ENV=production` in `.env.local`.
- `NEXT_PUBLIC_SUPABASE_SRK` exists in the codebase as a fallback, but `SUPABASE_SERVICE_ROLE_KEY` is the preferred secure configuration.

## Available Scripts

- `npm run dev`: starts the local Next.js development server
- `npm run build`: creates a production build and automatically generates the sitemap in `postbuild`
- `npm run start`: starts the production server after a build
- `npm run test:unit`: runs unit tests with Vitest
- `npm run test:e2e`: runs end-to-end tests with Playwright
- `npm run sitemap`: runs the sitemap generator using environment variables
- `npm run sitemap:cli`: runs the CLI wrapper for the sitemap generator with explicit arguments

Example:

```bash
npm run sitemap:cli -- --site=https://example.com --input=public/pages.json
```

## Sitemap Generation

This project generates `public/sitemap.xml` and `public/sitemap.xml.gz` for search engines.

### Automatic generation

The sitemap is generated automatically after a production build:

```bash
npm run build
```

The script reads `NEXT_PUBLIC_SITE_URL` from your environment or `.env.local`.

### Manual generation

Run the script directly:

```bash
npm run sitemap
```

Run the CLI shortcut with explicit arguments:

```bash
npm run sitemap:cli -- --site=https://example.com --input=public/pages.json
```

You can also use the package bin entry directly after linking or through npm execution:

```bash
next-sitemap-gen --site=https://example.com --input=public/pages.json
```

## Local Network Development

When you open the dev server from another device on your local network, Next.js may warn about cross-origin requests to `/_next/*`. To allow those requests during development, add the visiting origins to `ALLOWED_DEV_ORIGINS` in `.env.local`.

The project reads this variable in `next.config.ts` during development.

## CI and GitHub Actions Secrets

The Playwright workflow expects repository secrets to be configured in GitHub. Add these in your repository settings rather than committing them:

- `NEXT_PUBLIC_SITE_URL` as a repository variable or secret if you want CI builds to generate `sitemap.xml`
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `NEXT_PUBLIC_SUPABASE_SRK`
- `SUPABASE_SERVICE_ROLE_KEY`
- `RESEND_API_KEY`
- `NEXT_PUBLIC_RECAPTCHA_SITE_KEY`
- `RECAPTCHA_SECRET`
- `ADMIN_BROADCAST_TOKEN`

If any secret is ever exposed, rotate it immediately and remove it from repository history.

For security process guidance and disclosure instructions, see `SECURITY.md`.

## Chat Model Configuration

This project uses an external chat backend at `https://chat-779e.onrender.com/chat`.

To request a specific default model for all clients, set:

```bash
NEXT_PUBLIC_CHAT_DEFAULT_MODEL=claude-haiku-4.5
```

The backend must support that model identifier or map it correctly on the server side.

## Tech Stack

- Next.js 16
- React 19
- TypeScript
- Supabase
- Playwright
- Vitest

## Contributing Notes

- Keep secrets in environment variables, not in committed files.
- Prefer updating generated assets through their scripts rather than manual edits.
- If you change sitemap behavior, verify both `npm run sitemap` and `npm run sitemap:cli`.
- If you change environment requirements, update this README and the example env files in the same change.

## Repository

Source: `https://github.com/FouadBechar/NextApp.git`
