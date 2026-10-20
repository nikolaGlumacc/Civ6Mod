@echo off
setlocal
set "LOGS_DIR=%USERPROFILE%\Documents\My Games\Sid Meier's Civilization VI (Epic)\Logs"

echo ========================================================
echo       CIV 6 MOD LOG MONITOR (Serbia & WW2)
echo ========================================================
echo Monitoring logs from:
echo %LOGS_DIR%
echo.
echo Press Ctrl+C at any time to exit.
echo ========================================================

powershell -NoProfile -Command ^
  "$logs = @('%LOGS_DIR%\Database.log', '%LOGS_DIR%\Modding.log', '%LOGS_DIR%\Lua.log'); " ^
  "Write-Host 'Checking logs... Press Ctrl+C to stop.' -ForegroundColor Cyan; " ^
  "Get-Content -Path $logs -Wait -Tail 30 -ErrorAction SilentlyContinue"

pause
