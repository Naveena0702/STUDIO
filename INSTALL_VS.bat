@echo off
title Install Visual Studio for Flutter
color 0B
echo.
echo ========================================
echo   Visual Studio Installation Guide
echo   for Flutter Windows Apps
echo ========================================
echo.
echo Flutter needs Visual Studio Build Tools to compile Windows apps.
echo.
echo ========================================
echo   INSTALLATION OPTIONS
echo ========================================
echo.
echo Option 1: Visual Studio 2022 Community (Recommended)
echo   - Full IDE, free
echo   - ~3 GB download
echo   - Best for beginners
echo.
echo Option 2: Visual Studio Build Tools 2022 (Lightweight)
echo   - Just build tools, no IDE
echo   - Smaller download
echo   - For experienced users
echo.
echo ========================================
echo   WHAT YOU NEED TO INSTALL
echo ========================================
echo.
echo Make sure to select:
echo   ✅ "Desktop development with C++"
echo.
echo This includes:
echo   - MSVC v143 C++ build tools
echo   - Windows 10/11 SDK
echo   - CMake tools for Windows
echo.
echo ========================================
echo.
echo Opening Visual Studio download page...
echo.
pause
start https://visualstudio.microsoft.com/downloads/
echo.
echo ========================================
echo   INSTRUCTIONS
echo ========================================
echo.
echo 1. Download Visual Studio 2022 Community
echo 2. Run the installer
echo 3. Check "Desktop development with C++"
echo 4. Click Install
echo 5. Wait for installation (~15-30 min)
echo 6. Restart your computer
echo 7. Restart Cursor/VS Code
echo 8. Try Flutter again: flutter run
echo.
echo ========================================
echo.
echo For detailed instructions, see: INSTALL_VISUAL_STUDIO.md
echo.
pause

