@echo off
echo Setting up ChronoCare Backend...
echo.

echo Installing dependencies...
call npm install

echo.
echo Creating .env file...
if not exist .env (
    echo PORT=3000 > .env
    echo JWT_SECRET=chronocare-secret-key-change-in-production >> .env
    echo NODE_ENV=development >> .env
    echo .env file created!
) else (
    echo .env file already exists, skipping...
)

echo.
echo Initializing database...
call npm run init-db

echo.
echo Setup complete!
echo.
echo To start the server, run:
echo   npm start
echo.
echo Or for development with auto-reload:
echo   npm run dev
pause
