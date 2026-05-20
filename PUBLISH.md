# Publishing the Kit to GitHub

Make the kit installable from anywhere with one command.

---

## One-time: publish the repo

From inside the `myvibe/` folder:

```bash
git init
git add .
git commit -m "feat: initial myVibe"
git branch -M main

# Create repo and push (GitHub CLI)
gh repo create myvibe --public --source=. --remote=origin --push

# OR manually after creating the repo on github.com:
# git remote add origin https://github.com/<you>/myvibe.git
# git push -u origin main
```

Then edit `bootstrap.sh` and `bootstrap.ps1` — replace `REPLACE_ME` with your GitHub username/org in the `REPO` variable, commit, push.

---

## After publishing — one-line remote install

Anyone, on any device, runs **one line**:

### Windows
```powershell
iwr https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.ps1 | iex
```

### macOS / Linux
```bash
curl -fsSL https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.sh | bash
```

These bootstrap scripts:
1. Verify `git` is installed
2. Shallow-clone the kit to a temp folder
3. Run `install.ps1` / `install.sh` automatically
4. Clean up the temp folder

End result on the user's machine: `/myvibe` slash command + auto-invoking Copilot skill, identical to a local install.

---

## Symlink (live-update) remote install

If the user wants their installed copy to track the GitHub repo so updates pull in instantly:

### Windows (run as Administrator)
```powershell
$env:MV_SYMLINK='true'; iwr https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.ps1 | iex
```
Persists the clone at `%LOCALAPPDATA%\myvibe`.

### macOS / Linux
```bash
MV_SYMLINK=true curl -fsSL https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.sh | bash
```
Persists the clone at `~/.local/share/myvibe`.

To update later:
```bash
git -C ~/.local/share/myvibe pull
```
Or just re-run the bootstrap command — it does a `git fetch + reset` for you.

---

## Pinning a version

For repeatable installs in teams, pin to a tag:

```bash
MV_REF=v1.2 curl -fsSL https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.sh | bash
```
```powershell
iex "& { $(iwr https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.ps1) } -Ref v1.2"
```

Cut a tag with:
```bash
git tag v1.2 -m "Kit v1.2"
git push --tags
```

---

## Private repo? Use SSH or a PAT

If the repo is private, swap the clone URL:

```bash
# SSH (uses your ~/.ssh/id_*.pub)
MV_REPO=git@github.com:<you>/myvibe.git curl -fsSL https://raw.githubusercontent.com/.../bootstrap.sh | bash

# HTTPS + PAT (avoid baking the token into shell history; use a credential helper)
MV_REPO=https://<token>@github.com/<you>/myvibe.git ...
```

For curl to fetch the bootstrap from a private repo, use the GitHub raw API with a token header, then pipe:

```bash
curl -fsSL -H "Authorization: token $GH_TOKEN" \
  https://raw.githubusercontent.com/<you>/myvibe/main/bootstrap.sh | bash
```

---

## Update workflow (kit maintainer)

```bash
# Edit any file in the kit
git add .
git commit -m "feat: tighten phase 5 loop"
git tag v1.3 -m "Kit v1.3"
git push && git push --tags
```

Anyone who installed via `--symlink` and pulls (or re-runs bootstrap) gets the update instantly.
Anyone who installed via plain copy re-runs the one-line bootstrap to refresh.

---

## Note on `curl | bash`

The pattern `curl ... | bash` is convenient but trusts the URL. Mitigations:
- Pin the ref (`MV_REF=v1.2`) so you control exactly what runs.
- Inspect first: `curl ... | less` before piping to `bash`.
- For audited installs, document the two-step alternative in your README:
  ```bash
  curl -fsSL .../bootstrap.sh -o bootstrap.sh
  less bootstrap.sh   # inspect
  bash bootstrap.sh
  ```

The bootstrap scripts here are intentionally short (~30 lines) so they're easy to audit.
