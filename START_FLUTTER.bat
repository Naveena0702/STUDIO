@echo off
title ChronoCare Flutter App
color 0B
echo.
echo ========================================
echo   Starting ChronoCare Flutter App
echo ========================================
echo.

REM Check for Developer Mode error
echo Note: If you see "symlink support" error, enable Developer Mode:
echo   - Double-click ENABLE_DEVELOPER_MODE.bat
echo   - Or run: start ms-settings:developers
echo.

REM Check for Visual Studio error
echo Note: If you see "Visual Studio could not be found" error:
echo   - Option 1: Install VS 2022 Community (see INSTALL_VISUAL_STUDIO.md)
echo   - Option 2: Run on Chrome/web instead: flutter run -d chrome
echo   - Option 3: Use Android emulator: flutter run -d android
echo.

cd chronocare_app
if not exist .dart_tool (
    echo Installing Flutter dependencies...
    call flutter pub get
)
echo.
echo Running Flutter app on Windows...
echo.
echo If you get Visual Studio errors, try:
echo   flutter run -d chrome    (for web version)
echo   flutter run -d android   (for Android emulator)
echo.
call flutter run

