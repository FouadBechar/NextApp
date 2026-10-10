Backfill forum avatar URLs

This script pages through `profiles`, resolves avatar URLs, and writes denormalized
`author_avatar_url`, `author_avatar_path` and `author_display` into `forum_threads` and `forum_posts`, and
populates `profiles.avatar_url` when it's missing.

Why
- The app was updated to prefer a denormalized `author_avatar_url` on forum rows.
- This backfill populates existing rows so the UI shows correct avatars immediately.

Location
- Script: `scripts/backfill-forum-avatars.mjs`
- Migration to add columns: `db/migrations/002_add_author_avatar_url.sql` (must be applied first)

Prerequisites
- Node.js 16+ (supports ESM `.mjs`)
- `@supabase/supabase-js` installed: `npm install @supabase/supabase-js`
- Environment variables set:
  - `SUPABASE_URL` (e.g. `https://your-project.supabase.co`)
  - `SUPABASE_SERVICE_ROLE_KEY` (service role key; keep secret)
  - optional: `AVATAR_BUCKET` (defaults to `avatars`)

Safety features
- The script detects whether `author_avatar_url` exists on `forum_threads` and `forum_posts` using
  `information_schema.columns`. If missing, it aborts and instructs you to run the migration.
- Use `--dry-run` (or `-n`) to see planned updates without writing to the DB.
- Use `--force` (or `-f`) to bypass the column-existence check (not recommended).
  - When `--force` is provided, the script will also overwrite existing `profiles.avatar_url` values.

PowerShell examples

1) Install deps (if needed)

```powershell
npm install @supabase/supabase-js
```

2) Dry-run (recommended)

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "your-service-role-key"
# optional: $env:AVATAR_BUCKET = "avatars"
node .\scripts\backfill-forum-avatars.mjs --dry-run
```

3) Real run

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "your-service-role-key"
node .\scripts\backfill-forum-avatars.mjs
```

4) If you purposely want to attempt running without applying the migration (not recommended):

```powershell
$env:SUPABASE_URL = "https://your-project.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "your-service-role-key"
node .\scripts\backfill-forum-avatars.mjs --force
5) Overwrite existing `profiles.avatar_url` and update forum rows

```powershell
npm run backfill:profiles
```

This runs the script with `--force` and will overwrite existing `profiles.avatar_url` values with re-resolved URLs.
```

Verification
- Spot-check updated rows (both URL and storage path are written):

```sql
SELECT id, author_id, author_display, author_avatar_url, author_avatar_path
FROM forum_threads
WHERE author_id = '<some-user-id>'
LIMIT 5;

SELECT id, author_id, author_display, author_avatar_url, author_avatar_path
FROM forum_posts
WHERE author_id = '<some-user-id>'
LIMIT 5;
```

Notes
- If your avatars are stored in a different bucket, set `AVATAR_BUCKET`.
- Keep your service role key secure. Run this script from a trusted machine or CI with secrets.
- If you want, I can add a protected server-side endpoint to run this in your hosting environment.
