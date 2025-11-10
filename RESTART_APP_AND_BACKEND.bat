@echo off
title Restart App with Backend
color 0A
echo.
echo ========================================
echo   ChronoCare - Restart App
echo ========================================
echo.
echo This will:
echo   1. Start backend server (in new window)
echo   2. Wait 5 seconds
echo   3. Hot restart the Flutter app
echo.
pause

REM Start backend in new window
start "ChronoCare Backend" cmd /k "cd /d %~dp0backend && npm run dev"

echo Waiting for backend to start...
timeout /t 5 /nobreak >nul

echo.
echo Backend should be running now.
echo.
echo Now restart your Flutter app:
echo   - In Android Studio: Click the Hot Restart button (or Shift+F10)
echo   - Or stop and run the app again
echo.
echo The app should now connect to: http://10.0.2.2:3000
echo.
pause

