# 05 — Apply

Goal: implement the locked plan one small change at a time, verifying between each step.

## The inner loop

For each file in the plan (in dependency order — leaves first, callers later):

1. **Read** the file fully. Confirm it matches what discovery said.
2. **Edit** only the lines required by the plan. Preserve surrounding style, indentation, naming.
3. **Lint** the changed file with the project's linter.
4. **Typecheck** if applicable (TS, Py with mypy, Go, Rust).
5. **Run the affected tests.**
   - If the file has a co-located test, run that test only.
   - Else run the smallest test group that exercises this file.
6. **On green:** `git add <file>` and commit with message:
   `<type>(<scope>): <task summary> — <step n of m>`
   Examples: `feat(settings): add dark mode toggle — 1 of 3`, `fix(auth): correct redirect on expired token — 1 of 1`.
7. **On red:** STOP. Do not edit more files. Diagnose:
   - Is the failure caused by your change? → fix it in-place, rerun.
   - Is it a pre-existing failure? → surface to user, do not commit on top.
   - 3 failed retry attempts → escalate to user with what you tried.

## Commit discipline

- One logical change per commit. No "WIP" or "stuff" commits.
- Type prefix: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `perf`.
- Imperative mood: "add X", not "added X".
- No emojis.

## When new tests are required

If the plan said a new test is needed:
- Write the test FIRST (it should fail).
- Then implement the change.
- Then watch it go green.

This applies for both enhance and debug modes. For edit mode, update the existing test that locks in the old behavior.

## When the apply phase reveals a wrong plan

If you discover during apply that the plan was wrong (file isn't where you thought, behavior is different):
1. Stop immediately.
2. Do not improvise.
3. Send a one-message update to the user with the corrected plan. Wait for "go" again.

## What not to do

- Do not run formatters across files you didn't touch.
- Do not "fix" pre-existing lint warnings outside the changed lines.
- Do not rename files unless the plan said so.
- Do not delete or restructure tests beyond the plan.
- Do not commit secrets, env values, or generated files.
- Do not amend or rebase commits you already pushed without asking.

## After the last change

Move to `07-verify.md`.
