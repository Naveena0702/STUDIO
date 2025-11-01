@echo off
title Build ChronoCare APK
color 0B
echo.
echo ========================================
echo   Building ChronoCare Android APK
echo ========================================
echo.
echo This will create an APK file that anyone can install!
echo.

cd chronocare_app

echo [1/3] Cleaning previous builds...
call flutter clean >nul 2>&1

echo [2/3] Getting dependencies...
call flutter pub get

echo [3/3] Building release APK...
echo This may take 3-8 minutes (first time: 10-15 min)
echo Subsequent builds: 2-3 minutes
echo.
echo Tip: First build downloads NDK and dependencies (slow)
echo      Future builds use cache (much faster!)
echo.
call flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   ✅ APK Built Successfully!
    echo ========================================
    echo.
    echo APK Location:
    echo   build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Next Steps:
    echo   1. Share this APK file with users
    echo   2. Users install by opening the APK file
    echo   3. They may need to enable "Install from unknown sources"
    echo.
    echo To upload to Google Drive:
    echo   1. Upload app-release.apk to Google Drive
    echo   2. Share link with users
    echo   3. Users download and install
    echo.
    start explorer build\app\outputs\flutter-apk
) else (
    echo.
    echo ========================================
    echo   ❌ Build Failed
    echo ========================================
    echo.
    echo Check the error messages above.
    echo Make sure:
    echo   - Flutter is properly installed
    echo   - Android SDK is set up
    echo   - Run: flutter doctor
)

cd ..
echo.
pause

