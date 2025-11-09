# ⚡ ChronoCare Quick Start - Get Running in 5 Minutes!

## 🚀 Complete Setup Guide

### Step 1: Backend Setup (2 minutes)

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Initialize database (creates tables)
npm run init-db

# Start server
npm run dev
```

✅ **Backend Running**: http://localhost:3000

**Test it**: Open browser → http://localhost:3000

---

### Step 2: Flutter App Setup (3 minutes)

```bash
# Navigate to app
cd chronocare_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

✅ **App Running**: Opens in emulator/simulator

---

### Step 3: Configure for Your Device

**For Android Emulator** (already configured):
- Uses: `http://10.0.2.2:3000/api` ✅

**For iOS Simulator** (already configured):
- Uses: `http://localhost:3000/api` ✅

**For Physical Device**:
1. Find your computer's IP:
   ```bash
   # Windows
   ipconfig | findstr IPv4
   
   # Mac/Linux
   ifconfig | grep inet
   ```
2. Update `chronocare_app/lib/services/api_service.dart` line 10:
   ```dart
   // Automatically detect environment and choose backend URL
static const String baseUrl = String.fromEnvironment('FLUTTER_WEB') != null
    ? 'https://chronocare.onrender.com/api' // for web or deployed app
    : 'http://10.0.2.2:3000/api'; // for Android emulator (use your local backend)

   
   ```
   Example: `http://192.168.1.100:3000/api`

---

## 🎯 First Time User Flow

1. **Register Account**
   - Open app
   - Tap "Register"
   - Enter: email, password, name

2. **Complete Profile**
   - Go to "Profile Setup"
   - Enter: age, weight, height, gender, activity level, health goals
   - Save → BMR and goals calculated automatically!

3. **Explore Features**
   - Dashboard → See your health overview
   - Mood Tracker → AI analyzes your emotions
   - Symptom Checker → ML predicts conditions
   - Diet Tracker → Get AI meal recommendations
   - Water Tracker → ML hydration reminders

---

## 🐛 Troubleshooting

### Windows: "Building with plugins requires symlink support"?
**Enable Developer Mode:**
1. Double-click `ENABLE_DEVELOPER_MODE.bat` in project root
2. Toggle "Developer Mode" ON in Windows Settings
3. Restart terminal/IDE
4. Try `flutter run` again

### Windows: "CMake Error: Visual Studio could not be found"?
**Install Visual Studio Build Tools:**
1. Double-click `INSTALL_VS.bat` for instructions
2. Or see `INSTALL_VISUAL_STUDIO.md`
3. Install Visual Studio 2022 Community with "Desktop development with C++"
4. Restart computer and terminal
5. Try `flutter run` again

**Alternative**: Run on Android emulator instead:
```bash
flutter run -d android
```

### Backend won't start?
```bash
# Check if port 3000 is in use
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Mac/Linux

# Kill process if needed, then retry
```

### Flutter app can't connect?
- ✅ Ensure backend is running first
- ✅ Check API URL in `api_service.dart`
- ✅ For physical device, ensure same WiFi network
- ✅ Check firewall isn't blocking port 3000

### Database errors?
```bash
cd backend
npm run init-db  # Recreate database
```

---

## 📱 Testing Endpoints

With backend running, test these URLs:

- **Root**: http://localhost:3000
- **Health**: http://localhost:3000/api/health
- **Register**: POST http://localhost:3000/api/auth/register
- **Login**: POST http://localhost:3000/api/auth/login

---

## ✅ Success Checklist

- [ ] Backend running on port 3000
- [ ] Can access http://localhost:3000 in browser
- [ ] Flutter app opens in emulator
- [ ] Can register new account
- [ ] Can login
- [ ] Dashboard loads
- [ ] All features accessible

---

## 🎉 You're Ready!

Your ChronoCare app is now running locally!

**Backend**: http://localhost:3000  
**Flutter App**: Running in emulator/simulator

Enjoy your AI-powered health assistant! 💎
