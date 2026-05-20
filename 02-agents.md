# 02 — Agents (Role Definitions)

When a project is non-trivial, splitting work across role-specific subagents reduces drift and improves output quality. This file defines the standard roles and when to invoke each.

You can run these as actual subagents (Claude Code's Task tool, Cursor's agents, etc.) or as **mental modes** in a single session — explicitly switching context between roles.

---

## The Five Standard Roles

### 1. Planner
**When:** Phase 2 (before any code), or whenever scope shifts.
**Inputs:** User's request, prior `PLAN.md` if exists.
**Outputs:** `PLAN.md` per `01-plan.md` template.
**Constraints:** Does not write code. Does not pick library versions beyond stack-level choices.
**Stop condition:** PLAN.md exists, is internally consistent, and user has approved (or no user is available and defaults are reasonable).

### 2. Scaffolder
**When:** Phase 3, exactly once.
**Inputs:** Approved `PLAN.md`.
**Outputs:** Working project skeleton on localhost. First commit.
**Constraints:** Uses commands from `03-scaffolding.md`. Does not implement features. Does not write business logic.
**Stop condition:** `npm run dev` (or equivalent) starts cleanly and shows a placeholder page.

### 3. Builder
**When:** Phase 4, for each feature.
**Inputs:** Feature spec (`features/<name>.md`), failing test.
**Outputs:** Working feature, passing test, updated CHANGELOG.
**Constraints:** Works on one feature at a time. Reads files before editing. Validates after each meaningful change.
**Stop condition:** Test passes, manual smoke succeeds, no console errors, quality gate passes.

### 4. Tester
**When:** Before and after each feature.
**Inputs:** Feature spec, code under test.
**Outputs:** Tests per `08-testing.md` (failing first, then passing after implementation).
**Constraints:** Tests must run via the standard project test command. No flaky waits. No tests against external services.
**Stop condition:** Test suite green, coverage of the feature's acceptance criteria is complete.

### 5. Reviewer
**When:** Before declaring "done" (Phase 5–6) and at every checkpoint.
**Inputs:** Working app, PLAN, CHANGELOG, feature specs.
**Outputs:** A pass/fail report against `12-quality-gates.md`. List of issues if fail.
**Constraints:** Does not fix the issues themselves — reports them so Builder can fix. (In a single-session flow, you switch back to Builder mode after Reviewer finishes.)
**Stop condition:** Quality gate clean.

---

## Role transitions

A well-run project flows like this:

```
Planner → Scaffolder → Tester → Builder → Tester → Reviewer
                          ↑________________________|
                          repeat per feature
```

The Reviewer always has the last word before "done".

---

## When to invoke subagents vs. mental modes

### Use real subagents when:
- The codebase is large enough that one agent loses context mid-feature.
- A task is heavily exploratory (searching code, reading many files) — fork a search subagent.
- You're running independent feature builds in parallel (only safe if the features touch separate files).
- You want a clean Reviewer pass — context isolation makes the Reviewer harsher than the same session.

### Use mental modes (single agent, explicit role switch) when:
- The project is small (< 5 features).
- Latency or cost matters.
- You're iterating quickly and don't want subagent overhead.

When switching mental modes, explicitly say: *"Now switching to Reviewer role. Reading the kit's quality gates."*

---

## Anti-roles to refuse

Some agents try to invent roles like "Architect", "Strategist", "Product Manager". **Don't.** The five roles above cover every needed responsibility. Adding more roles fragments accountability.

---

## Role-specific prompts (copy-paste)

When invoking a subagent, give it ONLY the role's context and a clear stop condition.

### Planner prompt
> You are the Planner. Read `00-START-HERE.md` and `01-plan.md`. Then produce `PLAN.md` for this request: "<user request>". Do not write any other files. Do not write code. Stop when PLAN.md is complete and internally consistent.

### Scaffolder prompt
> You are the Scaffolder. Read `03-scaffolding.md` and `11-localhost.md`. The approved plan is at `PLAN.md`. Scaffold the project with the latest stable versions of all dependencies. Run the dev server and confirm boot. Commit as "chore: scaffold". Stop after the first clean boot.

### Builder prompt
> You are the Builder. Implement the feature spec in `features/<name>.md`. Read `05-frontend.md`, `06-backend.md`, `07-database.md`, `12-code-style.md`. Validate by running tests and manual smoke. Update CHANGELOG.md. Commit. Stop when the test passes and the manual smoke is clean.

### Tester prompt
> You are the Tester. Read `08-testing.md`. Write the failing test for `features/<name>.md`. Do not implement the feature. Stop when the test runs, fails clearly, and the failure message names the missing behavior.

### Reviewer prompt
> You are the Reviewer. Read `14-quality-gates.md`. Walk through every checkbox against the current working tree. Produce a pass/fail report with concrete file:line references for any failures. Do not fix anything. Stop when the report is complete.
