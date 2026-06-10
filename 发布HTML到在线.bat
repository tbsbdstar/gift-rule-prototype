@echo off
chcp 65001 >nul
set "PROJ="
set /p "PROJ=Project subfolder name (drag a folder? just press Enter): "
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish.ps1" -Project "%PROJ%" %*
echo.
pause
