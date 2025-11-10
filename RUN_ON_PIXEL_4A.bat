@echo off
title Run ChronoCare on Pixel 4a
color 0A
echo.
echo ========================================
echo   Running ChronoCare on Pixel 4a
echo ========================================
echo.
echo Make sure your Pixel 4a is connected via USB
echo and USB debugging is enabled!
echo.

cd chronocare_app
if not exist . (echo Error: chronocare_app folder not found! & pause & exit /b 1)

echo [Step 1/4] Checking connected devices...
call flutter devices
echo.

echo [Step 2/4] Cleaning Flutter build...
call flutter clean
if errorlevel 1 (
    echo Warning: Flutter clean had issues, continuing anyway...
)
echo.

echo [Step 3/4] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo Error: Failed to get dependencies!
    pause
    exit /b 1
)
echo.

echo [Step 4/4] Running app on Pixel 4a...
echo.
echo If your device is not listed above, check:
echo   - USB cable is connected
echo   - USB debugging is enabled
echo   - Device is unlocked
echo.

call flutter run -d android
if errorlevel 1 (
    echo.
    echo ========================================
    echo   Error Running App
    echo ========================================
    echo.
    echo Try these steps:
    echo   1. Make sure Pixel 4a is connected
    echo   2. Enable USB debugging on the phone
    echo   3. Unlock your phone
    echo   4. Run: flutter devices (to see if device is detected)
    echo   5. In Android Studio: File -^> Invalidate Caches / Restart
    echo.
    pause
)


