# Security Policy

## Reporting security issues

If you discover a security vulnerability in this project, please report it responsibly.

- Open a private GitHub security advisory if available.
- If security advisories are not available, open an issue and mark it as sensitive.
- Do not publish secrets, tokens, credentials, or personal data in public issue descriptions.

## What not to commit

Do not commit any secrets or credentials, including:

- API keys
- Database connection strings
- Redis URLs with passwords
- private keys and certificates
- `SUPABASE_SERVICE_ROLE_KEY`
- `RESEND_API_KEY`
- `RECAPTCHA_SECRET`
- any `NEXT_PUBLIC_*` secret values used only in server-side code

## Environment handling

Local environment files are ignored by git. Only example environment files should be committed.

- `.env` files are excluded via `.gitignore`
- `.env.example` and `.env.local.example` are allowed

## Rotation guidance

If a secret is exposed or committed accidentally:

1. Revoke the secret immediately.
2. Create a new secret/key.
3. Update the affected environment configuration.
4. Remove the secret from repository history if it was committed.
5. Regenerate any downstream credentials or tokens that may depend on the old secret.

## CI guardrails

This project includes automated CI checks to catch secrets and enforce ignored env files.

- Secrets are scanned during GitHub Actions runs.
- Local env files are validated to ensure they remain ignored.

## Contributor checklist

- [ ] No secrets are committed in code, logs, screenshots, or CI artifacts.
- [ ] `.env` files are ignored.
- [ ] Sensitive values are stored in GitHub Secrets or an equivalent vault.
- [ ] Any new secret-handling code documents where secrets should be configured.
