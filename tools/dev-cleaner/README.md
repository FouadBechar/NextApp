# `fouad-dev-cleaner`

Clean project dependencies, build output, and caches with one command.

## Package and command

- npm package: `fouad-dev-cleaner`
- CLI command: `dev-clean`

## Install

```bash
npm install -g fouad-dev-cleaner
dev-clean --help
```

## Usage

```bash
dev-clean
dev-clean --dry-run
dev-clean --path "C:\\my-project"
dev-clean --force
dev-clean --help
```

## What it removes

- `node_modules`
- `dist`
- `build`
- `.next`
- `.cache`
- `coverage`

## Safety

- Refuses to clean a directory unless it looks like a project root
- Use `--dry-run` to preview removals without deleting anything
- Use `--path` to target a specific project directory
- Use `--force` to bypass the project-root safety check

## Example output

```text
Dev Cleaner

Target: C:\work\demo-app
Would remove: node_modules
Would remove: .next
```
