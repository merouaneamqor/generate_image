@echo off
setlocal
REM Run from repo root: scripts\gem-docker.cmd build | push
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0gem-docker.ps1" %*
exit /b %ERRORLEVEL%
