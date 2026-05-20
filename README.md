# myVibe — turn one line into a finished app

> **"Build me a Kanban app."** → working, tested, localhost-running project. Single run. Any AI coding agent.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub Repo stars](https://img.shields.io/github/stars/Mohamed201389/myVibe?style=social)](https://github.com/Mohamed201389/myVibe)
[![Works with Claude Code](https://img.shields.io/badge/works%20with-Claude%20Code-8A2BE2)](#install)
[![Works with GitHub Copilot](https://img.shields.io/badge/works%20with-Copilot-24292E)](#install)
[![Works with Codex CLI](https://img.shields.io/badge/works%20with-Codex-10A37F)](#install)
[![Works with Cursor](https://img.shields.io/badge/works%20with-Cursor-000)](#install)

`myVibe` is a **model-agnostic operating system for AI coding agents**. It turns a one-line idea into a finished, professional, localhost-running project — every time, with **Claude Code, GitHub Copilot, OpenAI Codex CLI, Cursor, or Windsurf**. No mid-build interrogation. No drift. No half-broken scaffolds.

![myVibe demo](https://mohamed201389.github.io/myVibe/demo.svg)

---

## Install — one line

### Windows (PowerShell)
```powershell
iwr https://raw.githubusercontent.com/Mohamed201389/myVibe/main/bootstrap.ps1 | iex
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/Mohamed201389/myVibe/main/bootstrap.sh | bash
```

That's it. **One command installs myVibe into every coding agent on your machine** — Claude Code, GitHub Copilot, OpenAI Codex CLI, Cursor, and the generic `~/.agents/skills/` location.

After install (and a VS Code reload), type `/myvibe` in any Copilot chat — or just say *"build me a kanban app"* or *"fix the login redirect bug"*. **One command, two flows**: the skill auto-detects whether the workspace is empty (→ scaffolds a new project from intake) or already has a codebase (→ runs the safe edit/enhance/debug flow). See [myedit/README.md](myedit/README.md) for the existing-project protocol.

---

## Why myVibe

AI coding agents drift. They skip planning, invent features, forget tests, leave broken builds, pick stale library versions, and ask the same questions twice. **myVibe forces a deterministic, checkpoint-based workflow that any model can follow.**

The single most important pattern: **the agent collects every decision it needs upfront in one round** (the one-shot intake). No mid-build interrogation. Then it ships.

| | Without myVibe | With myVibe |
|---|---|---|
| Decisions | asked one at a time, mid-build | all upfront, one round |
| Tests | "I'll add them later" | failing test first, no test no commit |
| Stack | whatever the model remembers | latest stable, pinned versions |
| Done | "looks good to me" | hard quality gate: lint + types + tests + build all green |
| Drift | gradual, until rebuild | impossible — checkpoints block bad commits |

---

## What it does

1. **Intake** — single round, 18 sections of project decisions filled with sensible defaults. You reply *"go"* to lock the contract.
2. **Plan** — agent writes `PLAN.md` from the intake.
3. **Scaffold** — picks the right stack (React + Vite + TS, or Next.js, or FastAPI, or Express — opinionated defaults you can override in the intake) and runs the actual bootstrap commands.
4. **Build (Ralph-style loop)** — one feature at a time: failing test → implementation → green test → commit → checkpoint → next feature. Three-retry rule before escalating to you.
5. **Quality gate** — lint, type-check, full test suite, fresh build, smoke test on localhost. All green or it's not done.

Final deliverable: a real, running project at `http://localhost:PORT` with working tests, a CHANGELOG, and a clean commit history. Localhost-first — deployment is a separate conversation.

---

## Works with

| Agent | How myVibe loads |
|---|---|
| **GitHub Copilot (VS Code)** | `/myvibe` slash command + auto-discovered skill |
| **Claude Code** | `~/.claude/skills/myvibe/` + reference in `~/.claude/CLAUDE.md` |
| **OpenAI Codex CLI** | `~/.codex/skills/myvibe/` |
| **Cursor** | `~/.cursor/rules/myvibe.mdc` + per-project `.cursorrules` |
| **Windsurf** | per-project `.windsurfrules` (via `myvibe init`) |
| **Any other agent** | `~/.agents/skills/myvibe/` (generic convention) |

To wire it into a specific repo so every teammate's agent uses the same rules:
```powershell
# from your project root
pwsh -File ~/.agents/skills/myvibe/myvibe-init.ps1
```
```bash
# macOS / Linux
bash ~/.agents/skills/myvibe/myvibe-init.sh
```
This creates `AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.windsurfrules`, and `.github/copilot-instructions.md` — one source of truth for every agent.

---

## Quick examples

```
> build me a kanban board with drag-and-drop
> create a saas dashboard with auth and stripe
> scaffold a portfolio site with framer motion
> vibe code an inventory tool with sqlite
> make me a fastapi todo backend with jwt auth
```

Each one of these, run in a Copilot/Claude/Codex chat with myVibe installed, produces a real, tested, running project in a single end-to-end session.

---

## Install options

### Pin a version (recommended for teams)
```powershell
# Windows
iex "& { $(iwr https://raw.githubusercontent.com/Mohamed201389/myVibe/main/bootstrap.ps1) } -Ref v1.4"
```
```bash
# macOS / Linux
MV_REF=v1.4 curl -fsSL https://raw.githubusercontent.com/Mohamed201389/myVibe/main/bootstrap.sh | bash
```

### Symlink (live-update) mode
```powershell
iex "& { $(iwr https://raw.githubusercontent.com/Mohamed201389/myVibe/main/bootstrap.ps1) } -Symlink"
```
```bash
MV_SYMLINK=true curl -fsSL https://raw.githubusercontent.com/Mohamed201389/myVibe/main/bootstrap.sh | bash
```

### Install only specific agents
After cloning, run with `--targets`:
```bash
./install.sh --targets=claude,codex
```
```powershell
pwsh -File ./install.ps1 -Targets claude,codex
```

### Clone-and-inspect (audit-friendly)
```bash
git clone https://github.com/Mohamed201389/myVibe.git
cd myVibe
less bootstrap.sh   # inspect
./install.sh        # install
```

See [INSTALL.md](INSTALL.md) for full options and [PUBLISH.md](PUBLISH.md) for republishing the kit under your own org.

---

## File index

| File | Purpose |
|---|---|
| `SKILL.md` | Skill manifest — auto-invocation by trigger phrases (Claude / Copilot) |
| `myvibe.prompt.md` | VS Code Copilot prompt file (`/myvibe`) |
| `AGENTS.template.md` | Per-project rules template (drop into any repo) |
| `INTAKE.md` | **One-shot discovery form** — runs before Phase 1 |
| `00-START-HERE.md` | Master orchestration prompt (Phases 1–7, Ralph-style feature loop) |
| `01-plan.md` → `14-quality-gates.md` | Phase playbooks |
| `install.ps1` / `install.sh` | Multi-agent local installer |
| `bootstrap.ps1` / `bootstrap.sh` | Remote one-line installer (clone + install + cleanup) |
| `myvibe-init.ps1` / `myvibe-init.sh` | Per-project setup — drops AGENTS.md, CLAUDE.md, .cursorrules, etc. |
| `INSTALL.md` | Full install guide |
| `PUBLISH.md` | Publishing / forking guide |
| `LAUNCH.md` | Go-to-market checklist (for maintainers) |
| `CHANGELOG.md` | Release history |

---

## Philosophy

- **Localhost-first.** Deployment is out of scope on purpose.
- **Latest stable APIs.** No deprecated libraries, no Node 16, no React 17.
- **One feature, one commit.** No mega-PRs.
- **Failing test first.** No green, no commit.
- **Three retries, then ask.** Agent doesn't grind forever.
- **No emojis in code or output.**
- **Conventional commits.**
- **Root cause before fix.** No band-aids.

Read the full conventions in `12-code-style.md` and `13-debugging.md`.

---

## Contributing

PRs welcome. Keep the kit:
- **Vendor-neutral** — anything specific to one IDE or model goes behind a clear toggle.
- **Short.** Files should be readable in one sitting.
- **Opinionated.** "Pick one default" beats "list every option".

---

## Guides

In-depth articles on the patterns behind myVibe — also useful on their own:

- [What is vibe coding? A 2026 guide](https://mohamed201389.github.io/myVibe/vibe-coding.html)
- [AGENTS.md vs CLAUDE.md vs .cursorrules](https://mohamed201389.github.io/myVibe/agents-md.html)
- [How to build a Claude Code skill](https://mohamed201389.github.io/myVibe/claude-code-skills.html)
- [Cursor rules that actually work](https://mohamed201389.github.io/myVibe/cursor-rules.html)

Live site: **https://mohamed201389.github.io/myVibe/**

---

## License

MIT — see [LICENSE](LICENSE).

---

## Keywords

AI coding agent · Claude Code skill · GitHub Copilot prompt · OpenAI Codex CLI · Cursor rules · Windsurf · vibe coding · AI app builder · one-shot project scaffold · localhost-first · React Vite TypeScript · Tailwind shadcn · Fastify Prisma · FastAPI uv · AGENTS.md · CLAUDE.md · `.cursorrules` · slash command · model-agnostic.
