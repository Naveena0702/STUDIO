# 🚀 Deploy Backend to Render (Free Hosting)

## Quick Deployment Steps

### Step 1: Prepare Your Backend

Make sure `backend/package.json` has:
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "init-db": "node database/init.js"
  }
}
```

---

### Step 2: Create Render Account

1. Go to: https://render.com
2. Click "Get Started for Free"
3. Sign up with **GitHub** (recommended)
4. Authorize Render to access your repositories

---

### Step 3: Connect Your Repository

1. **Push your code to GitHub** (if not already):
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/chronocare.git
   git push -u origin main
   ```

2. **In Render Dashboard:**
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Select `chronocare` repository

---

### Step 4: Configure Web Service

**Settings:**

- **Name:** `chronocare-backend`
- **Environment:** `Node`
- **Region:** Choose closest to your users
- **Branch:** `main`
- **Root Directory:** `backend` ⚠️ Important!
- **Build Command:** `npm install`
- **Start Command:** `npm start`

**Environment Variables (Add these):**
```
PORT=3000
JWT_SECRET=your-super-secret-key-change-this-in-production-min-32-chars
NODE_ENV=production
```

**Advanced Settings:**
- **Auto-Deploy:** Yes (updates automatically on git push)
- **Health Check Path:** `/api/health`

---

### Step 5: Deploy!

1. Click "Create Web Service"
2. Wait ~5-10 minutes for first deployment
3. You'll get a URL like: `https://chronocare-backend.onrender.com`

**✅ Your backend is now live!**

---

### Step 6: Update Flutter App

Edit `chronocare_app/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://chronocare-backend.onrender.com/api';
```

**Rebuild your app:**
```bash
cd chronocare_app
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🔧 Database Setup

### Option A: Keep SQLite (Simple, Free)
- SQLite file included in deployment
- Good for small-medium apps
- Limited scalability

### Option B: PostgreSQL (Recommended for Production)
1. In Render dashboard, create **PostgreSQL** database
2. Get connection string
3. Update `backend/database/database.js` to use PostgreSQL
4. Or use database URL from environment variable

---

## ✅ Test Your Deployment

1. **Health Check:**
   ```
   https://your-app.onrender.com/api/health
   ```
   Should return: `{"status": "ok"}`

2. **API Root:**
   ```
   https://your-app.onrender.com
   ```
   Should show API welcome message

3. **Test Registration:**
   - Update Flutter app with new URL
   - Try registering a new user
   - Should work!

---

## 🐛 Troubleshooting

### Deployment Fails
- ✅ Check build logs in Render dashboard
- ✅ Ensure `package.json` has "start" script
- ✅ Check Root Directory is `backend`

### App Can't Connect
- ✅ Check backend URL in `api_service.dart`
- ✅ Ensure backend is "Live" in Render dashboard
- ✅ Test API directly in browser

### Database Errors
- ✅ Ensure database is initialized
- ✅ Check environment variables
- ✅ Review Render logs

---

## 📝 Environment Variables Cheat Sheet

**Required:**
```
PORT=3000
JWT_SECRET=your-secret-key-here
NODE_ENV=production
```

**Optional:**
```
DB_PATH=/path/to/database.db (if using SQLite)
DATABASE_URL=postgresql://... (if using PostgreSQL)
```

---

## 🎯 Next Steps

1. ✅ Backend deployed
2. ✅ Update Flutter app URL
3. ✅ Build APK/IPA
4. ✅ Share with users!

**Your app is now accessible to everyone! 🌍**

