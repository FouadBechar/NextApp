# `fouad-env-guardian`

CLI tool to scan projects for unsafe `.env` practices and likely secret-like variable names.

## Package and command

- npm package: `fouad-env-guardian`
- CLI command: `env-guardian`

## Install from npm

```bash
npm install -g fouad-env-guardian
env-guardian
```

## Usage

```bash
env-guardian
env-guardian --path=./my-project
env-guardian --version
env-guardian --help
```

## What it checks

- Whether `.env` exists
- Whether `.env` is tracked by git
- Whether `.env.example` exists
- Whether `.env` contains common secret-like variable names such as `API_KEY`, `SECRET`, `TOKEN`, `PASSWORD`, or `PRIVATE_KEY`

## Example output

```text
Env Guardian Report

Project: C:\my-project
- .env exists: yes
- .env tracked by git: yes
- .env.example exists: no
- secret-like keys found: API_KEY, TOKEN

Warnings:
- The .env file is tracked by git.
- Missing .env.example.
- Potential secret variable detected: API_KEY
- Potential secret variable detected: TOKEN
```

## Notes

- Run the command from the project root you want to inspect.
- You can also scan another directory with `--path=...`.
- The tool exits with a non-zero code when warnings are found, which makes it useful in CI.
- Detection is intentionally conservative and should be treated as a warning signal, not proof of a leak or exposed secret.

## Roadmap

- Auto-fix suggestions for `.gitignore`
- Framework-aware checks for Next.js, Vite, and similar tools
- Configurable secret patterns and ignore rules
- CI examples and GitHub Actions integration
