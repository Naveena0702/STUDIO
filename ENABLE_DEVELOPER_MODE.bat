@echo off
title Enable Developer Mode for Flutter
color 0B
echo.
echo ========================================
echo   Flutter Developer Mode Setup
echo ========================================
echo.
echo Flutter requires Developer Mode to be enabled
echo to create symlinks for plugins.
echo.
echo Opening Windows Developer Settings...
echo.
echo Please follow these steps:
echo   1. Toggle "Developer Mode" to ON
echo   2. Accept any warnings/prompts
echo   3. Close the settings window
echo   4. Restart your terminal/IDE if needed
echo.
pause
start ms-settings:developers
echo.
echo ========================================
echo   Settings Opened!
echo ========================================
echo.
echo After enabling Developer Mode:
echo   1. Close this window
echo   2. Restart your terminal/IDE
echo   3. Run your Flutter app again
echo.
pause

