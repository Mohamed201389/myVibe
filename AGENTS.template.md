# AGENTS.md

This project was built with the **myVibe** and must continue to be maintained under its rules.

Any coding agent (Claude, GPT/Codex, Gemini, Copilot, Cursor) working in this repo MUST follow the conventions below. If the kit folder is present (`myvibe/` or `docs/agent-kit/`), it is the source of truth — read it before making non-trivial changes.

---

## Project contract

- **Intake:** see `INTAKE.md` at the repo root. It defines what this project is and is not. Do not override silently.
- **Plan:** see `PLAN.md`. Must-have features and non-goals are locked unless explicitly amended.
- **Features:** see `FEATURES.md` index and `features/*.md` specs. Each feature has acceptance criteria — do not declare a feature done until every criterion is checked.
- **Changelog:** see `CHANGELOG.md`. Every shipped change gets an entry under the right section (`Added`, `Changed`, `Fixed`, `Removed`, `Security`).

---

## Rules of engagement

1. **Localhost-first.** No deployment, no cloud paths, no production-specific code in v1.
2. **Latest stable library versions.** Don't downgrade out of caution.
3. **One feature at a time.** No parallel half-builds. No refactors mid-feature.
4. **Read before edit.** Never modify a file you haven't read this session.
5. **Tests are part of the feature.** A feature without a test is a draft.
6. **Prove root cause before fixing.** No symptom-patching, no defensive wraps.
7. **Push back when wrong.** If a request contradicts the intake or breaks the project, explain and propose an alternative.
8. **No emojis** in code, commits, or terminal-facing docs.
9. **Update `CHANGELOG.md` at every checkpoint.** Not at end of day, not in bulk.
10. **Run the quality gate before declaring "done"** — see `myvibe/14-quality-gates.md`.

---

## Workflow per change

```
1. Read INTAKE.md and PLAN.md
2. If new feature: create features/<name>.md from the kit template
3. Write the failing test first
4. Implement the smallest change that passes the test
5. Run all tests — every test green
6. Manual smoke in browser — no console errors
7. Update CHANGELOG.md with the right section
8. Commit with conventional message: feat(scope): description
9. Checkpoint per kit/09-checkpoint.md
```

---

## Code style

See `myvibe/12-code-style.md` for the full ruleset. Headlines:

- Functions ≤ ~50 lines, files ≤ ~400 lines
- TypeScript strict mode on, no `any` in committed code
- Imports ordered: stdlib → third-party → aliases → relative → types
- Schemas (Zod / pydantic) are the source of truth — derive types from them
- Error handling: throw typed errors, catch only when you can do something useful
- No commented-out code, no `// TODO` without a date or issue link

---

## Commit message format

```
<type>(<scope>): <short description>

<optional body explaining why>
```

Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `style`.

Refuse: `WIP`, `fix stuff`, `more changes`, `asdf`.

---

## Decisions that need user approval

Ask the user before:
- Changing the stack defined in `INTAKE.md`
- Adding a new external service or dependency that wasn't in the plan
- Switching the database
- Adding auth where there was none
- Removing a feature already shipped
- Renaming public APIs or routes

Do NOT ask for:
- Defaults already in the kit
- Minor styling or copy choices (pick sensibly, note in CHANGELOG)
- Anything `INTAKE.md` already answers

---

## When stuck

Follow `myvibe/13-debugging.md`:

1. Reproduce
2. Isolate
3. Hypothesize
4. Prove
5. Fix at the root

If 30 minutes of debug protocol haven't produced a hypothesis, surface the repro recipe and your top theory to the user.

---

## Definition of done (the quality gate)

Before any "done" claim, every item in `myvibe/14-quality-gates.md` must check out. There is no partial pass — either all gates green, or it's not done.
