@echo off
cd /d "%~dp0"
echo ========================================
echo  Serbia Civ Pack - Install Leader Faces
echo ========================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Run-Install.ps1"
if errorlevel 1 (
  echo Failed. You can also run: python apply_portraits.py
  echo after portrait_data is present.
)
echo.
pause
