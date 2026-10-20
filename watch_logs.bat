@echo off
setlocal

:: Paths specified by user
set "MODS_DIR=C:\Users\nikol\OneDrive\Documents\My Games\Sid Meier's Civilization VI (Epic)\Mods"
set "LOGS_DIR=C:\Users\nikol\AppData\Local\Firaxis Games\Sid Meier's Civilization VI (Epic)\Logs"

echo ========================================================
echo       CIV 6 MOD LOG MONITOR (Serbia & WW2)
echo ========================================================
echo Logs directory:
echo %LOGS_DIR%
echo.

:: Automatically open Logs folder in Windows Explorer
if exist "%LOGS_DIR%" (
    echo [INFO] Opening Logs folder in Explorer...
    start "" explorer "%LOGS_DIR%"
)

:: Live tail in console
powershell -NoProfile -Command ^
  "$logPaths = @('%LOGS_DIR%\Database.log', '%LOGS_DIR%\Modding.log', '%LOGS_DIR%\Lua.log'); " ^
  "Write-Host 'Streaming logs in real-time... Press Ctrl+C to stop.' -ForegroundColor Cyan; " ^
  "Get-Content -Path $logPaths -Wait -Tail 30 -ErrorAction SilentlyContinue"

pause
