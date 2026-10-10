Migration policy for this repository
=================================

- `scripts/migrations/` contains original schema creation scripts (one-off create scripts used for initial provisioning).
- `db/migrations/` contains incremental ALTER migrations that should be applied in order (patches, adds, schema fixes).

When adding a new table, prefer adding the CREATE script in `scripts/migrations/` and then only use `db/migrations/` for ALTER/patches. If a prior create exists, avoid duplicating it in `db/migrations`.

If you need to change an existing table structure that is already in production, add a new ALTER migration in `db/migrations` rather than editing existing files.
