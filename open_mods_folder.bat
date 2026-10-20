@echo off
set "MODS_DIR=C:\Users\nikol\OneDrive\Documents\My Games\Sid Meier's Civilization VI (Epic)\Mods"
if exist "%MODS_DIR%" (
    echo Opening Civ 6 Mods folder...
    start "" explorer "%MODS_DIR%"
)
