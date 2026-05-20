# Per-project initializer: drop agent rule files into the current repo.
# Run from inside the project root.
param([string]$Source = (Split-Path -Parent $PSCommandPath))
$ErrorActionPreference = 'Stop'

$tplPath = Join-Path $Source 'AGENTS.template.md'
if (-not (Test-Path $tplPath)) { Write-Error "AGENTS.template.md not found in $Source"; exit 1 }
$tpl = Get-Content $tplPath -Raw

$targets = @(
  @{ Path='AGENTS.md';      Label='Codex / OpenAI / generic' }
  @{ Path='CLAUDE.md';      Label='Claude Code' }
  @{ Path='.cursorrules';   Label='Cursor' }
  @{ Path='.windsurfrules'; Label='Windsurf' }
  @{ Path='.github/copilot-instructions.md'; Label='GitHub Copilot' }
)

Write-Host "Initializing myVibe rules in $(Get-Location)..." -ForegroundColor Yellow
foreach ($t in $targets) {
  $dst = $t.Path
  $dir = Split-Path -Parent $dst
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $dst) {
    Write-Host "  exists, skipped: $dst ($($t.Label))" -ForegroundColor DarkGray
  } else {
    Set-Content -Path $dst -Value $tpl -NoNewline
    Write-Host "  created: $dst ($($t.Label))" -ForegroundColor Green
  }
}
Write-Host ""
Write-Host "Done. Commit these files so the whole team's agents follow the same rules."
