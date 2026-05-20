#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Install myVibe everywhere — VS Code Copilot, Claude Code, OpenAI Codex CLI, Cursor.

.DESCRIPTION
  Copies the kit and registers it with every detected coding agent on the system:
    - VS Code Copilot   : copies prompt to user prompts dir (slash command /myvibe)
    - Claude Code       : copies skill to ~/.claude/skills/myvibe/ + adds reference to ~/.claude/CLAUDE.md
    - OpenAI Codex CLI  : copies skill to ~/.codex/skills/myvibe/
    - Cursor            : drops rules template at ~/.cursor/rules/myvibe.mdc
    - Generic           : ~/.agents/skills/myvibe/ (used by other agents that follow this convention)

.PARAMETER Source
  Path to the myvibe folder. Defaults to the script's parent folder.

.PARAMETER Symlink
  Create symlinks instead of copies, so future edits sync automatically. Requires admin on Windows.

.PARAMETER Targets
  Comma-separated list of targets to install. Default: all.
  Valid values: copilot, claude, codex, cursor, generic.
#>
param(
  [string]$Source   = (Split-Path -Parent $PSCommandPath),
  [switch]$Symlink,
  [string]$Targets  = 'all'
)

$ErrorActionPreference = 'Stop'
$IsWin = $IsWindows -or $env:OS -eq 'Windows_NT'

function Get-VSCodeUserDir {
  if ($IsWin)        { return Join-Path $env:APPDATA 'Code\User' }
  elseif ($IsMacOS)  { return Join-Path $HOME 'Library/Application Support/Code/User' }
  else               { return Join-Path $HOME '.config/Code/User' }
}

function Install-Path {
  param([string]$From, [string]$To, [switch]$Sym)
  $parent = Split-Path -Parent $To
  if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
  if (Test-Path $To) { Remove-Item $To -Recurse -Force }
  if ($Sym) {
    try {
      New-Item -ItemType SymbolicLink -Path $To -Target $From | Out-Null
      Write-Host "  linked: $To" -ForegroundColor Cyan
    } catch {
      Write-Warning "Symlink failed for $To (need admin). Falling back to copy."
      if ((Get-Item $From).PSIsContainer) { Copy-Item $From $To -Recurse } else { Copy-Item $From $To }
      Write-Host "  copied: $To" -ForegroundColor Green
    }
  } else {
    if ((Get-Item $From).PSIsContainer) { Copy-Item $From $To -Recurse } else { Copy-Item $From $To }
    Write-Host "  copied: $To" -ForegroundColor Green
  }
}

if (-not (Test-Path (Join-Path $Source 'SKILL.md'))) {
  Write-Error "SKILL.md not found in $Source. Pass -Source <path-to-myvibe>."
  exit 1
}

$kitName    = 'myvibe'
$promptName = 'myvibe.prompt.md'
$promptSrc  = Join-Path $Source $promptName

$wanted = $Targets.ToLower().Split(',') | ForEach-Object { $_.Trim() }
$all = $wanted -contains 'all'

Write-Host ""
Write-Host "Installing myVibe..." -ForegroundColor Yellow
Write-Host "  Source: $Source"
Write-Host ""

if ($all -or $wanted -contains 'generic') {
  Write-Host "[generic] ~/.agents/skills/" -ForegroundColor Magenta
  Install-Path -From $Source -To (Join-Path $HOME ".agents/skills/$kitName") -Sym:$Symlink
}

if ($all -or $wanted -contains 'copilot') {
  Write-Host "[copilot] VS Code prompt" -ForegroundColor Magenta
  Install-Path -From $promptSrc -To (Join-Path (Get-VSCodeUserDir) "prompts/$promptName") -Sym:$Symlink
}

if ($all -or $wanted -contains 'claude') {
  Write-Host "[claude] Claude Code skill" -ForegroundColor Magenta
  Install-Path -From $Source -To (Join-Path $HOME ".claude/skills/$kitName") -Sym:$Symlink
  $claudeMd = Join-Path $HOME ".claude/CLAUDE.md"
  if (-not (Test-Path (Split-Path -Parent $claudeMd))) { New-Item -ItemType Directory -Force -Path (Split-Path -Parent $claudeMd) | Out-Null }
  if (-not (Test-Path $claudeMd)) { New-Item -ItemType File -Force -Path $claudeMd | Out-Null }
  $existing = Get-Content $claudeMd -Raw -ErrorAction SilentlyContinue
  if (-not ($existing -match 'myVibe')) {
    Add-Content -Path $claudeMd -Value "`n## myVibe`n`nWhen the user gives a one-line project command, follow the myVibe skill at ~/.claude/skills/myvibe/SKILL.md.`n"
    Write-Host "  added: myVibe section to ~/.claude/CLAUDE.md" -ForegroundColor Green
  }
}

if ($all -or $wanted -contains 'codex') {
  Write-Host "[codex] Codex CLI skill" -ForegroundColor Magenta
  Install-Path -From $Source -To (Join-Path $HOME ".codex/skills/$kitName") -Sym:$Symlink
}

if ($all -or $wanted -contains 'cursor') {
  Write-Host "[cursor] Cursor rules template" -ForegroundColor Magenta
  Install-Path -From (Join-Path $Source 'AGENTS.template.md') -To (Join-Path $HOME ".cursor/rules/myvibe.mdc") -Sym:$Symlink
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Quick start:"
Write-Host "  VS Code Copilot : reload window, type '/myvibe' — works for new projects AND for editing/debugging existing ones (auto-detects)"
Write-Host "  Claude Code     : 'use the myvibe skill to build a kanban app'"
Write-Host "  Codex CLI       : 'use the myvibe skill: build me a kanban app'"
Write-Host "  Any agent       : 'build me a kanban app' (auto-matches via skill description)"
Write-Host ""
Write-Host "Per-project setup (drops AGENTS.md + CLAUDE.md + .cursorrules):"
Write-Host "  pwsh -File ~/.agents/skills/myvibe/myvibe-init.ps1"
