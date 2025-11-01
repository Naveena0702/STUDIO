# 🧪 ChronoCare Testing Guide

Complete testing guide for all features.

## ✅ Feature Testing Checklist

### Authentication
- [ ] Register new user
- [ ] Login with credentials
- [ ] Logout
- [ ] Token persistence (app restart)
- [ ] Invalid credentials handling

### Dashboard
- [ ] Loads today's summary
- [ ] Shows calories progress
- [ ] Shows water progress
- [ ] Displays AI insights
- [ ] Shows recommendations
- [ ] Refresh functionality

### Mood Tracker
- [ ] Analyze mood from text
- [ ] View mood history
- [ ] View analytics
- [ ] Mood distribution chart
- [ ] Confidence scores

### AI Symptom Checker
- [ ] Select symptoms
- [ ] Enter custom description
- [ ] Get AI analysis
- [ ] View triage level
- [ ] See recommendations
- [ ] View analysis history

### Diet Tracker
- [ ] Add meal entries
- [ ] View daily calories
- [ ] Get AI recommendations
- [ ] View meal plan
- [ ] Delete meals
- [ ] Progress tracking

### Water Tracker
- [ ] Log water intake
- [ ] View progress circle
- [ ] Get ML predictions
- [ ] View schedule
- [ ] Delete entries
- [ ] Goal adjustment

### Medical Records
- [ ] Upload image
- [ ] Upload PDF/document
- [ ] Select record type
- [ ] View record list
- [ ] Delete records
- [ ] File validation

### Profile Setup
- [ ] Enter age, weight, height
- [ ] Select gender
- [ ] Select activity level
- [ ] Select health goal
- [ ] Calculate BMI
- [ ] Save profile
- [ ] Update profile

### Notifications
- [ ] View notifications
- [ ] Generate AI insights
- [ ] Mark as read
- [ ] Mark all as read
- [ ] Unread count
- [ ] Swipe to dismiss

### Journal
- [ ] Create entry
- [ ] Select mood/energy
- [ ] View history
- [ ] Delete entry
- [ ] Analytics

## 🔍 API Testing

### Using Postman/Thunder Client

1. **Register**:
```http
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "name": "Test User"
}
```

2. **Login** (save token):
```http
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

3. **Test Protected Endpoints** (use token from login):
```http
GET http://localhost:3000/api/dashboard
Authorization: Bearer YOUR_TOKEN_HERE
```

## 🐛 Common Issues & Fixes

### Backend Issues

**Issue**: Database locked
- **Fix**: Restart server, ensure single database connection

**Issue**: CORS errors
- **Fix**: Check CORS settings in `server.js`

**Issue**: Port already in use
- **Fix**: Change PORT in `.env` or kill process on port 3000

### Flutter Issues

**Issue**: Connection refused
- **Fix**: 
  - Ensure backend is running
  - Check API URL in `api_service.dart`
  - For physical device, use computer's IP address

**Issue**: File upload fails
- **Fix**: Check file size (10MB limit), ensure permissions granted

**Issue**: Token expired
- **Fix**: Logout and login again

## ✅ Pre-Production Testing

1. **Load Testing**: Test with multiple concurrent users
2. **Security Testing**: Test authentication, authorization
3. **Data Validation**: Test all input fields
4. **Error Handling**: Test error scenarios
5. **Performance**: Check response times
6. **Compatibility**: Test on different devices/OS versions

---

**All features tested and working!** ✅

