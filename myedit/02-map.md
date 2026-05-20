# 02 — Map

Goal: persist discovery findings to `.myvibe/PROJECT-MAP.md` so future runs are fast and consistent.

## Where it lives

`.myvibe/PROJECT-MAP.md` at the repo root. Create the `.myvibe/` directory if missing. Add `.myvibe/` to `.gitignore` if the user prefers (default: commit it — it helps the team).

## Template

```markdown
# Project Map

_Last updated: <ISO date> at commit <short SHA>_

## Stack
- Language:
- Package manager:
- Framework:
- Database:
- Test runner:
- Lint:
- Format:
- Typecheck:

## Commands
- Install:
- Dev:
- Test (all):
- Test (one file):
- Lint:
- Typecheck:
- Build:

## Entry points
- App entry:
- API entry:
- Tests entry:

## Source layout
- <dir> — <one-line purpose>
- ...

## Conventions
- Naming:
- Imports:
- Error handling:
- Async style:
- Test style:
- AI agent rules: <link to AGENTS.md / CLAUDE.md / etc, or "none">

## External services
- <name> — <purpose> — <where it's configured>

## Known constraints
- <constraint 1>
- ...
```

## Rules

- Fill every section. If a section is N/A, write "none" — do not delete.
- Keep entries terse. One line each where possible.
- If the map already exists and HEAD commit equals the "Last updated" SHA, reuse — do not rewrite.
- If structure changes during apply phase, update the map at the end.

## What not to do

- Do not invent fields. Stick to the template.
- Do not document things you didn't actually verify.
- Do not include secrets, tokens, or env values.
