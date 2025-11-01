# 📱 ChronoCare Mobile App Setup Guide

## Quick Steps to Run on Your Phone

### 1️⃣ Start Backend Server

```bash
cd backend
npm run dev
```

**Backend should be running at:** `http://localhost:3000`

---

### 2️⃣ Find Your Computer's IP Address

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" under your WiFi adapter (e.g., `192.168.1.100`)

**Mac/Linux:**
```bash
ifconfig
```
Or
```bash
ip addr show
```

---

### 3️⃣ Update API URL in Flutter App

Edit: `chronocare_app/lib/services/api_service.dart`

**Change line 10 from:**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**To your IP address:**
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';
```
*(Replace `192.168.1.100` with YOUR actual IP address)*

---

### 4️⃣ Connect Phone to Same WiFi

- Your phone and computer **MUST** be on the **same WiFi network**
- Turn off mobile data on your phone (use WiFi only)

---

### 5️⃣ Run on Android Phone

**Option A: Physical Device via USB**
```bash
cd chronocare_app

# Enable USB debugging on your phone
# Settings > Developer Options > USB Debugging

# Connect phone via USB
flutter devices  # Should see your phone

flutter run  # Runs on connected phone
```

**Option B: Build APK and Install**
```bash
cd chronocare_app
flutter build apk
```
APK will be in: `build/app/outputs/flutter-apk/app-release.apk`
Transfer to phone and install.

---

### 6️⃣ Run on iOS iPhone (Mac only)

```bash
cd chronocare_app
flutter run -d ios
```

**Note:** Requires:
- Mac computer
- Xcode installed
- iOS Developer account (free tier works)

---

## 🔧 Fix Email Registration Issue

### Problem: Email not being accepted

**Check these:**

1. **Backend is running?**
   - Open browser: `http://localhost:3000`
   - Should see API welcome message

2. **API URL correct?**
   - Check `api_service.dart` line 10
   - Should match your computer's IP for mobile
   - Use `localhost` only for web/emulator

3. **User already exists?**
   - Try a different email
   - Or delete database: `backend/chronocare.db`

4. **Error message?**
   - Check browser console (F12) for actual error
   - Or backend terminal for error logs

---

## 📝 Quick Mobile Test Script

Create `RUN_MOBILE.bat` (Windows):

```batch
@echo off
echo ========================================
echo   ChronoCare Mobile Setup
echo ========================================
echo.

echo [1] Starting Backend...
cd backend
start cmd /k "npm run dev"
timeout /t 3 >nul
cd ..

echo.
echo [2] Your IP Address:
ipconfig | findstr IPv4
echo.

echo [3] Update api_service.dart with your IP above
echo     File: chronocare_app/lib/services/api_service.dart
echo     Change: baseUrl to http://YOUR_IP:3000/api
echo.

echo [4] Run Flutter on connected device:
echo     flutter devices
echo     flutter run
echo.

pause
```

---

## ✅ Verify Everything Works

1. ✅ Backend running: `http://localhost:3000`
2. ✅ Phone connected to same WiFi
3. ✅ API URL updated with your IP
4. ✅ Phone connected via USB (for Android)
5. ✅ USB Debugging enabled (Android)

---

## 🐛 Troubleshooting

### "Connection refused" on phone
- ✅ Check backend is running
- ✅ Check IP address is correct
- ✅ Phone and computer on same WiFi
- ✅ Windows Firewall might block - allow Node.js through firewall

### Email registration fails
- ✅ Check backend terminal for error
- ✅ Try different email address
- ✅ Check network tab in browser (F12)

### Flutter can't find device
- ✅ Enable USB debugging (Android)
- ✅ Trust computer on phone
- ✅ Run `flutter devices` to see connected devices

---

## 🚀 Alternative: Use Android Emulator

If physical phone is difficult:

1. Open **Android Studio**
2. Start an **Android Emulator**
3. Run: `flutter run -d android`
4. Use API URL: `http://10.0.2.2:3000/api` (for emulator)

This works immediately without IP configuration!

