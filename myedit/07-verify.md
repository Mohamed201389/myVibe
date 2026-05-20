# 07 — Verify

Goal: prove the change is safe to ship. Quality gates scoped to the diff.

## The gates

Run ALL of these. Any failure blocks "done".

### 1. Lint on changed files
Run the project's linter against the changed files only.
- JS/TS: `eslint <files>` or `biome lint <files>`
- Python: `ruff check <files>` or `flake8 <files>`
- Go: `golangci-lint run <packages>`
- Rust: `cargo clippy`

### 2. Format check on changed files
If the project uses a formatter (Prettier, Biome, Black, gofmt, rustfmt), confirm changed files match. Auto-format only the touched files.

### 3. Typecheck
Whole-project typecheck. A type error you introduced anywhere blocks done.
- TS: `tsc --noEmit`
- Python: `mypy <package>` or `pyright`
- Go / Rust: build implies typecheck

### 4. Tests
- Run the test files affected by your change.
- Run the full test suite if the change touched shared code (utilities, types, config).
- Zero new failures. Zero new skipped/xfail tests unless explicitly justified in the plan.

### 5. Manual smoke
Walk the touched user-facing flow end to end on the dev server.
- For UI: open the page, perform the action, confirm the outcome.
- For API: hit the endpoint with a representative payload, confirm the response.
- For library: run the example from the README or write a 5-line script.

### 6. No-regression check
Run any pre-existing smoke test, e2e test, or starter script the project ships. If the project has none, run `dev` + open the home/root and confirm it still loads.

### 7. Diff sanity
`git diff main...HEAD --stat` — confirm the changed files match the plan. Anything extra needs justification or removal.

### 8. Commit message review
Read each commit message. Each must describe the change in imperative voice with a scope. No "WIP", no "stuff", no emojis.

## On any failure

Stop. Do not declare done. Fix the failing gate, then re-run from the failed gate forward.

3 failed cycles on the same gate → escalate to the user with what you tried and what the failure says.

## Updating the map

If the change altered file structure, dependencies, scripts, or conventions, update `.myvibe/PROJECT-MAP.md` with a new "Last updated" line and a one-line note of what changed.

## Final report to the user

Send one message:

```
Done.

Mode: <edit | enhance | debug>
Commits: <count>
Files changed: <count> (+<lines>, -<lines>)

What changed:
- <commit 1 message>
- <commit 2 message>

How to verify locally:
  <exact commands>

Follow-ups intentionally deferred:
- <thing 1, or "none">
```
