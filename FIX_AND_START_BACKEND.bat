@echo off
title Fix and Start Backend Server
color 0A
echo.
echo ========================================
echo   Fixing Backend Dependencies
echo ========================================
echo.
echo This will install all missing dependencies
echo and start the backend server.
echo.

cd backend
if not exist . (echo Error: backend folder not found! & pause & exit /b 1)

echo [Step 1/2] Installing all backend dependencies...
echo This may take a minute...
echo.
call npm install --legacy-peer-deps
if errorlevel 1 (
    echo.
    echo Error: Failed to install dependencies!
    echo Try running manually: cd backend ^&^& npm install
    pause
    exit /b 1
)
echo.
echo ✓ Dependencies installed successfully!
echo.

echo [Step 2/2] Starting backend server...
echo.
echo Backend will run on: http://localhost:3000
echo App connects to: http://10.0.2.2:3000 (Android emulator)
echo.
echo Keep this window open!
echo Press Ctrl+C to stop the server
echo.
echo ========================================
echo   Server Starting...
echo ========================================
echo.

call npm run dev

