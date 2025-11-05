# RepoZipper Cloud (gh-rz)
A read‑only, Git‑native backup for your GitHub account. Installs as a GitHub CLI extension or runs directly from this megazip.

## Quickstart (from this megazip)
```pwsh
# 1) Extract the zip
# 2) Dry run (lists targets safely):
pwsh -NoProfile -File .\payload\ops\run-gh-rz.ps1 -OutDir "$HOME\Desktop\CoSuiteBackup" -User $(gh api user --jq '.login') -Skip "AmpliPi","micro-nova/*","*/AmpliPi","*AmpliPi*" -Mode DryRun

# 3) Real run:
pwsh -NoProfile -File .\payload\ops\run-gh-rz.ps1 -OutDir "$HOME\Desktop\CoSuiteBackup" -User $(gh api user --jq '.login') -Skip "AmpliPi","micro-nova/*","*/AmpliPi","*AmpliPi*"
```
## Requirements
- Windows 10/11 (PowerShell 7.4+), Git 2.35+, GitHub CLI 2.x (`gh auth login`)
- Disk space for your repos; stable network
- Optional: `Out-GridView` for checkbox selection (`-Select`)

## What it does
- Mirrors only repos you **own** by default (excludes forks/archived)
- Filter with `-Include` / `-Skip` (wildcards), or choose with `-Select`
- Produces local mirrors + dated zips + `_RECEIPTS/run.log`
- Integrity checks with `git fsck`; **no pushes**, **no telemetry**

## Restore
- From mirror: `git clone --mirror <repo>.git` → downstream `git clone <mirror>`
- From bundle (if you later add bundles): `git bundle verify` then `git fetch`

## Uninstall
Megazip is portable. To remove, just delete the extracted folder. If installed as a gh extension:
```pwsh
gh extension remove rickballard/gh-rz
```
