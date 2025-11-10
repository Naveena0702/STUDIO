@echo off
title Complete App Restart for Android Emulator
color 0B
echo.
echo ========================================
echo   Complete Flutter App Restart
echo ========================================
echo.
echo This will:
echo   1. Clean Flutter build cache
echo   2. Get fresh dependencies
echo   3. Prepare app for Android emulator
echo.
echo IMPORTANT: After this, in Android Studio:
echo   - Stop the app completely (Stop button)
echo   - Run the app again (Run button)
echo.
pause

cd chronocare_app
if not exist . (echo Error: chronocare_app folder not found! & pause & exit /b 1)

echo.
echo [Step 1/3] Cleaning Flutter build...
call flutter clean
echo.

echo [Step 2/3] Getting dependencies...
call flutter pub get
echo.

echo [Step 3/3] Verifying API URL...
echo.
findstr /C:"10.0.2.2:3000" lib\services\api_service.dart >nul
if errorlevel 1 (
    echo WARNING: API URL might not be set to 10.0.2.2:3000
    echo Check: lib\services\api_service.dart
) else (
    echo ✓ API URL is correctly set to 10.0.2.2:3000
)
echo.

echo ========================================
echo   Ready to Restart in Android Studio
echo ========================================
echo.
echo Next steps in Android Studio:
echo   1. Click STOP button (red square) to stop the app
echo   2. Click RUN button (green play icon) to start fresh
echo   3. The app will now use the correct API URL
echo.
echo Make sure backend is running!
echo Double-click: FIX_AND_START_BACKEND.bat
echo.
pause

