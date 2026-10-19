@echo off
cd /d "%~dp0"
echo Installing Serbia leader portraits into Art...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Apply-Portraits.ps1"
if errorlevel 1 (
  echo Trying Python fallback...
  python "%~dp0apply_portraits.py"
)
echo.
pause
