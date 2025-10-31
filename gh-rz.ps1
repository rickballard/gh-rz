param(
  [Parameter(Mandatory=$true)][string]$User,
  [string]$OutDir = (Join-Path $HOME "Desktop/CoSuiteBackup"),
  [string[]]$Skip = @(),
  [int]$DotEveryMB = 25
)
$ErrorActionPreference = 'Stop'
$script = Join-Path $PSScriptRoot 'tools' 'RepoZipper_Cloud.ps1'
# Allow repo-relative path too (for bundled tools)
if (-not (Test-Path $script)) {
  $script = Join-Path (Split-Path -Parent $PSScriptRoot) 'tools' 'RepoZipper_Cloud.ps1'
}
if (-not (Test-Path $script)) { throw "Repo script not found: $script" }

& pwsh -NoLogo -NoProfile -File $script `
  -User $User -OutDir $OutDir -Skip $Skip -DotEveryMB $DotEveryMB
exit $LASTEXITCODE
