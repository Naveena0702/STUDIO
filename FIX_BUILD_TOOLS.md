# 🔧 Fix Android Build-Tools Error

## Error: Missing Android SDK Build-Tools 35

**Quick Fix Options:**

---

## ✅ Option 1: Install via Android Studio (Recommended)

1. **Open Android Studio**
2. **Tools** → **SDK Manager**
3. **SDK Tools** tab
4. Check **Android SDK Build-Tools 35**
5. Click **Apply** → **OK**
6. Wait for installation
7. Try building again: `flutter build apk --debug`

---

## ✅ Option 2: Install via Command Line

```bash
# Find your Android SDK path (usually):
# C:\Users\YOUR_USERNAME\AppData\Local\Android\sdk

# Run SDK manager
cd C:\Users\Srija\AppData\Local\Android\sdk\tools\bin
.\sdkmanager.bat "build-tools;35.0.0"

# Or accept licenses first
.\sdkmanager.bat --licenses
```

---

## ✅ Option 3: Use Lower Build-Tools Version (Fastest)

**Edit:** `chronocare_app/android/app/build.gradle.kts`

Add to `android` block:
```kotlin
android {
    // ... existing code ...
    
    buildToolsVersion = "34.0.0"  // Use installed version
    
    // ... rest of code ...
}
```

**Then build again:**
```bash
flutter build apk --debug
```

---

## ✅ Option 4: Let Flutter Auto-Install

Try running this:
```bash
flutter build apk --debug --verbose
```

Flutter will attempt to download missing components automatically.

---

## 🚀 Quick Alternative: Use Available Build-Tools

**Check what you have:**
```bash
dir "C:\Users\Srija\AppData\Local\Android\sdk\build-tools"
```

**Then modify build.gradle.kts to use that version**

---

## 💡 Recommended: Open Android Studio SDK Manager

This is the easiest way:
1. Android Studio → SDK Manager
2. Install Build-Tools 35
3. Done!

Then build APK again! 🚀

