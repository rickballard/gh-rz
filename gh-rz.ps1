param(
  [Alias("h","?")][switch]$Help,
  [string]$User,
  [string]$OutDir = (Join-Path $HOME "Desktop/CoSuiteBackup"),
  [string[]]$Skip = @(),
  [int]$DotEveryMB = 25
)

function Show-Usage {
@"
RepoZipper Cloud (read-only GitHub backup)
USAGE:
  gh rz -User <github_login> [-OutDir <path>] [-Skip <name> ...] [-DotEveryMB <int>]

EXAMPLES:
  gh rz -User me
  gh rz -User me -OutDir "$HOME\Desktop\CoSuiteBackup" -Skip @("big-repo","archive-*") -DotEveryMB 100

NOTES:
  - Read-only: no pushes, no telemetry, local-only output.
  - See TRUST.md and README ('Verify read-only').
"@ | Write-Host
}

if ($Help -or -not $PSBoundParameters.ContainsKey('User')) {
  Show-Usage
  exit 0
}

$ErrorActionPreference='Stop'
# Prefer local tools/ in the extension checkout (for dev)
$script = Join-Path $PSScriptRoot 'tools' 'RepoZipper_Cloud.ps1'
if (-not (Test-Path $script)) {
  # Fallback: CoSuiteBackup repo tools/
  $script = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools' 'RepoZipper_Cloud.ps1'
}
if (-not (Test-Path $script)) { throw "Repo script not found: $script" }

# Forward with explicit binding to avoid empty Skip errors
& pwsh -NoLogo -NoProfile -File $script `
  -User $User -OutDir $OutDir -Skip $Skip -DotEveryMB $DotEveryMB
exit $LASTEXITCODE

