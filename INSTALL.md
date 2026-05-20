# Install Guide

Install the myVibe on any device so `/myvibe` becomes a slash command in VS Code Copilot Chat **everywhere**.

---

## One-line install

### Windows (PowerShell — works on stock Windows 10/11)
```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
Or if you have PowerShell 7+ (`pwsh`):
```powershell
pwsh -File .\install.ps1
```

### macOS / Linux (bash)
```bash
chmod +x install.sh
./install.sh
```

That's it. The script copies:
- The kit folder → `~/.agents/skills/myvibe/` (auto-discovered Copilot skill)
- The prompt file → VS Code's user prompts folder (gives you `/myvibe` slash command)

After install, **reload VS Code** (`Cmd/Ctrl+Shift+P` → "Developer: Reload Window").

---

## Symlink mode (recommended for kit maintainers)

If you'll keep editing the kit and want the installed copy to stay in sync automatically:

```powershell
# Windows — needs Admin PowerShell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -Symlink
```

```bash
# macOS / Linux
./install.sh --symlink
```

Now every edit you make to the source folder is reflected instantly in the installed skill and prompt.

---

## Where files end up

| OS | VS Code prompts | Agent skills |
|---|---|---|
| Windows | `%APPDATA%\Code\User\prompts\` | `%USERPROFILE%\.agents\skills\` |
| macOS | `~/Library/Application Support/Code/User/prompts/` | `~/.agents/skills/` |
| Linux | `~/.config/Code/User/prompts/` | `~/.agents/skills/` |

---

## After install — how to use

### Option 1 — Slash command
1. Open Copilot Chat
2. Type `/` → pick `myvibe`
3. Enter your project command when prompted

### Option 2 — Natural language (auto-invoke)
Just type in Copilot Chat:
> "Build me a kanban app with drag-and-drop"

The skill's description matches that phrase and auto-loads. No `/` needed.

### Option 3 — Workspace-scoped slash command
If you want this slash command for one project only, drop the prompt file at:
```
<repo>/.github/prompts/myvibe.prompt.md
```
That overrides the user-level one in that repo.

---

## Uninstall

### Windows
```powershell
Remove-Item "$env:APPDATA\Code\User\prompts\myvibe.prompt.md" -Force
Remove-Item "$env:USERPROFILE\.agents\skills\myvibe" -Recurse -Force
```

### macOS / Linux
```bash
rm "$HOME/Library/Application Support/Code/User/prompts/myvibe.prompt.md"   # macOS
# or
rm "$HOME/.config/Code/User/prompts/myvibe.prompt.md"                       # Linux
rm -rf "$HOME/.agents/skills/myvibe"
```

---

## Updating

If you cloned the kit and the source updates (new version, new files), just re-run the install script — it overwrites cleanly.

If you installed with `--symlink`, you don't need to re-run anything; edits propagate live.

---

## Distribution: one-line remote install (when published to GitHub)

Once the kit is pushed to a GitHub repo, anyone on any device can install with **one line** — no manual clone needed. The included `bootstrap.sh` / `bootstrap.ps1` handle the clone + install + cleanup automatically.

### Windows
```powershell
iwr https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.ps1 | iex
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.sh | bash
```

See [PUBLISH.md](PUBLISH.md) for:
- How to publish the repo (one-time setup)
- Symlink / live-update remote install
- Pinning a version (`MV_REF=v1.2`)
- Private-repo install with SSH or PAT
- Update workflow for maintainers

---

## Why not a `.exe` / `.pkg` installer?

Honest answer: **it's not worth the cost.**

A native installer means:
- Windows: Inno Setup / WiX, plus an EV code-signing certificate ($200–500/year) to avoid SmartScreen warnings
- macOS: `.pkg` or `.dmg`, plus Apple Developer signing + notarization ($99/year) to avoid Gatekeeper warnings
- Maintenance across OS versions and architectures (x64, ARM64)
- An installer UI for what is fundamentally `cp -r` to two known folders

The kit is **markdown files**. A 200-line install script delivers the same result with:
- Zero signing cost
- Zero installer-UI bugs
- Trivial uninstall
- Auditable source (anyone can read what it does before running)
- Same code path on Windows, macOS, and Linux

If you ever do need a `.exe` (e.g. for non-technical users on Windows), the upgrade path is:
1. Publish kit to npm or a GitHub release
2. Use **`pkg`** or **`Nuitka`** to wrap a small JS/Python launcher into a single binary that downloads and runs the install script

But for any user who's already running VS Code + a coding agent — meaning they have a shell — the script is strictly better than an installer.
