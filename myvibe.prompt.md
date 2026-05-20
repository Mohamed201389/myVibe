---
mode: agent
description: One command for new projects, edits, enhancements, and debugging. Auto-detects whether the current workspace is a new project or an existing codebase and routes accordingly.
---

# Execute myVibe

Read `myvibe/SKILL.md`, then `myvibe/00-START-HERE.md`. Follow them exactly.

First, run the **auto-detect** step in `00-START-HERE.md` to decide the mode:

- **new-project mode** — the workspace is empty or has no project manifest. Run the myVibe intake + build flow (files `INTAKE.md` → `00-START-HERE.md` → `01-plan.md` … `14-quality-gates.md`).
- **existing-project mode** — the workspace has a project manifest (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, `Gemfile`, `pubspec.yaml`, etc.) or is a git repo with source files. Run the myedit flow (files `myedit/01-discover.md` → `myedit/02-map.md` → … → `myedit/07-verify.md`).

Constraints (both modes):
- Localhost-first. No deployment, no cloud.
- Latest stable library versions.
- Tests are part of every change.
- No emojis anywhere.
- Read before edit. Prove root cause before fixing.
- Push back on requests that contradict the locked plan/intake.

---

## Command

${input:command:Describe the task in one line. Examples: "build me a kanban app" (new project) | "add dark mode toggle" | "fix the login redirect bug" | "investigate slow uploads"}

