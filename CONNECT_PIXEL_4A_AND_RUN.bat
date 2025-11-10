@echo off
title Connect Pixel 4a and Run App
color 0B
echo.
echo ========================================
echo   ChronoCare App - Pixel 4a Setup
echo ========================================
echo.
echo IMPORTANT: Before continuing, make sure:
echo   1. Pixel 4a is connected via USB
echo   2. USB Debugging is enabled on the phone
echo   3. You've authorized this computer (check phone screen)
echo   4. Phone is unlocked
echo.
pause

cd chronocare_app
if not exist . (echo Error: chronocare_app folder not found! & pause & exit /b 1)

echo.
echo [Step 1/5] Checking for connected devices...
echo.
call flutter devices
echo.

echo [Step 2/5] Cleaning Flutter build...
call flutter clean >nul 2>&1
echo ✓ Clean completed
echo.

echo [Step 3/5] Getting dependencies...
call flutter pub get
if errorlevel 1 (
    echo Error: Failed to get dependencies!
    pause
    exit /b 1
)
echo ✓ Dependencies ready
echo.

echo [Step 4/5] Checking devices again...
echo.
call flutter devices
echo.

echo [Step 5/5] Attempting to run on Android device...
echo.
echo If your Pixel 4a is connected and authorized, the app will start!
echo If not, you'll see an error below.
echo.

call flutter run -d android
if errorlevel 1 (
    echo.
    echo ========================================
    echo   Device Not Found!
    echo ========================================
    echo.
    echo Your Pixel 4a is not detected. Try this:
    echo.
    echo 1. CHECK USB CONNECTION:
    echo    - Disconnect and reconnect USB cable
    echo    - Try a different USB cable
    echo    - Try a different USB port
    echo.
    echo 2. ENABLE USB DEBUGGING on Pixel 4a:
    echo    - Settings ^> About Phone ^> Tap Build Number 7 times
    echo    - Back to Settings ^> System ^> Developer Options
    echo    - Enable "USB Debugging"
    echo    - Enable "USB Debugging (Security Settings)" if available
    echo.
    echo 3. AUTHORIZE COMPUTER:
    echo    - When you connect, phone will ask "Allow USB debugging?"
    echo    - Check "Always allow from this computer"
    echo    - Tap OK
    echo.
    echo 4. CHECK USB MODE:
    echo    - Pull down notification panel on phone
    echo    - Tap "USB for..." notification
    echo    - Select "File Transfer" or "MTP" (NOT "Charging only")
    echo.
    echo 5. RESTART ADB (if you have Android SDK):
    echo    - Open Android Studio
    echo    - Tools ^> SDK Manager ^> SDK Tools
    echo    - Make sure "Android SDK Platform-Tools" is installed
    echo.
    echo 6. VERIFY in Android Studio:
    echo    - Open Android Studio
    echo    - Check device dropdown (top right)
    echo    - Your Pixel 4a should appear there
    echo.
    echo For detailed help, see: FIX_PIXEL_4A_CONNECTION.md
    echo.
    pause
)


