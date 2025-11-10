# 🔧 Quick Fix: Registration Not Working

## Problem
Registration fails with "Connection refused" error.

## Root Cause
After pulling changes from git:
1. ✅ API URL was fixed (changed to `10.0.2.2:3000` for Android emulator)
2. ❌ Backend dependencies weren't installed (missing `natural` module)
3. ❌ Backend server is not running

---

## ✅ Solution - Do This Now:

### Step 1: Install Backend Dependencies
**Double-click this script:**
```
FIX_AND_START_BACKEND.bat
```

**OR run manually:**
```powershell
cd backend
npm install
npm run dev
```

**What this does:**
- Installs all missing backend dependencies (including `natural`, `compromise`, etc.)
- Starts the backend server on port 3000

### Step 2: Wait for Backend to Start
You should see in the terminal window:
```
Server running on port 3000
Database initialized successfully
```

### Step 3: Restart Your Flutter App
**In Android Studio:**
- Click **Hot Restart** button (circular arrow icon) or press **Shift+F10**
- OR stop and run the app again

### Step 4: Try Registering Again
The registration should now work!

---

## ✅ Verify Everything is Working

### Check Backend is Running:
Open in browser: `http://localhost:3000/api/health`

Should show:
```json
{
  "status": "ok",
  "message": "ChronoCare API is running"
}
```

### Check App Connection:
- App is using: `http://10.0.2.2:3000/api` (correct for Android emulator)
- Backend is running on: `http://localhost:3000`

---

## 🔍 If Still Not Working

### Issue 1: Backend Window Shows Errors
**Solution:**
- Make sure all dependencies installed: `cd backend && npm install`
- Check for port conflicts: Is port 3000 already in use?
- Try stopping any other Node.js processes

### Issue 2: App Still Shows "Connection refused"
**Solution:**
1. Make sure backend window is open and shows "Server running"
2. Check backend URL in app: `chronocare_app/lib/services/api_service.dart`
   - Should be: `http://10.0.2.2:3000/api` for Android emulator
3. Hot restart the app again

### Issue 3: "Cannot find module" errors
**Solution:**
```powershell
cd backend
rmdir /s /q node_modules
npm install
npm run dev
```

---

## 📝 Summary

**What was wrong:**
- Backend dependencies not installed after git pull
- Missing `natural` module causing backend crash

**What was fixed:**
- Created `FIX_AND_START_BACKEND.bat` script
- Updated API URL for Android emulator
- Script installs dependencies and starts server

**Next steps:**
1. Run `FIX_AND_START_BACKEND.bat`
2. Keep backend window open
3. Hot restart Flutter app
4. Register again - should work! ✅

---

Good luck! 🚀

