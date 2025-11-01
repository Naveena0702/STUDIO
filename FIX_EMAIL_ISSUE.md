# 🔧 Fix Email Registration Issue

## Quick Fixes

### Issue 1: Email Not Being Accepted

**Possible Causes:**
1. ✅ Backend not running
2. ✅ Email already exists in database  
3. ✅ Network/API connection issue
4. ✅ Email format validation too strict

---

## ✅ Solution 1: Check Backend is Running

1. **Open browser:** `http://localhost:3000`
2. **Should see:** API welcome message with endpoints listed
3. **If not running:**
   ```bash
   cd backend
   npm run dev
   ```

---

## ✅ Solution 2: Clear Database (If Email Already Exists)

Your email might already be registered. Delete database and start fresh:

**Windows:**
```bash
cd backend
del chronocare.db
npm run init-db
npm run dev
```

**Mac/Linux:**
```bash
cd backend
rm chronocare.db
npm run init-db
npm run dev
```

Then try registering again.

---

## ✅ Solution 3: For Mobile - Update API URL

**Your Computer's IP:** `10.174.24.87`

**Update:** `chronocare_app/lib/services/api_service.dart`

**Change line 10 from:**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**To:**
```dart
static const String baseUrl = 'http://10.174.24.87:3000/api';
```

**⚠️ Important:** 
- For **web/Chrome**: Keep `localhost`
- For **Android emulator**: Use `http://10.0.2.2:3000/api`
- For **physical phone**: Use `http://10.174.24.87:3000/api` (your IP)

---

## ✅ Solution 4: Check Error Messages

When registration fails:

1. **Open Browser Console** (F12 → Console tab)
2. **Look for red error messages**
3. **Check backend terminal** for error logs
4. **Common errors:**
   - `Connection refused` → Backend not running
   - `User already exists` → Email already registered
   - `Network error` → Wrong API URL or network issue

---

## 📱 Running on Mobile Phone

### Step 1: Start Backend
```bash
cd backend
npm run dev
```

### Step 2: Update API URL
Edit `chronocare_app/lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://10.174.24.87:3000/api';
```

### Step 3: Connect Phone
- Connect phone to **same WiFi** as computer
- For Android: Enable USB debugging, connect via USB
- Run: `flutter run`

### Step 4: Test Registration
Try registering with your email again!

---

## 🐛 Still Not Working?

**Check these:**

1. ✅ Backend running on port 3000?
2. ✅ API URL matches your device type?
3. ✅ Phone and computer on same WiFi?
4. ✅ Windows Firewall allowing Node.js?
5. ✅ Try different email address?

**Get actual error:**
- Check browser console (F12)
- Check backend terminal
- Share the exact error message

---

## 📝 Quick Test

**Test backend directly:**
```bash
curl http://localhost:3000/api/health
```

**Should return:** `{"status": "ok"}`

If error → Backend not running!

