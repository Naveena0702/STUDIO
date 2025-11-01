@echo off
echo Starting ChronoCare Backend...
echo.
cd backend
if not exist node_modules (
    echo Installing dependencies...
    call npm install
)
echo.
echo Starting server at http://localhost:3000
echo.
call npm run dev

