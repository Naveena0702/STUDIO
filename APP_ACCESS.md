# 🔗 ChronoCare App Access

## 📱 How to Access Your App

### Current Status: **Local Development**

Your ChronoCare app is configured to run **locally** on your machine. Here's how to access it:

---

## 🖥️ Backend API Access

### Local URL:
```
http://localhost:3000
```

### API Base URL:
```
http://localhost:3000/api
```

### Test in Browser:
Open your browser and visit:
```
http://localhost:3000
```

You should see the API welcome message with all available endpoints.

### Test API Endpoints:
- Health Check: `http://localhost:3000/api/health`
- API Info: `http://localhost:3000/api`

---

## 📱 Flutter App Access

### For Android Emulator:
- API URL: `http://10.0.2.2:3000/api`
- The app runs in the Android emulator window

### For iOS Simulator:
- API URL: `http://localhost:3000/api`
- The app runs in the iOS simulator window

### For Physical Device (Phone/Tablet):
- Find your computer's IP address:
  ```bash
  # Windows
  ipconfig
  
  # Mac/Linux
  ifconfig
  ```
- API URL: `http://YOUR_IP:3000/api`
  - Example: `http://192.168.1.100:3000/api`

### For Web (Chrome/Edge):
- API URL: `http://localhost:3000/api`
- Run: `flutter run -d chrome`

---

## 🚀 Quick Start

### 1. Start Backend:
```bash
cd backend
npm install
npm run init-db
npm run dev
```

Backend will be available at: **http://localhost:3000**

### 2. Start Flutter App:
```bash
cd chronocare_app
flutter pub get
flutter run
```

### 3. Configure API URL (if needed):
Edit `chronocare_app/lib/services/api_service.dart` line 10:

```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

---

## 🌐 To Deploy Online (Get Public Link)

Currently, your app is **local only**. To get a public web link, you have options:

### Option 1: Deploy Backend + Flutter Web
1. Deploy backend to **Render/Railway/Heroku**
2. Build Flutter web: `flutter build web`
3. Deploy to **Vercel/Netlify/Firebase Hosting**

### Option 2: Use Mobile App Stores
- Deploy Flutter app to **Google Play** or **App Store**
- Users download from stores

### Option 3: Local Network Access
- Keep backend running locally
- Connect devices on same WiFi
- Use your computer's IP address

---

## 📊 Current Access Points

| Component | Local URL | Status |
|-----------|-----------|--------|
| Backend API | `http://localhost:3000` | ✅ Ready |
| API Endpoints | `http://localhost:3000/api/*` | ✅ Ready |
| Flutter App | Emulator/Simulator | ✅ Ready |
| Web Version | Not built yet | ⚠️ Need to build |

---

## 🎯 Testing Links

Once backend is running, test these:

1. **API Root**: http://localhost:3000
2. **Health Check**: http://localhost:3000/api/health
3. **Register**: POST http://localhost:3000/api/auth/register
4. **Login**: POST http://localhost:3000/api/auth/login
5. **Dashboard**: GET http://localhost:3000/api/dashboard (needs auth)

---

## 💡 Tips

- **Backend must be running** before using the Flutter app
- **Use Postman/Thunder Client** to test API endpoints
- **Check console logs** for debugging
- **Same WiFi network** needed for physical devices

---

**Your app is ready to use locally!** 🎉

Start the backend and Flutter app, then access via emulator/simulator or physical device on your local network.

