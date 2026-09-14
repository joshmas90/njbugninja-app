@echo off
setlocal
cd /d "%~dp0"
if not exist "MosquitoNinja.xcodeproj\project.pbxproj" goto wrongfolder
if exist ".git" goto existing
where git >nul 2>nul
if errorlevel 1 goto failed
git init -b main
if errorlevel 1 goto failed
git remote add origin https://github.com/joshmas90/njbugninja-app.git
if errorlevel 1 goto failed
git fetch origin
if errorlevel 1 goto failed
git reset --mixed 8718424aa9790dc89f078865bc1c111a24f78db1
if errorlevel 1 goto failed
git add -A
if errorlevel 1 goto failed
git commit -m "Use throwing-star logo for app icon and launch screen"
if errorlevel 1 goto failed
git rebase origin/main
if errorlevel 1 goto failed
git push -u origin HEAD:main
if errorlevel 1 goto failed
echo.
echo SUCCESS: uploaded to joshmas90/njbugninja-app main.
echo Read AUDIT-NOTES.md for the remaining release checks.
pause
exit /b 0
:wrongfolder
echo This script must run inside the extracted njbugninja-app update folder.
pause
exit /b 1
:existing
echo This folder already has Git history. No changes were made.
echo Use a fresh extraction, or send the existing git status for guidance.
pause
exit /b 1
:failed
echo.
echo Upload stopped. Copy the error above for help before continuing.
echo No force-push is used by this script.
pause
exit /b 1
