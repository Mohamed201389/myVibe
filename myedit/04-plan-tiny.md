# 04 — Plan Tiny

Goal: smallest viable diff that satisfies the acceptance criteria. Reject sprawl.

## The plan format

Send this to the user as ONE message. Wait for "go".

```
## Plan: <one-line task>

Mode: edit | enhance | debug

Acceptance criteria:
- <criterion 1>
- <criterion 2>

Files to change (target diff):
- path/to/file.ts — <one-line change summary>
- path/to/other.ts — <one-line change summary>

Files to read (no change):
- path/to/context.ts

Tests:
- Existing: <test file(s) that cover this>
- New: <new test file + what it asserts, or "none">

Estimated diff size: <small / medium>. If medium, justify.

Risks:
- <thing that could break>

Reply "go" to apply, or tell me what to change.
```

## Constraints on the plan

- **Files to change** should be the SHORTEST list that works. If it grows past 5 files, justify in writing.
- **No drive-by changes.** Do not add files that aren't required by the acceptance criteria.
- **No dependency additions** without explicit user approval listed in the plan.
- **No architecture changes** without explicit user approval. If you find one is needed, surface it and ask.
- **Match existing patterns.** If you find a similar feature, mirror its file layout.

## When to escalate before sending the plan

- Acceptance criteria are unclear → ask the user one focused question first
- The task as stated requires changing public interfaces or shared modules → flag it explicitly
- You cannot find where the current behavior lives → say so; do not guess

## After "go"

Lock the plan. Proceed to `05-apply.md`. Do not silently expand scope. If reality diverges from the plan during apply, stop and re-plan in one message.

## Anti-patterns

- "Let me also clean up X while I'm in this file" → no
- "I noticed Y is messy, let me refactor" → no
- "I'll add a test for the whole module" → only the changed behavior
- "Let's bump the framework version" → no, separate task
