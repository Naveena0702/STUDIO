@echo off
echo ========================================
echo ChronoCare - Complete Setup Script
echo ========================================
echo.

echo [1/3] Setting up Backend...
cd backend
if not exist node_modules (
    echo Installing backend dependencies...
    call npm install
)
echo.
echo Initializing database...
call npm run init-db
echo.
echo Starting backend server...
echo Backend will run at http://localhost:3000
echo.
start cmd /k "npm run dev"
timeout /t 3 >nul

echo.
echo [2/3] Setting up Flutter App...
cd ..\chronocare_app
if not exist .dart_tool (
    echo Installing Flutter dependencies...
    call flutter pub get
)
echo.
echo [3/3] Setup Complete!
echo.
echo Backend: Running at http://localhost:3000
echo Flutter: Ready to run with 'flutter run'
echo.
echo To run Flutter app:
echo   cd chronocare_app
echo   flutter run
echo.
pause

