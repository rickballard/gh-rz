param(
  [string]$OutDir = (Join-Path $HOME "Desktop/CoSuiteBackup"),
  [string]$User   = $(gh api user --jq ".login"),
  [ValidateSet('DryRun','Real')][string]$Mode = 'Real',
  [string[]]$Skip = @()
)
$ErrorActionPreference='Stop'
$ReceiptRoot = Join-Path $OutDir '_RECEIPTS'
New-Item -ItemType Directory -Force -Path $OutDir,$ReceiptRoot | Out-Null
$Log = Join-Path $ReceiptRoot ("run_{0}.log" -f (Get-Date).ToString('yyyyMMdd_HHmmss'))

function Note($s){ $s | Tee-Object -FilePath $Log -Append }

Note ("Runner start {0}" -f (Get-Date))
Note ("User: {0}" -f $User)
Note ("OutDir: {0}" -f $OutDir)
if($Skip.Count){ Note ("Skip: {0}" -f ($Skip -join ', ')) }
Note ("Mode: {0}" -f $Mode)

$wrapper = Resolve-Path (Join-Path $PSScriptRoot '..\gh-rz.ps1')

if ($Mode -eq 'DryRun') {
  $list = & pwsh -NoLogo -NoProfile -File $wrapper -DryRun -User $User -Skip $Skip
  $list | Sort-Object | Tee-Object -FilePath (Join-Path $ReceiptRoot 'dryrun_list.txt')
  Note ("DryRun count: {0}" -f ($list.Count))
  exit 0
}

& pwsh -NoLogo -NoProfile -File $wrapper -User $User -OutDir $OutDir -Skip $Skip
Note ("ExitCode: {0}" -f $LASTEXITCODE)
exit $LASTEXITCODE
