# 03 — Classify

Goal: route the one-line task into exactly one mode. The mode dictates rules.

## The three modes

### edit
A bounded change to existing behavior. The capability already exists; you are altering it.
Examples: "change the password min length to 12", "rename Settings to Preferences in the UI", "use blue instead of green for the primary button".

### enhance
A net-new capability that fits into existing architecture without redesigning it.
Examples: "add a dark mode toggle", "add CSV export to the reports page", "add a /health endpoint".

### debug
Something is broken or behaving unexpectedly. Outcome unknown until root cause is proven.
Examples: "fix the login redirect loop", "uploads time out on files > 5MB", "the dashboard renders blank for some users".

## How to classify

Read the task. Ask yourself:

1. Is something currently broken that needs investigation? → **debug**
2. Is there a brand-new feature/capability requested? → **enhance**
3. Otherwise (modifying existing working behavior) → **edit**

If the task contains "fix", "broken", "not working", "investigate", "why does", "should but doesn't" → debug.
If it contains "add", "introduce", "support", "new" → enhance.
If it contains "change", "rename", "update", "use X instead of Y", "tweak" → edit.

## Output

Single line: `Mode: edit | enhance | debug` + a one-sentence justification.

## Mode-specific rules

### edit mode
- Constrain blast radius. Find the minimal set of files that hold the current behavior.
- Preserve all public interfaces unless the task explicitly says otherwise.
- Update or add a test that locks in the new behavior.

### enhance mode
- Find the closest existing pattern in the codebase (similar feature) and mirror it. Do not introduce a new pattern unless necessary.
- Reuse existing utilities, components, modules. Do not duplicate.
- Add a test for the new capability before merging.

### debug mode
- **Stop. Go to `06-debug.md` first.** Do not plan a fix until root cause is proven.
- The plan in Phase 4 must include the reproduction recipe and the proven cause.

## What to refuse

- Multi-mode tasks ("add a feature AND fix the bug AND rename X") → push back, split into separate runs.
- Vague tasks ("make it better") → ask the user for a concrete acceptance criterion before classifying.
