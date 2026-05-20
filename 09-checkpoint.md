# 09 — Checkpoint Protocol

A checkpoint is a deliberate pause where you verify the project is in a coherent, working state before continuing. It's the difference between a project that ships and one that becomes a tangle.

---

## When to checkpoint

Run a checkpoint:
1. **After every feature** (Phase 4 loop)
2. **Before any architectural change** (e.g. switching state management, adding auth)
3. **Before a long-running operation** (mass migration, refactor)
4. **At the end of each work session** if shipping over multiple sessions
5. **Whenever you feel uncertain** that everything still works

Checkpoint frequency = trust. The smaller the checkpoints, the higher the confidence.

---

## The checkpoint sequence (run in order)

```
1. Stop coding
2. Save all files
3. Run the build
4. Run the test suite
5. Run the linter + typechecker
6. Start the dev server
7. Click through the affected features in the browser
8. Verify no console errors
9. Update CHANGELOG.md
10. Commit with a clean message
11. (Optional) Pause and ask the user if priorities have shifted
```

Skipping any step risks landing in a broken state without knowing it.

---

## What a clean checkpoint looks like

All of the following are simultaneously true:

- [ ] `npm run build` succeeds with no warnings
- [ ] `npm test` (or `vitest run`) — all green
- [ ] `npm run lint` — zero warnings
- [ ] `npm run typecheck` — zero errors
- [ ] `npm run dev` starts cleanly
- [ ] Browser shows the app on `localhost:PORT`, no console errors
- [ ] You can perform the feature you just built end-to-end manually
- [ ] All prior features still work (smoke check 2–3 of them)
- [ ] Git working tree clean (committed or stashed)
- [ ] CHANGELOG.md has an entry for what was just shipped
- [ ] FEATURES.md status flipped to `Complete` for this feature

If any item is missing or broken, **you do not have a checkpoint**. Fix before moving on.

---

## Manual smoke test (the 60-second walkthrough)

For each feature, walk through these states in the browser:

1. **Empty state** — what does the user see when there's no data?
2. **Create flow** — click the "add" button, fill the form, submit
3. **Read flow** — does the new data appear correctly?
4. **Update flow** — edit it, save, verify the change persists on refresh
5. **Delete flow** — delete it, verify it's gone (and stays gone after refresh)
6. **Error states** — submit empty form, force a 500 (block network) → does the UI degrade gracefully?
7. **Keyboard navigation** — Tab through, Enter to submit, Escape to cancel — does it work?

This takes 60 seconds. Do it every checkpoint.

---

## Commit message format

```
<type>(<scope>): <short description>

<optional body explaining why, not what>
<optional footer with breaking changes or issue refs>
```

Types:
- `feat` — new feature
- `fix` — bug fix
- `refactor` — code change that doesn't add features or fix bugs
- `chore` — build, scaffolding, deps
- `docs` — documentation only
- `test` — adding or improving tests
- `perf` — performance improvement
- `style` — formatting, missing semicolons, no logic change

Examples:
- `feat(cards): drag-and-drop between columns persists to DB`
- `fix(boards): empty board title no longer crashes the create flow`
- `refactor(api): extract validation into shared zod schemas`
- `chore: scaffold project`

**Bad commit messages to refuse:**
- "WIP"
- "fix stuff"
- "more changes"
- "asdf"
- A commit message that says "what" but not why for non-obvious changes

---

## When the checkpoint reveals problems

If the build is broken or tests fail at checkpoint time:

1. **Do not commit broken state**. The whole point of checkpoints is that every commit is green.
2. Diagnose the failure per `13-debugging.md`.
3. Fix the root cause.
4. Re-run the checkpoint sequence from step 3.
5. Only commit when fully green.

If the failure is too big to fix immediately (e.g. you took a wrong architectural turn 4 hours ago):
- `git stash` or `git reset --hard` to the last good checkpoint
- Replan
- Try again

This is why checkpoints are frequent — the maximum cost of rolling back is the work since the last checkpoint.

---

## The "ask the user" moment

At every checkpoint, ask yourself:
- Has anything in the user's brief changed since last checkpoint?
- Have we discovered something that should change the plan?
- Are we still building the right thing?

If yes to any: pause and confirm with the user before proceeding. If no: continue.

For autonomous runs (no user available): document the decision in CHANGELOG.md and continue.

---

## What the user sees at a checkpoint

Brief, useful, no fluff:

```markdown
**Checkpoint: card drag-and-drop**

- Shipped: cards can be dragged between columns; positions persist
- Tests: 4 new (2 unit, 1 integration, 1 e2e) — all passing
- Files changed: 6
- CHANGELOG updated
- Next: add card edit modal (features/card-edit.md)

Anything to adjust before I continue?
```

That's it. No emoji. No padding. No "I hope this helps!".

---

## Checkpoint anti-patterns

- Skipping the manual smoke because "the tests pass" — tests miss things
- Committing with a known broken state and `TODO: fix later`
- Pushing forward when the checkpoint reveals confusion
- Updating CHANGELOG retroactively in bulk — do it at each checkpoint
- Naming checkpoints vaguely ("update", "changes") instead of by the feature shipped
- Combining multiple features in one checkpoint to "save time"

---

## End-of-session checkpoint

When you're stopping work for the day (or ending a session for any reason):

1. Run the full checkpoint sequence
2. Write a 5-line "where we are" note in `CHANGELOG.md` under a `## Work in progress` section
3. If anything is partial/broken, document it explicitly
4. Push to a `wip/` branch if uncertain about the state of the work
5. Don't leave uncommitted work — either commit, stash, or discard

Next session opens with confidence about where you stand.
