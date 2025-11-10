@echo off
echo ========================================
echo ChronoCare Backend Setup
echo ========================================
echo.

echo Step 1: Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ERROR: npm install failed!
    pause
    exit /b 1
)
echo.
echo Dependencies installed successfully!
echo.

echo Step 2: Creating .env file...
if not exist .env (
    echo PORT=3000 > .env
    echo JWT_SECRET=chronocare-secret-key-change-in-production >> .env
    echo NODE_ENV=development >> .env
    echo .env file created!
) else (
    echo .env file already exists.
)
echo.

echo Step 3: Initializing database...
call npm run init-db
if %errorlevel% neq 0 (
    echo ERROR: Database initialization failed!
    pause
    exit /b 1
)
echo.
echo Database initialized successfully!
echo.

echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo To start the server, run:
echo   npm start
echo.
echo The server will be available at: http://localhost:3000
echo Health check: http://localhost:3000/api/health
echo.
pause
