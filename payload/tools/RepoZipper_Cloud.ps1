param(
  [string]$User,
  [string]$OutDir,
  [string[]]$Skip = @(),
  [string[]]$Include = @(),
  [string]$Org,
  [switch]$Select,
  [int]$DotEveryMB = 25
)
$ErrorActionPreference='Stop'

# Resolve owner
$owner = if ($Org) { $Org } else { $User }
if (-not $owner) { throw "No owner provided." }

# Receipts
$ReceiptRoot = Join-Path $OutDir '_RECEIPTS'
New-Item -ItemType Directory -Force -Path $OutDir,$ReceiptRoot | Out-Null
$RunLog = Join-Path $ReceiptRoot ("run_{0}.log" -f (Get-Date).ToString('yyyyMMdd_HHmmss'))

function Note($s){ $s | Tee-Object -FilePath $RunLog -Append }

Note ("RepoZipper Cloud run {0}" -f (Get-Date))
Note ("Owner: {0}" -f $owner)
Note ("OutDir: {0}" -f $OutDir)
if($Skip.Count){ Note ("Skip: {0}" -f ($Skip -join ', ')) }
if($Include.Count){ Note ("Include: {0}" -f ($Include -join ', ')) }

# Repo discovery
$raw = gh repo list $owner --limit 500 --json nameWithOwner,isFork,isArchived,isPrivate,visibility | ConvertFrom-Json
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

if ($Select) {
  if (Get-Command Out-GridView -ErrorAction SilentlyContinue) {
    $chosen = $repos | Select-Object nameWithOwner,isPrivate,visibility | Out-GridView -PassThru -Title "Select repos to back up"
    if ($chosen) { $repos = $chosen }
  } else {
    $i=0; $map=@{}
    $repos | ForEach-Object { $i++; $map[$i]=$_; "{0,3}. {1}" -f $i,$_.nameWithOwner | Write-Host }
    $ans = Read-Host "Enter numbers/ranges (e.g. 1,3-5) or blank to keep all"
    if ($ans) {
      $pick=@()
      foreach($tok in $ans.Split(',').ForEach({ $_.Trim() })) {
        if ($tok -match '^\d+-\d+$') { $a,$b = $tok -split '-',2; $pick += [int]$a..[int]$b }
        elif ($tok -match '^\d+$') { $pick += [int]$tok }
      }
      $repos = $pick | ForEach-Object { $map[$_] } | Where-Object { $_ }
    }
  }
}

$n = $repos.Count
$idx = 0

foreach ($r in $repos) {
  $idx++
  $name = $r.nameWithOwner
  $safe = ($name -replace '[^\w\.-]','_').Split('/')[-1] + '.git'
  $repoDir = Join-Path $OutDir $safe

  Write-Progress -Activity "Backing up repositories" -Status ("{0} ({1}/{2})" -f $name,$idx,$n) -PercentComplete ([int](100*$idx/$n))
  Note ("[{0}/{1}] {2}: updating mirror" -f $idx,$n,$name)

  if (Test-Path $repoDir) {
    $proc = Start-Process git -ArgumentList @('-C',$repoDir,'fetch','--prune','--all','--tags','--quiet') -PassThru -WindowStyle Hidden
    while(-not $proc.HasExited){ Start-Sleep -Milliseconds 250 }
  } else {
    $url = "https://github.com/{0}.git" -f $name
    $proc = Start-Process git -ArgumentList @('clone','--mirror',$url,$repoDir) -PassThru -WindowStyle Hidden
    while(-not $proc.HasExited){ Start-Sleep -Milliseconds 250 }
  }

  git -C $repoDir fsck --no-dangling 1>$null 2>$null
}

Write-Progress -Activity "Backing up repositories" -Completed

$stamp = (Get-Date).ToString('yyyyMMdd')
$daily = Join-Path $OutDir $stamp
New-Item -ItemType Directory -Force -Path $daily | Out-Null
$repos | Select-Object -ExpandProperty nameWithOwner | Set-Content -Encoding UTF8 (Join-Path $daily 'repos.txt')

