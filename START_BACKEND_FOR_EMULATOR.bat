@echo off
title Start Backend Server for Emulator
color 0B
echo.
echo ========================================
echo   Starting ChronoCare Backend Server
echo ========================================
echo.
echo Backend will run on: http://localhost:3000
echo App should connect to: http://10.0.2.2:3000 (Android emulator)
echo.
echo Keep this window open while testing!
echo.
echo Press Ctrl+C to stop the server
echo.

cd backend
if not exist . (echo Error: backend folder not found! & pause & exit /b 1)

echo Checking for node_modules...
if not exist node_modules (
    echo Installing dependencies...
    call npm install --legacy-peer-deps
    if errorlevel 1 (
        echo Error: Failed to install dependencies!
        pause
        exit /b 1
    )
) else (
    echo Checking if all dependencies are installed...
    call npm install --legacy-peer-deps
    if errorlevel 1 (
        echo Warning: Some dependencies may not be installed properly!
    )
)

echo.
echo Starting backend server...
echo.
call npm run dev
pause

