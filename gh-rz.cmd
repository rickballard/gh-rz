@echo off
setlocal
set "SCRIPT=%~dp0gh-rz.ps1"
pwsh -NoLogo -NoProfile -File "%SCRIPT%" %*
