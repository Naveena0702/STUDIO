@echo off
title ChronoCare - Starting Everything
color 0A
echo.
echo ========================================
echo    ChronoCare - Complete Application
echo ========================================
echo.
echo Starting Backend and Flutter App...
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is not installed!
    echo Please install Node.js from https://nodejs.org
    pause
    exit /b 1
)

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Flutter is not installed or not in PATH
    echo Flutter app will not start automatically
    echo.
)

echo [1/2] Starting Backend Server...
cd backend
if not exist node_modules (
    echo Installing backend dependencies...
    call npm install >nul 2>&1
)
if not exist .env (
    echo Creating .env file...
    echo PORT=3000 > .env
    echo JWT_SECRET=your-secret-key-change-this-in-production >> .env
    echo NODE_ENV=development >> .env
)
start "ChronoCare Backend" cmd /k "npm run dev"
timeout /t 3 >nul
cd ..

echo [2/2] Starting Flutter App...
cd chronocare_app
if not exist .dart_tool (
    echo Installing Flutter dependencies...
    call flutter pub get >nul 2>&1
)
start "ChronoCare Flutter" cmd /k "flutter run"
cd ..

echo.
echo ========================================
echo    ✅ Everything is Starting!
echo ========================================
echo.
echo Backend:  http://localhost:3000
echo Flutter:  Check the Flutter window
echo.
echo Press any key to open backend in browser...
pause >nul
start http://localhost:3000
echo.
echo Done! Check both windows for status.
pause

