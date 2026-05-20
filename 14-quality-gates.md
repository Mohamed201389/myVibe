# 14 — Quality Gates

The final checklist. Before you tell the user "it's done", every single box below must be checked. If even one fails, you're not done.

This is non-negotiable. The whole kit exists to make sure projects clear this bar.

---

## Quality gate categories

```
1. Build & start
2. Tests
3. Lint, format, types
4. Functional verification
5. UX states
6. Accessibility
7. Performance
8. Code hygiene
9. Documentation
10. Handover readiness
```

---

## 1. Build & start

- [ ] `git status` shows no uncommitted changes
- [ ] `npm install` on a fresh clone succeeds with no errors
- [ ] `npm run build` succeeds with zero errors and zero warnings
- [ ] `npm run dev` starts cleanly (no port collisions, no missing env)
- [ ] App loads at `http://localhost:PORT` within 3 seconds
- [ ] No errors in the browser console on initial load
- [ ] No errors in the server log on initial load

## 2. Tests

- [ ] `npm test` — every test passes
- [ ] No `it.skip` or `it.only` in committed test files
- [ ] No commented-out tests
- [ ] Every must-have feature has at least one test
- [ ] Test coverage isn't artificially low (use judgment — 80%+ on lib utilities, every endpoint has happy + error path)
- [ ] E2E suite (if exists) passes — `npm run test:e2e`

## 3. Lint, format, types

- [ ] `npm run lint` — zero warnings, zero errors
- [ ] `npm run typecheck` (or `tsc --noEmit`) — zero errors
- [ ] `npm run format` (or `prettier --check .`) — passes
- [ ] No `// @ts-ignore` or `// @ts-expect-error` without an explanatory comment
- [ ] No `any` in code except where intentionally documented
- [ ] No `console.log` left over from debugging (use a logger if you need runtime logs)

## 4. Functional verification

Walk through every must-have feature manually:

- [ ] Create flow works
- [ ] Read flow works (lists, detail pages)
- [ ] Update flow works (and persists on refresh)
- [ ] Delete flow works (and stays deleted on refresh)
- [ ] Search/filter (if applicable) works
- [ ] Drag-and-drop / reorder (if applicable) works and persists
- [ ] Forms validate correctly (try invalid input)
- [ ] Forms submit successfully with valid input
- [ ] Page refresh preserves state where it should

## 5. UX states (the four every screen must handle)

For every primary screen:

- [ ] **Empty state** — meaningful illustration / CTA, not just a blank page
- [ ] **Loading state** — skeletons or progress indicators, not just blank waiting
- [ ] **Error state** — readable error message + retry path
- [ ] **Success state** — populated, working version

Specifically check:
- [ ] First-time user (no data) experience is welcoming, not confusing
- [ ] What happens if the API returns 500? (You can simulate by stopping the backend)
- [ ] What happens if the user goes offline? (Disable network in DevTools)

## 6. Accessibility

- [ ] Tab key navigates through every interactive element in logical order
- [ ] Focus ring is visible on every focusable element
- [ ] All form inputs have labels (`<label htmlFor>` or `aria-label`)
- [ ] All icon-only buttons have `aria-label`
- [ ] All images have meaningful `alt` text (or `alt=""` if decorative)
- [ ] Color contrast ≥ 4.5:1 for body text, ≥ 3:1 for large text
- [ ] No reliance on color alone to convey meaning
- [ ] Headings in correct hierarchy (one `<h1>`, then `<h2>`s, then `<h3>`s)
- [ ] `prefers-reduced-motion` respected — animations have a static fallback
- [ ] Modals trap focus and restore on close
- [ ] Screen reader can announce all critical interactions (test with VoiceOver/NVDA at least once)

Run `axe-core` (via Playwright or the browser extension) on every primary screen — zero violations of `serious` or `critical` severity.

## 7. Performance

For web projects:

- [ ] Lighthouse desktop score ≥ 90 Performance
- [ ] Lighthouse mobile score ≥ 80 Performance
- [ ] First Contentful Paint < 1.5s (dev server is fine for assessment)
- [ ] Largest Contentful Paint < 2.5s
- [ ] Cumulative Layout Shift < 0.1
- [ ] Interaction to Next Paint < 200ms
- [ ] Main JS bundle < 250KB gzipped
- [ ] No images > 500KB
- [ ] Fonts use `font-display: swap`
- [ ] Heavy routes are lazy-loaded

For backend:
- [ ] p50 response time < 100ms for read endpoints (local)
- [ ] p99 response time < 300ms for read endpoints (local)
- [ ] No N+1 query patterns (check with Prisma's `log: ['query']`)
- [ ] Health endpoint responds < 50ms

## 8. Code hygiene

- [ ] No commented-out code
- [ ] No TODO comments without an issue link or date
- [ ] No unused imports (linter should catch)
- [ ] No unused exports
- [ ] No duplicate code blocks (DRY where it makes sense — not over-DRY)
- [ ] No files longer than ~400 lines (unless justified)
- [ ] No functions longer than ~50 lines
- [ ] No magic numbers — extract constants with named meaning
- [ ] No hardcoded URLs to external services without env vars
- [ ] Folder structure matches `03-scaffolding.md` conventions

## 9. Documentation

- [ ] `README.md` exists and includes:
  - One-paragraph project description
  - Prerequisites (Node version, Docker if needed)
  - Install + run commands
  - Test command
  - Env vars list (or pointer to `.env.example`)
  - License (or "All rights reserved")
- [ ] `.env.example` is committed and matches the actual required env vars
- [ ] `PLAN.md` exists and reflects what shipped (update if scope changed)
- [ ] `FEATURES.md` exists, all must-haves marked complete
- [ ] `CHANGELOG.md` exists and has entries for every checkpoint
- [ ] Each `features/<name>.md` is in `Complete` status with checked acceptance criteria

## 10. Handover readiness

- [ ] A new contributor can clone the repo and run it in under 5 minutes
- [ ] No "tribal knowledge" required — everything's in the docs
- [ ] No dependency on the original author's local machine state
- [ ] No secrets committed (search the repo for `password`, `secret`, `key` to verify)
- [ ] `.gitignore` covers: `node_modules`, `dist`, `.env`, DB files, IDE configs, OS junk
- [ ] All test data and fixtures are in the repo (or seedable via `db:seed`)

---

## Self-audit script

You can automate part of this. Create `scripts/audit.sh`:

```bash
#!/usr/bin/env bash
set -e

echo "→ Install"
npm ci

echo "→ Typecheck"
npm run typecheck

echo "→ Lint"
npm run lint

echo "→ Tests"
npm test

echo "→ Build"
npm run build

echo "→ Audit (security)"
npm audit --audit-level=high

echo "All quality gates passed."
```

Run it as the final step before declaring done.

---

## What fails a quality gate (examples)

- One Lighthouse score below threshold → fix the cause, re-measure
- A flaky test → either fix it or delete it; never accept "it sometimes fails"
- A console error you can't explain → debug per `13-debugging.md`
- A `// TODO: fix this hack` → fix it now, this is the moment
- A feature in `FEATURES.md` marked complete that you haven't manually verified → verify or unmark
- README that says "TBD" anywhere → fill it in

---

## When ALL gates pass

You can finally say "done". Hand off with:

```markdown
**Project complete: <name>**

Quality gate: PASSED
Features: <X> / <X> must-haves shipped
Tests: <Y> total, all passing
Coverage: <approximate>%
Bundle: <size> gzipped
Lighthouse: <perf>/<a11y>/<best-practices>/<seo>

Run locally:
1. `git clone <url>`
2. `cd <project>`
3. `npm install`
4. `npm run dev`
5. Open `http://localhost:<port>`

Deployment is out of scope for this conversation.
```

That's the bar. Anything less is a draft.
