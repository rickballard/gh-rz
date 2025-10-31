param(
  [string]$User,
  [string]$OutDir = (Join-Path $HOME "Desktop/CoSuiteBackup"),
  [string[]]$Skip = @(),
  [int]$DotEveryMB = 25
)
$script = Join-Path (Split-Path -Parent $PSScriptRoot) "tools/RepoZipper_Cloud.ps1"
& pwsh -File $script -User $User -OutDir $OutDir -Skip $Skip -DotEveryMB $DotEveryMB
