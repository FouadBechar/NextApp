# `fouad-next-sitemap-gen`

Small CLI package for generating `sitemap.xml` and `sitemap.xml.gz` for Next.js projects.

## Package and command

- npm package: `fouad-next-sitemap-gen`
- CLI command: `next-sitemap-gen`

## Install from npm

```bash
npm install -g fouad-next-sitemap-gen
next-sitemap-gen --site=example.com
```

## Update

```bash
npm install -g fouad-next-sitemap-gen@latest
next-sitemap-gen --version
```

## Install locally for development

```bash
cd tools/sitemap-cli
npm link
next-sitemap-gen --site=example.com
```

## Publish flow

```bash
cd tools/sitemap-cli
npm publish
```

## Usage

```bash
next-sitemap-gen --site=https://example.com
next-sitemap-gen --site=example.com --input=public/pages.json --out-dir=public
next-sitemap-gen --config=./sitemap.config.json
next-sitemap-gen --version
```

## `sitemap.config.json`

The CLI automatically reads `sitemap.config.json` from the current working directory if it exists. You can also point to a custom file with `--config=...`.

```json
{
  "site": "https://example.com",
  "input": "public/pages.json",
  "outDir": "public",
  "ignoreRoutes": ["/auth", "/api", "/admin", "/_", "/dashboard"],
  "defaults": {
    "changefreq": "weekly",
    "priority": 0.7
  },
  "rootEntry": {
    "enabled": true,
    "changefreq": "weekly",
    "priority": 1,
    "lastmod": "auto"
  }
}
```

You can also copy the published example file `sitemap.config.example.json` from the package.

## Options

- `--site`: Required unless `NEXT_PUBLIC_SITE_URL` is set.
- `--input`: Optional path to the JSON source file. Defaults to `public/pages.json`.
- `--out-dir`: Optional output directory. Defaults to `public`.
- `--config`: Optional path to a config file. Defaults to `./sitemap.config.json`.
- `--version`: Prints the installed CLI version.

## Expected `pages.json` format

```json
[
  {
    "url": "/privacy",
    "changefreq": "weekly",
    "priority": 0.7,
    "lastmod": "2026-04-07T12:00:00.000Z"
  }
]
```

## Notes

- Routes starting with `/auth`, `/api`, `/admin`, `/_`, and `/dashboard` are ignored.
- The CLI writes both `sitemap.xml` and `sitemap.xml.gz`.
- Passing `--site=example.com` is normalized to `https://example.com`.
- The tool reads and writes relative to the current working directory, so run it from your project root.
- Invalid entries in `pages.json` are skipped with warnings instead of crashing the whole generation.
- CLI flags take precedence over config values.
