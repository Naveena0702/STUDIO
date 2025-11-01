@echo off
title Check APK Build Status
color 0B
echo.
echo ========================================
echo   Checking APK Build Status
echo ========================================
echo.

cd chronocare_app

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ✅ APK FOUND!
    echo.
    echo Location: build\app\outputs\flutter-apk\app-debug.apk
    echo.
    for %%F in ("build\app\outputs\flutter-apk\app-debug.apk") do (
        echo File Size: %%~zF bytes (%%~zF / 1048576 MB)
    )
    echo.
    echo Opening folder...
    start explorer build\app\outputs\flutter-apk
    echo.
    echo ✅ SUCCESS! APK is ready to share!
) else if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ RELEASE APK FOUND!
    echo.
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    start explorer build\app\outputs\flutter-apk
    echo.
    echo ✅ SUCCESS! Release APK is ready!
) else (
    echo ❌ APK not found yet
    echo.
    echo The build might still be running or failed.
    echo.
    echo To build APK now:
    echo   1. Run BUILD_APK_FAST.bat (debug - faster)
    echo   2. Or run BUILD_APK.bat (release - slower)
    echo.
    echo Checking if build is in progress...
    tasklist | findstr /i "gradle java" >nul
    if %ERRORLEVEL% EQU 0 (
        echo ✅ Build process detected - still running!
        echo    Wait a few more minutes...
    ) else (
        echo ❌ No build process found
        echo    Start a new build: BUILD_APK_FAST.bat
    )
)

cd ..
echo.
pause

