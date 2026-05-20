---
mode: agent
description: Run the myVibe to take a one-line project command from idea to a complete, tested, localhost-running project in a single end-to-end run.
---

# Execute Kit

Read `myvibe/SKILL.md`, then `myvibe/INTAKE.md`, then `myvibe/00-START-HERE.md`. Follow them exactly.

The user's project command is below. Run the **one-shot intake** first (fill defaults, send to user in one message, wait for "go" with overrides). After "go", lock the contract and build the project end-to-end without re-asking.

Constraints:
- Localhost-first. No deployment, no cloud.
- Latest stable library versions.
- Tests are part of every feature.
- No emojis anywhere.
- Push back on requests that contradict the locked intake.

---

## Project command

${input:command:Describe the project in one line (e.g. "Build me a kanban app with drag-and-drop")}
