param([ValidateSet("Prompt","Default")][string]$Mode="Prompt")
$ErrorActionPreference='Stop'
function Say($m){ Write-Host "[gh-rz] $m" }
if(-not (Get-Command gh -ErrorAction SilentlyContinue)){ throw "GitHub CLI 'gh' is not installed." }
if(-not (gh extension list | Select-String -Quiet 'rickballard/gh-rz')){ Say "Installing gh extension rickballard/gh-rz…"; gh extension install rickballard/gh-rz | Out-Null }
$user = gh api user --jq .login
$defaultOut = Join-Path $HOME "Desktop/GitHubRepoBackups"
$outDir = $defaultOut
if($Mode -eq 'Prompt'){ $ans = Read-Host "Output folder [$defaultOut]"; if($ans){ $outDir = $ans } }
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
Say "Running backup for @$user to $outDir"
gh rz -User $user -OutDir $outDir
Say "Done."