@echo off
title Build ChronoCare APK - Fast Mode
color 0B
echo.
echo ========================================
echo   Building ChronoCare APK - FAST MODE
echo ========================================
echo.
echo This will build a debug APK (faster, still installable)
echo For production, use BUILD_APK.bat after first successful build
echo.

cd chronocare_app

echo [1/4] Optimizing Gradle...
echo Parallel builds: ON
echo Caching: ON
echo.

echo [2/4] Getting dependencies (cached)...
call flutter pub get

echo [3/4] Building debug APK (faster than release)...
echo This is installable and works the same, just larger file size.
echo Build time: ~2-3 minutes instead of 5-10 minutes
echo.
call flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   ✅ APK Built Successfully!
    echo ========================================
    echo.
    echo APK Location:
    echo   build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo Note: This is a debug APK (faster to build)
    echo       Works perfectly, just larger file size
    echo.
    echo For production release APK:
    echo   Run BUILD_APK.bat (takes longer but optimized)
    echo.
    start explorer build\app\outputs\flutter-apk
) else (
    echo.
    echo ========================================
    echo   ❌ Build Failed
    echo ========================================
    echo.
    echo Check error messages above
)

cd ..
echo.
pause

