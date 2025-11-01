# 🌐 Deploy ChronoCare to Get Public Link

## Quick Deployment Options

### Option 1: Render (Easiest - Free Tier Available)

#### Backend Deployment:

1. **Create Account**: https://render.com

2. **New Web Service**:
   - Connect your GitHub repo (or deploy directly)
   - Build Command: `cd backend && npm install`
   - Start Command: `cd backend && npm start`
   - Environment Variables:
     ```
     PORT=3000
     NODE_ENV=production
     JWT_SECRET=your-strong-secret-key-here
     ```

3. **Add PostgreSQL** (Free tier):
   - Create PostgreSQL database
   - Copy connection string to `DATABASE_URL` env var

4. **Deploy**: Auto-deploys on git push

**Result**: `https://chronocare-api.onrender.com`

#### Flutter Web Deployment:

```bash
cd chronocare_app
flutter build web
```

Then deploy `build/web/` folder to:
- **Vercel**: `vercel --prod`
- **Netlify**: Drag & drop `build/web`
- **Firebase**: `firebase deploy`

**Update API URL** in Flutter:
```dart
static const String baseUrl = 'https://chronocare-api.onrender.com/api';
```

---

### Option 2: Railway (Simplest - $5/month)

1. **Sign up**: https://railway.app
2. **New Project** → Deploy from GitHub
3. **Add PostgreSQL**: Auto-configured
4. **Set Environment Variables**: Same as Render
5. **Deploy**: Automatic

**Result**: `https://chronocare-production.up.railway.app`

---

### Option 3: Heroku (Classic - Free Tier Removed)

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create chronocare-api

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Set environment variables
heroku config:set JWT_SECRET=your-secret
heroku config:set NODE_ENV=production

# Deploy
git push heroku main
```

---

## 🚀 One-Click Deploy Script

### For Render (Recommended):

1. Create `render.yaml`:
```yaml
services:
  - type: web
    name: chronocare-api
    env: node
    buildCommand: cd backend && npm install
    startCommand: cd backend && npm start
    envVars:
      - key: NODE_ENV
        value: production
      - key: JWT_SECRET
        generateValue: true
  - type: pgsql
    name: chronocare-db
    plan: free
```

2. Push to GitHub
3. Connect to Render
4. Auto-deploys!

---

## 📱 Mobile App Deployment

### Android (Google Play):

```bash
cd chronocare_app
flutter build appbundle --release
```

Upload to: https://play.google.com/console

### iOS (App Store):

```bash
cd chronocare_app
flutter build ios --release
```

Upload via Xcode or: https://appstoreconnect.apple.com

---

## 🔗 After Deployment

### Update Flutter App:

Edit `chronocare_app/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://YOUR_DEPLOYED_URL/api';
```

Rebuild:
```bash
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web                  # Web
```

---

## ✅ Deployment Checklist

- [ ] Backend deployed and accessible
- [ ] Database connected (PostgreSQL)
- [ ] Environment variables set
- [ ] API tested with deployed URL
- [ ] Flutter app updated with new API URL
- [ ] Flutter app rebuilt
- [ ] Mobile app uploaded to stores (optional)
- [ ] Web version deployed (optional)

---

## 🎯 Public URLs After Deployment

- **Backend API**: `https://chronocare-api.onrender.com`
- **API Health**: `https://chronocare-api.onrender.com/api/health`
- **Web App**: `https://chronocare-app.vercel.app` (if deployed)

---

## 🆘 Need Help?

1. **Render**: Check logs in dashboard
2. **Railway**: View logs tab
3. **Heroku**: `heroku logs --tail`
4. **Testing**: Use Postman to test deployed API

---

**Deploy now and get your public link!** 🚀

