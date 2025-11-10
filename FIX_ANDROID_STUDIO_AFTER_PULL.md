# 🔧 Fix Android Studio After Git Pull

## Quick Fix (Choose One)

### ✅ Option 1: Run Fix Script (Recommended)
1. **Double-click:** `FIX_ANDROID_STUDIO.bat`
2. **Wait** for it to complete
3. **Open Android Studio** → File → Invalidate Caches / Restart
4. **Wait** for Android Studio to sync Gradle
5. **Run** the app again

---

### ✅ Option 2: Manual Fix

**Step 1: Clean Flutter**
```powershell
cd chronocare_app
flutter clean
```

**Step 2: Get Dependencies**
```powershell
flutter pub get
```

**Step 3: Clean Gradle (Optional)**
```powershell
cd android
rmdir /s /q .gradle
cd ..
```

**Step 4: In Android Studio**
1. **File** → **Invalidate Caches / Restart**
2. Click **Invalidate and Restart**
3. Wait for Gradle sync to complete
4. Try running the app

---

## Common Issues After Pull

### Issue 1: "file_picker" Plugin Errors
**Error:** `cannot find symbol class Registrar`

**Solution:**
- This happens when cached old plugin versions exist
- Run `flutter clean` then `flutter pub get`
- The app uses `file_picker: ^8.0.3` (correct version)

### Issue 2: Gradle Sync Failed
**Error:** Build failed, sync errors

**Solution:**
1. File → Invalidate Caches / Restart
2. File → Sync Project with Gradle Files
3. Check Android SDK is installed (Tools → SDK Manager)

### Issue 3: Missing Dependencies
**Error:** Package not found

**Solution:**
```powershell
cd chronocare_app
flutter pub get
flutter pub upgrade
```

---

## Step-by-Step: First Time After Pull

### 1. Close Android Studio (if open)

### 2. Run Fix Script
```powershell
# Double-click FIX_ANDROID_STUDIO.bat
# OR run in terminal:
.\FIX_ANDROID_STUDIO.bat
```

### 3. Open Android Studio
- Open the `chronocare_app` folder (not the parent folder)
- Wait for Gradle sync to complete
- If sync fails, see Issue 2 above

### 4. Invalidate Caches
- File → Invalidate Caches / Restart
- Select "Invalidate and Restart"
- Wait for Android Studio to restart

### 5. Verify Setup
- Tools → SDK Manager → Check Android SDK is installed
- Tools → SDK Manager → SDK Tools tab → Ensure build-tools are installed

### 6. Run the App
- Select an Android device/emulator
- Click Run (▶️) or press Shift+F10

---

## If Still Not Working

### Check Flutter Doctor
```powershell
flutter doctor -v
```

### Check for Missing Components
```powershell
# Should show no major issues
flutter doctor --android-licenses
```

### Verify Android SDK Path
- Android Studio → File → Project Structure → SDK Location
- Should point to: `C:\Users\YOUR_USERNAME\AppData\Local\Android\sdk`

### Check Android Emulator
1. Tools → Device Manager
2. Create/Start an Android Virtual Device (AVD)
3. Make sure it's running before trying to run the app

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Plugin not found" | Run `flutter pub get` |
| "Gradle sync failed" | Invalidate caches and restart |
| "Build failed" | Run `flutter clean` then rebuild |
| "SDK not found" | Install Android SDK via SDK Manager |
| "Device not found" | Start Android emulator or connect phone |

---

## Need More Help?

Check these files:
- `FIX_BUILD_TOOLS.md` - For Android SDK issues
- `MOBILE_SETUP.md` - For Android setup
- `README.md` - General project info

---

## ✅ Success Indicators

After fixing, you should see:
- ✓ Gradle sync successful in Android Studio
- ✓ No red error markers in the project
- ✓ App builds without errors
- ✓ App runs on Android device/emulator

Good luck! 🚀


