<#
.SYNOPSIS
  Remote bootstrap for the myVibe (Windows).

.DESCRIPTION
  Clones the public repo to a temp folder, runs install.ps1, cleans up.

.EXAMPLE
  iwr https://raw.githubusercontent.com/<owner>/myvibe/main/bootstrap.ps1 | iex

.PARAMETER Repo
  Override repo URL.

.PARAMETER Ref
  Branch, tag, or commit SHA. Default: main.

.PARAMETER Symlink
  Install in symlink mode. Persists the clone to %LOCALAPPDATA%\myvibe so links stay valid. Requires admin.
#>
param(
  [string]$Repo    = 'https://github.com/Mohamed201389/myvibe.git',
  [string]$Ref     = 'main',
  [switch]$Symlink
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Error "git is required. Install Git for Windows: https://git-scm.com/download/win"
  exit 1
}

function Invoke-Install {
  param([string]$KitPath, [bool]$DoSymlink)
  $installer = Join-Path $KitPath 'install.ps1'
  $args = @('-ExecutionPolicy','Bypass','-File',$installer)
  if ($DoSymlink) { $args += '-Symlink' }
  & powershell @args
}

if ($Symlink) {
  $target = Join-Path $env:LOCALAPPDATA 'myvibe'
  if (Test-Path (Join-Path $target '.git')) {
    git -C $target fetch --quiet --depth 1 origin $Ref
    git -C $target checkout --quiet $Ref
    git -C $target reset --hard --quiet "origin/$Ref" 2>$null
  } else {
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    git clone --quiet --depth 1 --branch $Ref $Repo $target
  }
  Invoke-Install -KitPath $target -DoSymlink $true
} else {
  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("mv-" + [guid]::NewGuid().ToString('N'))
  try {
    git clone --quiet --depth 1 --branch $Ref $Repo $tmp
    Invoke-Install -KitPath $tmp -DoSymlink $false
  } finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue }
  }
}
