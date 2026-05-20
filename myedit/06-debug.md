# 06 — Debug

Goal: prove root cause with evidence BEFORE planning a fix. No symptom patches.

## The debug protocol

### Step 1 — Reproduce deterministically

You cannot fix what you cannot reproduce. Until reproduction is reliable, do not propose any fix.

- Capture the exact steps to trigger the bug (smallest possible recipe).
- Capture environment: OS, runtime version, browser, env vars, data state.
- Capture the observed behavior (logs, error, screenshot, response body).
- Capture the expected behavior.

If you cannot reproduce: ask the user for one more piece of info (input data, exact URL, account state) — one focused question.

### Step 2 — Isolate

Narrow the surface area:
- Disable unrelated middleware/plugins/features one at a time.
- Bisect the codebase: does the bug occur in the simplest possible call to the affected function?
- If git history is suspect, `git bisect` against a known-good commit.

### Step 3 — Form one hypothesis at a time

State the hypothesis explicitly:
`Hypothesis: <component X> does <wrong thing> because <reason>.`

Predict what evidence would confirm or refute it.

### Step 4 — Test the hypothesis

Add a temporary log, a breakpoint, or a unit assertion that produces evidence. Run the reproduction. Record what you observe.

- If evidence confirms → root cause proven, move to Step 5.
- If evidence refutes → discard, form next hypothesis, repeat Step 3.

Do not stack hypotheses. One at a time.

### Step 5 — Write the proof

Before any fix is planned, write a short proof in the Phase 4 plan:

```
Root cause:
  <component>.<function> does <wrong behavior> when <condition>.

Evidence:
  - Step to reproduce: <recipe>
  - Observed: <log line / error / value>
  - Expected: <what should happen>
  - Confirmed by: <the test/log/breakpoint output>
```

### Step 6 — Fix at the root, not the symptom

The fix must address what the proof identified, not the surface error.

- If the fix means catching an exception, the proof must show why the exception is unrecoverable at the source.
- If the fix means a config change, the proof must show why no code path can correctly handle the current config.

### Step 7 — Regression test

Add a test that fails before the fix and passes after. This is non-negotiable. The test belongs in the apply commit.

### Step 8 — Remove debug scaffolding

Delete temporary logs, prints, and breakpoints added during isolation. Do not commit them.

## What not to do

- Do not guess. Do not "try this and see".
- Do not wrap broken code in try/except to silence it.
- Do not fix it on one platform/browser and call it done — verify the reproduction recipe is green.
- Do not skip writing the regression test "because the fix is obvious".
- Do not move on with multiple unproven changes stacked together.
