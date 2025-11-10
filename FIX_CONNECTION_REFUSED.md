# 🔧 Fix "Connection Refused" Error

## Problem
App shows: `Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 40704, uri=http://localhost:3000/api/auth/register`

## Root Cause
1. ❌ Backend server is not running
2. ❌ App is using old cached code (still trying `localhost` instead of `10.0.2.2`)
3. ❌ App needs to be fully restarted (not just hot reload)

---

## ✅ Solution - Do These Steps:

### Step 1: Start Backend Server
**Double-click:**
```
FIX_AND_START_BACKEND.bat
```

**OR run manually:**
```powershell
cd backend
npm run dev
```

**Wait until you see:**
```
🚀 ChronoCare Backend Server running on port 3000
✅ Connected to SQLite database
```

**Keep this window open!**

### Step 2: Verify Backend is Running
Open browser and go to: `http://localhost:3000/api/health`

Should show:
```json
{
  "status": "ok",
  "message": "ChronoCare API is running"
}
```

### Step 3: FULLY RESTART Flutter App
**IMPORTANT: You must do a FULL RESTART, not just hot reload!**

**In Android Studio:**
1. **Stop the app completely:**
   - Click the **Stop** button (red square) 
   - OR press **Shift+F10** then **Stop**

2. **Clear Flutter cache:**
   ```powershell
   cd chronocare_app
   flutter clean
   flutter pub get
   ```

3. **Run the app again:**
   - Click **Run** button (green play icon)
   - OR press **Shift+F10**

**Why full restart?**
- Hot reload doesn't reload static constants
- The `baseUrl` is a static constant, so it needs a full restart
- Cached code might still have the old `localhost` URL

### Step 4: Verify API URL in Code
Check: `chronocare_app/lib/services/api_service.dart`

Line 11 should be:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

**NOT:**
```dart
static const String baseUrl = 'http://localhost:3000/api';  // ❌ Wrong for Android emulator
```

### Step 5: Try Registering Again
After backend is running AND app is fully restarted, try registering again.

---

## 🔍 Troubleshooting

### Issue 1: Still Shows "localhost" in Error
**Solution:**
1. Stop the app completely
2. Run: `cd chronocare_app && flutter clean`
3. Run: `flutter pub get`
4. Run the app again (full restart)

### Issue 2: Backend Not Starting
**Check:**
- Are dependencies installed? Run: `cd backend && npm install --legacy-peer-deps`
- Is port 3000 already in use? Close other Node.js processes
- Check backend terminal for error messages

### Issue 3: "Database error" After Connection Works
**Solution:**
```powershell
cd backend
npm run init-db
```
Then restart backend server.

---

## ✅ Quick Checklist

- [ ] Backend server is running (check terminal window)
- [ ] Backend responds at `http://localhost:3000/api/health`
- [ ] Flutter app is FULLY RESTARTED (not just hot reload)
- [ ] API URL in code is `http://10.0.2.2:3000/api`
- [ ] Database is initialized (`npm run init-db`)
- [ ] Try registering again

---

## 📝 Summary

**The Problem:**
- App trying to use `localhost:3000` (won't work on Android emulator)
- Backend server not running
- App needs full restart to pick up URL change

**The Solution:**
1. Start backend: `cd backend && npm run dev`
2. Full restart Flutter app (stop, clean, run again)
3. App will now use `10.0.2.2:3000` (correct for Android emulator)

---

Good luck! 🚀

