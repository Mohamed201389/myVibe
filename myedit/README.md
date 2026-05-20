# myedit

Sibling of [myVibe](../README.md). Same deterministic philosophy, applied to **existing codebases** instead of new projects.

## What it does

Takes a one-line task on a working project and runs it through a fixed protocol:

**Discover → Map → Classify → Plan tiny → Apply → Verify**

Three task modes:
- **edit** — change existing behavior
- **enhance** — add a new capability inside the existing architecture
- **debug** — find the root cause of a bug, then fix it (reproduce first, no symptom patches)

## Why a separate kit

myVibe assumes a blank slate. myedit assumes:
- A stack, conventions, and tests already exist and must be respected
- The smallest diff is always preferred
- Tests stay green
- Architecture changes require explicit approval

## How to use it

In VS Code Copilot Chat:

```
/myedit add dark mode toggle to settings
/myedit fix the login redirect loop
/myedit investigate why uploads time out over 5MB
```

In any other agent (Claude Code / Codex / Cursor / Windsurf): point the agent at `myedit/SKILL.md`. Same protocol.

## Anti-patterns it refuses

- "While you're in there, also refactor X" — no, separate task
- "Skip the tests" — no
- "Bump these 5 dependencies too" — no
- "Apply the fix without reproducing the bug" — no
- "Edit and commit without showing the plan" — no

## File layout

```
myedit/
  SKILL.md              skill manifest (for Claude / agents)
  myedit.prompt.md      VS Code Copilot slash command
  00-START-HERE.md      orchestrator
  01-discover.md        stack + conventions detection
  02-map.md             writes .myvibe/PROJECT-MAP.md
  03-classify.md        routes task to edit / enhance / debug
  04-plan-tiny.md       smallest viable diff plan
  05-apply.md           incremental application + commits
  06-debug.md           reproduce-first debug protocol
  07-verify.md          quality gates on the diff
```
