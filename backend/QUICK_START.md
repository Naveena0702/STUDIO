# Quick Start Guide

## Setup Backend (One-Time Setup)

1. **Open PowerShell in the backend directory:**
   ```powershell
   cd C:\Users\bnave\Documents\sample\studio\backend
   ```

2. **Run the setup script:**
   ```powershell
   .\complete-setup.bat
   ```

   Or manually:
   ```powershell
   npm install
   npm run init-db
   ```

3. **Create .env file** (if it doesn't exist):
   ```
   PORT=3000
   JWT_SECRET=chronocare-secret-key-change-in-production
   NODE_ENV=development
   ```

## Start the Server

```powershell
cd C:\Users\bnave\Documents\sample\studio\backend
npm start
```

The server will start on: **http://localhost:3000**

## Test the Server

Open in browser: http://localhost:3000/api/health

Or in PowerShell:
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/health"
```

## Available Endpoints

- `GET /api/health` - Health check
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login user
- `GET /api/journal` - Get journal entries (requires auth)
- `POST /api/journal` - Create journal entry (requires auth)
- `GET /api/diet` - Get meal entries (requires auth)
- `POST /api/diet` - Create meal entry (requires auth)
- `GET /api/water` - Get water entries (requires auth)
- `POST /api/water` - Create water entry (requires auth)
- `GET /api/symptoms` - Get symptom analyses (requires auth)
- `POST /api/symptoms` - Create symptom analysis (requires auth)

For full documentation, see `README.md`
