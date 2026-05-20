---
name: myedit
description: Safely edit, enhance, or debug an EXISTING working project from a one-line task. Use when the user asks to "add a feature to this project", "fix a bug", "refactor X", "enhance Y", "investigate why Z fails", or any change request on a codebase that already exists. Discovers the stack, conventions, and entry points first; plans the smallest viable diff; applies changes incrementally with verification after each step. Respects existing tests, style, and architecture. Does NOT scaffold new projects (use myvibe for that).
---

# myedit

A deterministic operating system for safely changing existing codebases from a single one-line task. Sibling of myVibe. Vendor-neutral.

## When to invoke

The user gives you a one-line task targeting an existing project. Examples:
- "Add dark mode toggle to the settings page"
- "Fix the login redirect bug"
- "Refactor auth to use JWT"
- "Investigate why uploads time out on files > 5MB"
- "Enhance the search to support fuzzy matching"
- "Migrate the user table from int IDs to UUIDs"

Do NOT invoke for: new project creation (use `myvibe`), pure questions, or asks that don't change code.

## The protocol (follow strictly)

Run phases in order. Each phase has a dedicated file in the `myedit/` folder.

### Phase 1 — Discover (`01-discover.md`)
Detect stack, package manager, test runner, lint/format tools, framework conventions, entry points. Output: in-memory facts.

### Phase 2 — Map (`02-map.md`)
Write `.myvibe/PROJECT-MAP.md` at the repo root. Single source of truth for stack, scripts, modules, conventions. Refresh on every run if stale.

### Phase 3 — Classify (`03-classify.md`)
Route the task to one of three modes: **edit** (small change), **enhance** (new capability), **debug** (something is broken). Each mode has rules.

### Phase 4 — Plan tiny (`04-plan-tiny.md`)
Smallest viable diff. List files that will change. Reject sprawl. Send plan to user in one message. Wait for "go".

### Phase 5 — Apply (`05-apply.md`)
One small change at a time. After each change: run existing tests + targeted check. On green: commit checkpoint. On red: stop, diagnose, do not stack changes.

### Phase 6 — Debug (only debug mode) (`06-debug.md`)
Reproduce first. Prove root cause with evidence. Then fix. No symptom patches.

### Phase 7 — Verify (`07-verify.md`)
Quality gates run only on the diff: lint changed files, typecheck, run affected tests, run a manual smoke for the touched flow.

## Rules of engagement

- **Read before edit.** Never modify a file you haven't read in this session.
- **Match existing style.** Don't reformat, rename, or restructure beyond the task.
- **Smallest diff wins.** Reject "while I'm here" cleanups unless the user asked.
- **One change at a time.** Verify between changes. No batched edits across unrelated files.
- **Prove root cause before fixing.** Reproduce bugs deterministically.
- **Tests stay green.** If existing tests fail before your change, surface that first.
- **No new deps without asking.** Adding a dependency is a separate decision.
- **No emojis** in code, commits, or docs.
- **Push back when wrong.** If the task will break the project or contradicts the map, explain.

## What "done" means

All true at the same time:
- The task's acceptance criteria are met
- Lint + typecheck pass on changed files
- All affected tests pass; no previously-green test went red
- A manual smoke of the touched flow works
- A commit (or PR) exists with a clear message describing the change
- `.myvibe/PROJECT-MAP.md` is updated if structure changed

## Anti-patterns to refuse

- "Just rewrite the module while you're at it" — no, that's a different task
- "Skip the tests, just push it" — no
- "Bump these 5 deps too" — no, separate task
- "Apply the fix without reproducing the bug" — no, reproduce first
- "Edit and commit without showing me the plan" — no, plan first

## File reference

| File | When to read |
|---|---|
| `01-discover.md` | Phase 1, every run |
| `02-map.md` | Phase 2, every run |
| `03-classify.md` | Phase 3, every run |
| `04-plan-tiny.md` | Phase 4, every run |
| `05-apply.md` | Phase 5, every change |
| `06-debug.md` | Debug mode only |
| `07-verify.md` | Phase 7, before declaring done |
