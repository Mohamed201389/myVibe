# 01 — Discover

Goal: build an accurate mental model of the existing project without writing anything yet.

## Detect language + package manager

Look for these files at the repo root (in order). The first match wins:

| File | Language | Package manager | Test runner hint |
|---|---|---|---|
| `package.json` | JS/TS | npm / pnpm / yarn / bun | check `scripts.test` |
| `pyproject.toml` | Python | uv / poetry / pip | check `[tool.pytest]` |
| `requirements.txt` | Python | pip | usually `pytest` |
| `go.mod` | Go | go modules | `go test` |
| `Cargo.toml` | Rust | cargo | `cargo test` |
| `composer.json` | PHP | composer | check `scripts.test` |
| `Gemfile` | Ruby | bundler | usually `rspec` or `rake test` |
| `pubspec.yaml` | Dart/Flutter | pub | `flutter test` |

For JS/TS: detect package manager by lockfile (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`).
For Python: prefer `uv` if `uv.lock` exists, else `poetry.lock`, else pip.

## Detect framework

Scan dependencies and config files:

- **React / Next.js / Vite / Remix** — `package.json` deps + `next.config.*` / `vite.config.*`
- **Vue / Nuxt** — `vue` dep + `nuxt.config.*`
- **Svelte / SvelteKit** — `svelte.config.*`
- **Angular** — `angular.json`
- **Django** — `manage.py` + `settings.py`
- **FastAPI / Flask** — imports in main entry
- **Express / Fastify / Hono / NestJS** — deps
- **Rails** — `config/application.rb`
- **Laravel** — `artisan`
- **Spring Boot** — `pom.xml` / `build.gradle`

## Detect lint + format

Check for: `.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `biome.json`, `ruff.toml` / `[tool.ruff]`, `.flake8`, `.golangci.yml`, `rubocop.yml`, `.editorconfig`.

## Detect entry points

- JS/TS: `package.json` `main` / `module` / `exports`, then `scripts.dev` / `scripts.start`
- Python: `pyproject.toml` `[project.scripts]`, then look for `main.py` / `app.py` / `manage.py`
- Go: `cmd/*/main.go` or root `main.go`
- Rust: `src/main.rs` or `src/lib.rs`

## Detect test layout

- `tests/` or `test/` or `__tests__/` directories
- Files matching `*.test.*` / `*.spec.*` / `test_*.py`
- Read `scripts.test` (JS) or `[tool.pytest]` (Py) for the canonical command

## Detect conventions

Open and skim:
- `README.md` — what the project does, how to run it
- `CONTRIBUTING.md` if present — coding rules
- `AGENTS.md` / `CLAUDE.md` / `.cursor/rules` / `.windsurfrules` if present — AI agent rules **must be obeyed**
- The largest 2-3 source files in the main source dir — to internalize naming, formatting, comment style

## Detect run + build commands

Capture exact commands for:
- Install dependencies
- Run dev server
- Run tests (all + single file + watch)
- Lint
- Typecheck (if applicable)
- Build

## Output

Hold all of this in working memory. Move to `02-map.md` to persist it.

## What to refuse

- Do not run install / build / test commands yet — discovery is read-only.
- Do not modify any file in this phase.
- Do not ask the user clarifying questions yet — exhaust discovery first.
