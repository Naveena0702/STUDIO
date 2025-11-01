# 🏥 ChronoCare - AI-Powered Personal Health Assistant

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Status](https://img.shields.io/badge/status-production--ready-brightgreen.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**Your complete AI-powered health management companion**

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Deployment](#-deployment)

</div>

---

## 🎯 What is ChronoCare?

ChronoCare is a comprehensive **AI-powered personal health assistant** that helps you:
- Track your mood with NLP emotion detection
- Check symptoms with ML-based medical triage
- Get personalized diet recommendations
- Stay hydrated with intelligent water reminders
- Manage medical records securely
- Monitor your overall health with analytics

**Built with**: Node.js + Express • Flutter • SQLite/PostgreSQL • AI/ML Services

---

## ✨ Features

### 🧠 AI-Powered Features

- **Smart Mood Tracker** - NLP analyzes emotions from text input
- **AI Symptom Checker** - ML predicts conditions with medical triage
- **Intelligent Diet Planner** - Personalized meal recommendations
- **ML Water Predictor** - Optimal hydration reminders
- **Health Insights** - AI-generated personalized recommendations

### 📱 Complete App Features

- ✅ User Authentication (JWT)
- ✅ Health Dashboard
- ✅ Journal Entries
- ✅ Meal Tracking
- ✅ Water Intake Logging
- ✅ Medical Records Management
- ✅ Profile Setup with BMR Calculation
- ✅ Notifications & Insights

---

## 🚀 Quick Start

### Option 1: Automated Setup (Windows)

Double-click: **`setup.bat`**

### Option 2: Manual Setup

#### Backend:
```bash
cd backend
npm install
npm run init-db
npm run dev
```

Backend runs at: **http://localhost:3000**

#### Flutter App:
```bash
cd chronocare_app
flutter pub get
flutter run
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [**START_HERE.md**](START_HERE.md) | ⭐ Start here - Complete overview |
| [**QUICK_START.md**](QUICK_START.md) | 5-minute setup guide |
| [**APP_ACCESS.md**](APP_ACCESS.md) | How to access the app |
| [**GO_LIVE_NOW.md**](GO_LIVE_NOW.md) | 🚀 **3-step deployment for mobile** |
| [**DEPLOY_FOR_EVERYONE.md**](DEPLOY_FOR_EVERYONE.md) | Complete mobile deployment guide |
| [**DEPLOY_BACKEND.md**](DEPLOY_BACKEND.md) | Backend deployment to Render |
| [**DEPLOY_NOW.md**](DEPLOY_NOW.md) | Web deployment guide |
| [**MOBILE_SETUP.md**](MOBILE_SETUP.md) | Test on mobile device |
| [**TESTING_GUIDE.md**](TESTING_GUIDE.md) | Testing checklist |
| [**FINAL_SUMMARY.md**](FINAL_SUMMARY.md) | Complete feature list |

---

## 🏗️ Project Structure

```
chronocare/
├── backend/              # Node.js/Express API
│   ├── database/        # Database schema & connection
│   ├── ml/              # AI/ML services
│   ├── routes/          # API endpoints
│   └── server.js        # Express server
│
├── chronocare_app/      # Flutter mobile app
│   ├── lib/
│   │   ├── screens/     # All app screens
│   │   ├── services/    # API integration
│   │   └── providers/   # State management
│   └── pubspec.yaml     # Dependencies
│
└── Documentation/       # Guides & docs
```

---

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register user
- `POST /api/auth/login` - Login
- `GET /api/auth/verify` - Verify token

### Health Tracking
- `GET /api/dashboard` - Health dashboard
- `POST /api/mood/analyze` - AI mood analysis
- `POST /api/symptoms` - Symptom checker
- `GET /api/diet/recommendations` - AI meal plan
- `GET /api/water/prediction/next-reminder` - ML reminder

### Full API List
Visit: **http://localhost:3000** (when backend is running)

---

## 🛠️ Technology Stack

### Backend
- **Framework**: Express.js
- **Database**: SQLite (dev) / PostgreSQL (production)
- **Auth**: JWT + bcrypt
- **ML**: Natural.js, Custom algorithms
- **File Upload**: Multer

### Frontend
- **Framework**: Flutter (Cross-platform)
- **State**: Provider
- **HTTP**: http package
- **Charts**: fl_chart
- **Storage**: shared_preferences

---

## 📱 Access the App

### Local Development

**Backend API**: http://localhost:3000  
**Flutter App**: Runs in emulator/simulator

### Configuration

For **physical devices**, update API URL in:
```
chronocare_app/lib/services/api_service.dart
```

Change line 10 to your computer's IP:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

---

## 🌐 Deployment

### 📱 Make App Available to Everyone on Mobile

**Quick Path:** See **[GO_LIVE_NOW.md](GO_LIVE_NOW.md)** for 3-step deployment!

1. **Deploy Backend** → [Render](https://render.com) (Free) - See **[DEPLOY_BACKEND.md](DEPLOY_BACKEND.md)**
2. **Build APK** → Run `BUILD_APK.bat` or `flutter build apk --release`
3. **Share APK** → Upload to Google Drive/Dropbox and share link!

**Full Guide:** **[DEPLOY_FOR_EVERYONE.md](DEPLOY_FOR_EVERYONE.md)**

### Web Deployment

1. **Backend**: Deploy to [Render](https://render.com) or [Railway](https://railway.app)
2. **Flutter Web**: Build and deploy to [Vercel](https://vercel.com) or [Netlify](https://netlify.com)

See: **[DEPLOY_NOW.md](DEPLOY_NOW.md)** for detailed steps

---

## ✅ Status

- ✅ **100% Features Implemented**
- ✅ **All Screens Complete**
- ✅ **AI Services Functional**
- ✅ **Database Schema Ready**
- ✅ **API Endpoints Working**
- ✅ **Production Ready**

---

## 🎓 Learning Resources

- **Backend**: Express.js documentation
- **Flutter**: flutter.dev
- **Database**: SQLite/PostgreSQL guides
- **ML**: Natural.js documentation

---

## 🤝 Contributing

This is a complete production-ready application. Feel free to:
- Fork and customize
- Add new features
- Improve ML models
- Enhance UI/UX

---

## 📝 License

MIT License - Feel free to use for personal or commercial projects.

---

## 🆘 Support

### Common Issues

1. **Backend won't start?**
   - Check if port 3000 is in use
   - Ensure Node.js is installed
   - Run `npm install` in backend folder

2. **Flutter can't connect?**
   - Ensure backend is running
   - Check API URL configuration
   - For physical device, ensure same WiFi network

3. **Database errors?**
   - Run `npm run init-db` in backend folder

### Documentation

All guides are in the root directory. Start with **[START_HERE.md](START_HERE.md)**

---

## 🎉 You're All Set!

Your ChronoCare app is ready to use. Follow the **[QUICK_START.md](QUICK_START.md)** guide to get running in 5 minutes!

**Happy Health Tracking!** 💎

---

<div align="center">

**Built with ❤️ for better health management**

[Back to Top](#-chronocare---ai-powered-personal-health-assistant)

</div>
