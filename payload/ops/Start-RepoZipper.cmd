@echo off
setlocal
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-gh-rz.ps1" -Mode Prompt
pause
