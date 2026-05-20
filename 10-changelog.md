# 10 — Changelog

The changelog is the project's memory. It tells future-you (and any new collaborator or AI session) what happened, when, and why.

---

## Where it lives

`CHANGELOG.md` at the project root. Always.

---

## Format

Follow **Keep a Changelog** + **Semantic Versioning** conventions.

```markdown
# Changelog

All notable changes to this project are documented here.
The format is based on Keep a Changelog. This project adheres to Semantic Versioning.

## [Unreleased]

### Added
- Card drag-and-drop between columns
- Inline card title editing

### Changed
- Board list now sorts by `updatedAt` descending

### Fixed
- Empty board title no longer crashes the create flow

## [0.3.0] — 2026-05-19

### Added
- Column CRUD (create, rename, reorder, delete)
- Card creation via inline editor

### Changed
- Migrated from in-memory store to SQLite via Prisma

## [0.2.0] — 2026-05-18

### Added
- Board CRUD endpoints (POST/GET/PATCH/DELETE /boards)
- Board list page with search filter

## [0.1.0] — 2026-05-17

### Added
- Initial scaffold: Vite + React 19 + TypeScript + Tailwind + Fastify + Prisma
- Health endpoint
- Landing placeholder page
```

---

## Sections (Keep a Changelog standard)

Within each version, group entries under these headers, in this order:

- **Added** — new features
- **Changed** — changes to existing functionality
- **Deprecated** — features marked for removal
- **Removed** — features deleted
- **Fixed** — bug fixes
- **Security** — vulnerability patches

Omit any section that's empty for that version. Don't write "N/A" or "None".

---

## Versioning rules (SemVer)

`MAJOR.MINOR.PATCH`

- **MAJOR (X.0.0)** — breaking changes (API contract, schema, behavior)
- **MINOR (0.X.0)** — new features, no breaking changes
- **PATCH (0.0.X)** — bug fixes, performance, docs

Pre-1.0 projects: bump MINOR for everything except patch fixes. Save MAJOR for the 1.0.0 launch.

---

## When to write entries

**At every checkpoint.** Don't batch. Don't backfill at the end of the day. Write while the change is fresh.

For multi-step features, write one entry under `[Unreleased]` as you ship each piece. When you bump a version, those entries graduate from `[Unreleased]` to the new version block with the date.

---

## How to write a good entry

Each entry is one line. Subject + concrete result. Past tense.

**Good:**
- "Card drag-and-drop persists position to SQLite"
- "Board list filter no longer loses focus on each keystroke"
- "Migrated API validation from yup to Zod"

**Bad:**
- "Improvements" — improvements to what?
- "Fixed bug" — which bug?
- "Updated styles" — meaningless
- "Various changes" — never
- "WIP" — never goes in changelog

---

## Linking commits/PRs (optional)

If your workflow uses PRs, append `(#42)`:
```
- Card drag-and-drop persists position to SQLite (#42)
```
For solo localhost work without PRs, skip the references.

---

## Releases

When you cut a version:
1. Move everything from `[Unreleased]` to a new `[X.Y.Z] — YYYY-MM-DD` block.
2. Bump the version in `package.json`.
3. Create a git tag: `git tag v0.3.0 && git push --tags`
4. Leave `[Unreleased]` empty at the top — ready for the next cycle.

For localhost-only projects without published artifacts, tagging is still useful for "this is what shipped in the demo".

---

## Anti-patterns

- Writing the changelog only at release time → entries get vague, items get forgotten
- Including internal refactors in `Added` → they go in `Changed`
- Marketing copy ("Exciting new features!") → no, just facts
- Emojis → no
- "Improved performance" without specifics → say what, by how much if measured
- Combining 6 commits into one entry → break them out
- Listing every file changed → describe the *behavior* that changed, not the files

---

## Special entries

### Scope changes
When you change the plan mid-build:
```
### Changed
- scope: dropped real-time collaboration from v1 (deferred to v1.1)
- scope: switched persistence from localStorage to SQLite for multi-tab consistency
```

### Stack changes
```
### Changed
- stack: replaced React-Beautiful-DnD with @dnd-kit (better React 19 support)
```

### Decisions worth recording
```
### Added
- design decision: cards store float position for O(1) inserts; rebalance not needed at expected scale
```

---

## A complete example for a Kanban project

```markdown
# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- Card labels (colored tags)

## [0.5.0] — 2026-05-22

### Added
- Card drag-and-drop with optimistic UI updates
- Cards persist position on reorder

### Fixed
- Empty column no longer collapses height to 0

## [0.4.0] — 2026-05-20

### Added
- Card creation via inline editor (Enter to save, Esc to cancel)
- Card deletion with undo toast (5s window)

### Changed
- Column header now shows card count

## [0.3.0] — 2026-05-19

### Added
- Column CRUD: create, rename, reorder, delete

## [0.2.0] — 2026-05-18

### Added
- Board CRUD (POST/GET/PATCH/DELETE /boards)
- Board list page

### Changed
- Migrated from in-memory to SQLite + Prisma

## [0.1.0] — 2026-05-17

### Added
- Project scaffold (Vite + React 19 + TypeScript + Tailwind + Fastify + Prisma)
- Health endpoint
- Landing page
```

That's the standard. Follow it.
