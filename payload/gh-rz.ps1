param(
  [Alias('h','?')][switch]$Help,
  [string]$User,
  [string]$OutDir = (Join-Path $HOME "Desktop/CoSuiteBackup"),
  [string[]]$Skip = @(),
  [string[]]$Include = @(),
  [string]$Org,
  [switch]$Select,
  [switch]$DryRun,
  [int]$DotEveryMB = 25
)

function Show-Usage {
@"
RepoZipper Cloud (read-only GitHub backup)
USAGE:
  gh rz [-User <github_login>] [-OutDir <path>] [-Skip <name> ...] [-DotEveryMB <int>]
EXAMPLES:
  gh rz
  gh rz -User me -OutDir "$HOME\Desktop\CoSuiteBackup" -Skip @("big-repo","archive-*") -DotEveryMB 100
NOTES:
  - Read-only: no pushes, no telemetry, local-only output.
  - See TRUST.md and README ('Verify read-only').
"@ | Write-Host
}

if ($Help) { Show-Usage; exit 0 }

if (-not $PSBoundParameters.ContainsKey('User')) {
  try {
    $User = gh api user --jq '.login'
    if (-not $User) { throw "no login" }
  } catch {
    Show-Usage
    Write-Host "`nTip: run 'gh auth login' or pass -User <login>." -ForegroundColor Yellow
    exit 1
  }
}

function Test-RzScript([string]$p){
  if([string]::IsNullOrWhiteSpace($p)){ return $false }
  if(-not (Test-Path -LiteralPath $p)){ return $false }
  $line = (Get-Content -LiteralPath $p -First 1 -ErrorAction SilentlyContinue)
  if ($null -eq $line) { return $false }
  $s = ($line | Out-String).TrimStart()
  return -not ($s.StartsWith('{') -or $s.StartsWith('<'))
}

# Use the copy in ./tools relative to this wrapper
$script = Join-Path $PSScriptRoot 'tools\RepoZipper_Cloud.ps1'
if(-not (Test-RzScript $script)){ throw "Repo script not found or invalid: $script" }

# DryRun list (wrapper-side)
if ($DryRun) {
  $owner = if ($Org) { $Org } else { $User }
  $raw = gh repo list $owner --limit 500 --json nameWithOwner,isFork,isArchived | ConvertFrom-Json
  $repos = $raw | Where-Object { -not $_.isFork -and -not $_.isArchived }
  if ($Include -and $Include.Count) {
    $repos = $repos | Where-Object {
      $n = $_.nameWithOwner
      $Include | Where-Object { $n -like $_ } | ForEach-Object { return $true }
      $false
    }
  }
  if ($Skip -and $Skip.Count) {
    $repos = $repos | Where-Object {
      $n = $_.nameWithOwner
      -not ($Skip | Where-Object { $n -like $_ })
    }
  }
  $repos | Select-Object -ExpandProperty nameWithOwner
  return
}

# Splat into inner script
$invoke = @{
  User       = $User
  OutDir     = $OutDir
  DotEveryMB = $DotEveryMB
}
if ($Skip    -and $Skip.Count)    { $invoke['Skip']    = $Skip }
if ($Include -and $Include.Count) { $invoke['Include'] = $Include }
if ($Org)                         { $invoke['Org']     = $Org }
if ($Select)                      { $invoke['Select']  = $Select }

& $script @invoke
exit $LASTEXITCODE
