@echo off
title Build ChronoCare iOS App
color 0B
echo.
echo ========================================
echo   Building ChronoCare iOS App
echo ========================================
echo.
echo ⚠️  This requires a Mac with Xcode installed!
echo.

cd chronocare_app

echo [1/3] Cleaning previous builds...
call flutter clean >nul 2>&1

echo [2/3] Getting dependencies...
call flutter pub get

echo [3/3] Building iOS app...
echo This may take 5-10 minutes...
echo.
call flutter build ios --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   ✅ iOS Build Successful!
    echo ========================================
    echo.
    echo Next Steps:
    echo   1. Open ios/Runner.xcworkspace in Xcode
    echo   2. Archive the app
    echo   3. Upload to App Store Connect
    echo.
    echo Or build IPA:
    echo   flutter build ipa
    echo.
) else (
    echo.
    echo ========================================
    echo   ❌ Build Failed
    echo ========================================
    echo.
    echo This requires:
    echo   - Mac computer
    echo   - Xcode installed
    echo   - iOS Developer account
)

cd ..
echo.
pause

