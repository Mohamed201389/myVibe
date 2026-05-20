# 04 — Features

Every feature gets its own spec file: `features/<feature-name>.md`. This file is the contract between Planner, Builder, Tester, and Reviewer. Without it, scope drifts and "done" becomes opinion.

---

## The feature spec template

Copy this into `features/<feature-name>.md` at the start of each feature.

```markdown
# Feature: <Name>

> One-sentence summary of what this feature does for the user.

## User story
As a <user type>, I want to <do thing>, so that <outcome>.

## Acceptance criteria
- [ ] Concrete, testable condition 1
- [ ] Concrete, testable condition 2
- [ ] Concrete, testable condition 3
(Aim for 3–7. Each one becomes a test case.)

## UI / UX
- Where it lives in the app (route, section, modal)
- Key states: empty, loading, success, error, disabled
- Key interactions: click, hover, drag, keyboard
- Screenshots or sketches if available

## Data model changes
- New tables / columns? List them with types.
- New API endpoints? Method + path + request/response shape.
- New client-side state? Where it lives (zustand, react-query cache, URL).

## Out of scope
- What this feature explicitly does NOT do.

## Implementation plan
1. Step 1 (e.g. add migration)
2. Step 2 (e.g. add API endpoint with validation)
3. Step 3 (e.g. add client hook + UI)
4. Step 4 (e.g. wire drag-drop)

## Tests
- Unit: <list of unit test cases>
- Integration: <list of integration tests>
- E2E: <list of end-to-end flows>

## Verification
How to manually verify this feature works:
1. Open `http://localhost:PORT`
2. Click X
3. Enter Y
4. Confirm Z appears

## Status
Not started | In progress | Complete

## Notes
Anything else — design decisions, trade-offs, deferred items.
```

---

## Writing good acceptance criteria

**Bad:**
- "User can manage cards"
- "It looks nice"
- "Fast performance"

**Good:**
- "Clicking 'Add card' opens an inline editor focused on the title input"
- "Pressing Enter saves the card; Escape cancels and clears the input"
- "Cards persist to SQLite and survive a page refresh"
- "Drag a card between columns updates its `columnId` and `position`"

Each criterion must be:
- **Testable** — you can write a test for it
- **Observable** — a human can verify by clicking
- **Atomic** — does one thing, fails or passes cleanly

---

## Sizing features

A feature should be 2–8 hours of focused work for a competent agent. If estimate exceeds 8h:
- Split into sub-features
- Each sub-feature gets its own `features/<name>-<sub>.md`
- Each sub-feature is independently shippable

Example: "User authentication" is too big. Split into:
- `features/auth-signup.md`
- `features/auth-login.md`
- `features/auth-logout.md`
- `features/auth-password-reset.md`

---

## Feature ordering

In `FEATURES.md` (a root-level index), list features in build order:

```markdown
# Features index

## Must-have (v1)
1. [x] features/scaffold.md
2. [x] features/board-list.md
3. [x] features/board-create.md
4. [ ] features/column-crud.md
5. [ ] features/card-crud.md
6. [ ] features/card-drag-drop.md
7. [ ] features/persistence.md

## Nice-to-have
- [ ] features/labels.md
- [ ] features/search.md
- [ ] features/export.md
```

Order rules:
1. Data layer features come before UI features that depend on them.
2. Read-only views come before edit/create.
3. Single-resource CRUD before multi-resource interactions.
4. Drag-drop and animations come *after* basic CRUD works.
5. Polish (empty states, error states, loading states) ships with each feature, not as a separate phase.

---

## Updating the spec mid-build

If you discover during implementation that the spec is wrong or incomplete:
1. Stop coding.
2. Update the spec.
3. Add a note in the "Notes" section: *"Spec updated mid-build: added X because Y."*
4. Continue.

Never silently diverge from the spec.

---

## When a feature is "done"

A feature's `## Status` becomes `Complete` only when:
- [ ] All acceptance criteria boxes are checked
- [ ] All listed tests exist and pass
- [ ] Manual verification steps pass in the browser
- [ ] CHANGELOG.md has an entry referencing the feature
- [ ] Code committed with a clean message: `feat(<scope>): <feature name>`
- [ ] No console errors during the manual verification

If any item is unchecked, status stays as `In progress`.
