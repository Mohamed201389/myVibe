---
name: myvibe
description: One command for the full project lifecycle. Auto-detects whether the workspace is empty (new project) or has an existing codebase (edit / enhance / debug), then routes to the right flow. NEW PROJECT mode runs intake → plan → scaffold → build → test from a one-line idea like "build me a kanban app". EXISTING PROJECT mode runs discover → map → classify → plan-tiny → apply → verify on tasks like "add dark mode", "fix the login redirect", or "investigate slow uploads". Same command, same philosophy, two flows. Localhost-first, vendor-neutral.
---

# myVibe

A deterministic operating system for shipping software — whether starting from scratch or evolving a running codebase. Vendor-neutral: works on any coding model.

## When to invoke this skill

The user gives you a one-line command. Two intents are valid:

**New project (greenfield):**
- "Build me a kanban board with drag-and-drop"
- "Make a SaaS billing dashboard"
- "Scaffold an inventory tracker"
- "Create a portfolio site with scroll animations"

**Existing project (change request):**
- "Add a dark mode toggle to the settings page"
- "Fix the login redirect loop"
- "Refactor auth to use JWT"
- "Investigate why uploads time out over 5MB"
- "Enhance search to support fuzzy matching"

Do NOT invoke for: pure questions that don't change code.

## Always start with Phase 0 — Auto-detect

Read `00-START-HERE.md` and run the **Phase 0 auto-detect** step. It inspects the workspace (manifest files, git, source dirs) and the task wording, then chooses:

- **new-project mode** → continue with the protocol below (intake → plan → scaffold → build)
- **existing-project mode** → jump to `myedit/SKILL.md` + `myedit/00-START-HERE.md` and follow that flow

If ambiguous (e.g. existing project + new-project wording), ask the user one focused question before routing.

---

## NEW-PROJECT PROTOCOL (when auto-detect returns new-project)

## The protocol (follow strictly)

The kit lives in a `myvibe/` folder. Read files in this order:

### Step 1 — Intake (ONE round)
1. Read `INTAKE.md` in the kit folder.
2. Fill out the full 18-section intake form using sensible defaults based on the user's command.
3. Send the filled form to the user in **one message** asking them to override any line or reply "go".
4. After "go", write the final form to `INTAKE.md` at the new project root and commit it as `chore: lock project intake`.
5. **Do not ask any further questions** until the project is shipped. If something is ambiguous mid-build, pick a sensible default and note it in `CHANGELOG.md`.

### Step 2 — Orchestrate
1. Read `00-START-HERE.md` and follow Phases 2 through 7 in order.
2. At each phase boundary, re-read the relevant per-stage file:
   - `01-plan.md` for planning
   - `03-scaffolding.md` for stack + bootstrap
   - `05-frontend.md` / `06-backend.md` / `07-database.md` for the foundation
   - `04-features.md` for each feature spec
   - `08-testing.md` for test strategy
   - `09-checkpoint.md` at every checkpoint
   - `10-changelog.md` for changelog discipline
   - `11-localhost.md` for env/ports/dev DX
   - `12-code-style.md` for code quality
   - `13-debugging.md` when something breaks
   - `14-quality-gates.md` before declaring "done"

### Step 3 — Ralph-style feature loop
For each feature in `PLAN.md`, run the tight inner loop documented in `00-START-HERE.md` Phase 5: spec → failing test → implement → run → on-fail-debug-and-retry → on-pass-checkpoint → next feature. Maximum 3 retry passes before escalating to the user.

### Step 4 — Quality gate
Before claiming "done", run every check in `14-quality-gates.md`. If any fails, fix and re-run.

## Rules of engagement

- **Localhost-first.** No deployment, no cloud, no production paths in v1.
- **Latest stable library versions.** No "for compatibility" downgrades.
- **One feature at a time.** No parallel half-builds.
- **No emojis** in code, commits, or terminal-facing docs.
- **Read before edit.** Never modify a file you haven't read in the current session.
- **Tests are part of the feature**, not a separate phase.
- **Prove root cause before fixing.** No symptom-patching.
- **Push back when wrong.** If the user's request will break the project or contradicts the locked intake, explain and propose an alternative.

## What "done" means

All of the following are simultaneously true:
- Fresh clone → `npm install` → `npm run dev` produces the running app
- All must-have features in `FEATURES.md` are complete with passing tests
- `npm run lint`, `npm run typecheck`, `npm test` all pass with zero warnings/errors
- `INTAKE.md`, `PLAN.md`, `CHANGELOG.md`, `README.md` are all current
- Every category in `14-quality-gates.md` checks out

If any item fails, the project is not done — keep going.

## Anti-patterns to refuse

- "Skip the intake, just build it" — no, intake is what makes the run succeed
- "Deploy it after" — no, deployment is a separate conversation
- "Add 10 nice-to-have features in v1" — push back, defer to v1.1
- "Don't bother with tests" — no, tests are part of the contract
- "Use this old library version" — push back unless there's a real reason
- "Ship without checking it works" — no, manual smoke is mandatory at every checkpoint

## File reference

| File | When to read |
|---|---|
| `INTAKE.md` | First — to collect all decisions in one round |
| `00-START-HERE.md` | Right after intake — drives all phases |
| `01-plan.md` | Phase 2 |
| `02-agents.md` | When you want to think in roles or spin subagents |
| `03-scaffolding.md` | Phase 3 |
| `04-features.md` | Every feature, Phase 5 |
| `05-frontend.md` | Foundation + every UI feature |
| `06-backend.md` | Foundation + every API feature |
| `07-database.md` | Foundation + any schema change |
| `08-testing.md` | Every feature |
| `09-checkpoint.md` | After every feature |
| `10-changelog.md` | Every commit |
| `11-localhost.md` | Phase 3 + handover |
| `12-code-style.md` | Always |
| `13-debugging.md` | When anything breaks |
| `14-quality-gates.md` | Before declaring "done" |
