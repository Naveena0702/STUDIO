@echo off
title Fix Android Studio After Git Pull
color 0A
echo.
echo ========================================
echo   Fixing ChronoCare App for Android Studio
echo ========================================
echo.
echo This will fix common issues after pulling changes from git:
echo   1. Clean Flutter build cache
echo   2. Update Flutter dependencies
echo   3. Clean Gradle cache
echo   4. Verify setup
echo.

cd chronocare_app
if not exist . (echo Error: chronocare_app folder not found! & pause & exit /b 1)

echo [Step 1/4] Cleaning Flutter build cache...
call flutter clean
if errorlevel 1 (
    echo Error: Flutter clean failed!
    pause
    exit /b 1
)
echo ✓ Flutter clean completed
echo.

echo [Step 2/4] Getting Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo Error: Flutter pub get failed!
    pause
    exit /b 1
)
echo ✓ Dependencies updated
echo.

echo [Step 3/4] Cleaning Gradle cache...
cd android
if exist .gradle (
    rmdir /s /q .gradle
    echo ✓ Gradle cache cleaned
) else (
    echo ✓ No Gradle cache to clean
)
cd ..
echo.

echo [Step 4/4] Verifying Flutter setup...
call flutter doctor -v
echo.

echo ========================================
echo   Fix Complete!
echo ========================================
echo.
echo Next steps:
echo   1. Open Android Studio
echo   2. Open the 'chronocare_app' folder
echo   3. Wait for Android Studio to sync Gradle
echo   4. Try running the app again
echo.
echo If you still see errors:
echo   - Try: File → Invalidate Caches / Restart
echo   - Make sure Android SDK is properly installed
echo   - Check Android Studio SDK Manager for missing components
echo.
pause


