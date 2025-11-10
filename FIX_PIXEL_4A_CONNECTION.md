# 🔧 Fix Pixel 4a Connection for Flutter

## Issue: Pixel 4a Not Detected

Your Pixel 4a is not showing up in `flutter devices`. Here's how to fix it:

---

## ✅ Quick Fix Steps

### Step 1: Enable USB Debugging on Pixel 4a

1. **Open Settings** on your Pixel 4a
2. **About Phone** → Tap **Build Number** 7 times (enable Developer Mode)
3. **Go back** → **System** → **Developer Options**
4. **Enable USB Debugging** ✓
5. **Enable USB Debugging (Security Settings)** ✓ (if available)

### Step 2: Connect Phone and Authorize

1. **Connect Pixel 4a** to computer via USB
2. **On your phone**: You should see a popup "Allow USB debugging?"
3. **Check "Always allow from this computer"**
4. **Tap OK**

### Step 3: Verify Connection

Run in terminal:
```powershell
adb devices
```

Should show:
```
List of devices attached
XXXXXXXX        device
```

If it shows "unauthorized", disconnect and reconnect the USB cable.

---

## 🔍 Troubleshooting

### Issue 1: Device Shows as "Unauthorized"

**Solution:**
1. Disconnect USB cable
2. Revoke USB debugging authorizations: Settings → Developer Options → Revoke USB debugging authorizations
3. Reconnect cable
4. Accept the prompt on your phone

### Issue 2: Device Not Showing in ADB

**Solution:**
```powershell
# Restart ADB server
adb kill-server
adb start-server
adb devices
```

### Issue 3: Driver Issues (Windows)

**Solution:**
1. Device Manager → Look for your phone (might show as unknown device)
2. Right-click → Update Driver
3. Browse → Let me pick → Android Device → Android Composite ADB Interface
4. Or download Google USB Driver from Android Studio SDK Manager

### Issue 4: Wrong USB Connection Mode

**Solution:**
1. When you connect, check the notification on your phone
2. Tap "USB for file transfer" or "USB for charging"
3. Select **"File Transfer"** or **"MTP"** mode
4. NOT "Charging only" mode

---

## ✅ After Fixing Connection

### Run the App on Pixel 4a

**Option 1: Using Script**
```powershell
# Double-click: RUN_ON_PIXEL_4A.bat
```

**Option 2: Manual**
```powershell
cd chronocare_app
flutter devices  # Should now show your Pixel 4a
flutter run -d android  # Will auto-select Pixel 4a
```

**Option 3: In Android Studio**
1. Open Android Studio
2. Select your Pixel 4a from device dropdown
3. Click Run (▶️)

---

## 🔍 Verify Device Detection

After connecting, run:
```powershell
flutter devices
```

You should see something like:
```
Pixel 4a (mobile) • XXXXXXXXX • android-arm64 • Android 13 (API 33)
```

---

## 📱 Alternative: Use Emulator (If Phone Issues Persist)

If you can't get the phone working, use the emulator that's already connected:

```powershell
cd chronocare_app
flutter run -d emulator-5554
```

---

## ✅ Success!

Once your Pixel 4a is detected:
- `flutter devices` shows your phone
- You can run: `flutter run -d android`
- Or run from Android Studio and select Pixel 4a

Good luck! 🚀


