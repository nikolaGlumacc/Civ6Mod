@echo off
cd /d "%~dp0"
echo ========================================
echo  Serbia Civ Pack - Install Leader Faces
echo ========================================
echo.
echo This writes portrait DDS files into the Art folder.
echo.
python "%~dp0apply_portraits_full.py"
if errorlevel 1 (
  echo Python failed - trying py launcher...
  py "%~dp0apply_portraits_full.py"
)
if errorlevel 1 (
  echo.
  echo Still failed. Install Python from python.org, then double-click this again.
  echo Or extract Serbia_Leader_Portraits_READY.zip into the Art folder.
)
echo.
pause
