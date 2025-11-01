@echo off
title ChronoCare Flutter App - Android
color 0B
echo.
echo ========================================
echo   Starting ChronoCare on Android
echo ========================================
echo.
echo Running Flutter app on Android emulator...
echo Make sure Android emulator is running!
echo.

cd chronocare_app
if not exist .dart_tool (
    echo Installing Flutter dependencies...
    call flutter pub get
)
echo.
echo Launching on Android...
echo.
call flutter run -d android

