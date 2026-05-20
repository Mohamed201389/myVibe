# 00 — Start Here (myedit Orchestrator)

You are running myedit on an existing project. Follow phases strictly. Do not skip ahead.

## Pre-flight

1. Confirm you are in a git repo. If not, stop and tell the user.
2. Confirm working tree is clean (`git status`). If dirty, ask the user whether to stash or include uncommitted changes in scope.
3. Note current branch and HEAD commit. You will checkpoint frequently.

## Phase 1 — Discover

Read `01-discover.md`. Inspect the repo. Do not write yet.

## Phase 2 — Map

Read `02-map.md`. Write `.myvibe/PROJECT-MAP.md`. If the file already exists and the repo HEAD has not changed since it was written, reuse it.

## Phase 3 — Classify

Read `03-classify.md`. Route the task into exactly one mode:
- **edit** — bounded change to existing behavior
- **enhance** — net-new capability inside existing architecture
- **debug** — something is broken; find the cause, then fix

## Phase 4 — Plan tiny

Read `04-plan-tiny.md`. Produce a plan with:
- Mode (edit / enhance / debug)
- Acceptance criteria (1–3 bullets)
- Files that will change (paths only)
- Files that will be read but not changed
- Test strategy (which existing tests cover this, which new test if any)
- Risk notes (what could break)

Send the plan to the user in **one message**. Wait for "go" or overrides.

## Phase 5 — Apply

Read `05-apply.md`. Implement the plan one change at a time. After each change:
1. Run lint on the changed file
2. Run the affected test(s)
3. If green: `git add -p` + commit with a clear scoped message
4. If red: stop. Diagnose. Do not stack changes on top.

For **debug** mode: before any apply step, run `06-debug.md` to reproduce and prove root cause.

## Phase 6 — Verify

Read `07-verify.md`. Run the full diff-scoped quality gate. Only declare "done" when every gate passes.

## Phase 7 — Report

Send a final message with:
- What changed (file list with one-line summary each)
- How to verify locally (exact commands)
- Any follow-ups intentionally deferred

## Rules

- One feature/fix at a time. No parallel branches of work.
- Maximum 3 retry passes on a failing change. Then escalate to the user.
- Never bypass tests or quality gates to claim done.
- If the task requires architectural change, stop in Phase 4 and propose it explicitly — do not silently expand scope.
