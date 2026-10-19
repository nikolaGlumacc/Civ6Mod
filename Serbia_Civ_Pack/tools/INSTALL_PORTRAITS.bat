@echo off
cd /d "%~dp0"
echo ========================================
echo  Serbia Civ Pack - Install Leader Faces
echo ========================================
echo.
python "%~dp0apply_tar.py"
if errorlevel 1 py "%~dp0apply_tar.py"
if errorlevel 1 (
  echo.
  echo Need Python. Install from https://www.python.org/downloads/
  echo Check "Add Python to PATH", then run this again.
)
echo.
pause
