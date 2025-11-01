@echo off
title ChronoCare Flutter App - Chrome/Web
color 0B
echo.
echo ========================================
echo   Starting ChronoCare on Chrome (Web)
echo ========================================
echo.
echo Running Flutter app in web browser...
echo This doesn't require Visual Studio!
echo.

cd chronocare_app
if not exist .dart_tool (
    echo Installing Flutter dependencies...
    call flutter pub get
)
echo.
echo Launching in Chrome...
echo.
call flutter run -d chrome

