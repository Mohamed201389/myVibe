---
mode: agent
description: Run myedit to safely edit, enhance, or debug the current project from a one-line task. Discovers the codebase, plans the smallest diff, applies changes incrementally, verifies after each step.
---

# Execute myedit

Read `myedit/SKILL.md`, then `myedit/00-START-HERE.md`. Follow them exactly.

The user's task is below. Run phases in order:
1. **Discover** the stack and conventions (do not ask the user)
2. **Map** the project to `.myvibe/PROJECT-MAP.md`
3. **Classify** the task as edit / enhance / debug
4. **Plan** the smallest viable diff and send to the user in one message
5. Wait for "go"
6. **Apply** incrementally with verification after each change
7. **Verify** quality gates on the diff before declaring done

Constraints:
- Smallest diff wins. No drive-by refactors.
- Match existing code style and conventions.
- Tests stay green. One change at a time.
- Debug mode: reproduce before fixing. Prove root cause.
- No new dependencies without explicit approval.
- No emojis anywhere.

---

## Task

${input:task:Describe the task in one line (e.g. "Add dark mode toggle to settings", "Fix login redirect bug", "Investigate slow uploads")}
