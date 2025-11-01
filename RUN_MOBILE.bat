@echo off
title ChronoCare Mobile Setup
color 0B
echo.
echo ========================================
echo   ChronoCare Mobile App Setup
echo ========================================
echo.

echo [1/4] Starting Backend Server...
cd backend
if not exist node_modules (
    echo Installing dependencies...
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

echo.
echo [2/4] Finding Your IP Address...
echo ========================================
ipconfig | findstr IPv4
echo ========================================
echo.
echo ^> Copy the IP address above (e.g., 192.168.1.100)
echo.

echo [3/4] Checking Flutter devices...
cd chronocare_app
call flutter devices
cd ..

echo.
echo [4/4] Instructions:
echo ========================================
echo 1. Update API URL in chronocare_app/lib/services/api_service.dart
echo    Change line 10 to: http://YOUR_IP:3000/api
echo.
echo 2. Connect your phone to the SAME WiFi as this computer
echo.
echo 3. For Android:
echo    - Enable USB Debugging (Settings ^> Developer Options)
echo    - Connect phone via USB
echo    - Run: cd chronocare_app ^&^& flutter run
echo.
echo 4. For iOS (Mac only):
echo    - Run: cd chronocare_app ^&^& flutter run -d ios
echo.
echo ========================================
echo Backend running at: http://localhost:3000
echo.
pause

