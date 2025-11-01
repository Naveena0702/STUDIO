# ChronoCare - Quick Setup Guide

## Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Create `.env` file:**
   - Copy `.env.example` to `.env`
   - Or create `.env` with:
     ```
     PORT=3000
     JWT_SECRET=your-secret-key-change-this-in-production
     NODE_ENV=development
     ```

4. **Initialize database:**
   ```bash
   npm run init-db
   ```

5. **Start the server:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev
   
   # Production mode
   npm start
   ```

   The API will be running at `http://localhost:3000`

## Flutter App Setup

1. **Navigate to app directory:**
   ```bash
   cd chronocare_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   - Open `lib/services/api_service.dart`
   - Update the `baseUrl` based on your setup:
     - **Android Emulator**: `http://10.0.2.2:3000/api`
     - **iOS Simulator**: `http://localhost:3000/api`
     - **Physical Device**: `http://YOUR_COMPUTER_IP:3000/api`
       - Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
       - Example: `http://192.168.1.100:3000/api`

4. **Run the app:**
   ```bash
   flutter run
   ```

## Testing

1. **Start the backend server first**
2. **Run the Flutter app**
3. **Register a new account** or login with existing credentials
4. **Test the features:**
   - Create journal entries
   - Log meals and track calories
   - Record water intake
   - Use AI Symptom Checker

## Troubleshooting

### Backend Issues
- **Database errors**: Make sure you ran `npm run init-db`
- **Port already in use**: Change PORT in `.env` file
- **JWT errors**: Ensure JWT_SECRET is set in `.env`

### Flutter App Issues
- **Connection refused**: Check that backend is running and API URL is correct
- **CORS errors**: Make sure backend CORS is enabled (already configured)
- **Authentication errors**: Clear app data and try logging in again
- **"Building with plugins requires symlink support"** (Windows):
  - **Solution**: Enable Developer Mode in Windows
  - **Quick fix**: Double-click `ENABLE_DEVELOPER_MODE.bat` in the project root
  - **Manual**: Run `start ms-settings:developers` and toggle "Developer Mode" ON
  - **After enabling**: Restart your terminal/IDE and try again

- **"CMake Error: Visual Studio 16 2019 could not be found"**:
  - **If you have VS 2026 Insiders**: It's a pre-release version that may not be fully supported
  - **Solution 1**: Install Visual Studio 2022 Community (stable) - See `INSTALL_VISUAL_STUDIO.md`
  - **Solution 2**: Try specifying CMake generator manually:
    ```bash
    flutter run --verbose
    ```
  - **Solution 3**: Use Android emulator instead:
    ```bash
    flutter run -d android
    ```
  - **Quick fix**: Double-click `INSTALL_VS.bat` for installation guide

## Important Notes

- The backend uses SQLite for data storage (file: `chronocare.db`)
- JWT tokens expire after 7 days
- All passwords are hashed using bcrypt
- The database connection uses a singleton pattern for optimal performance

## Project Structure

```
chronocare/
├── backend/
│   ├── database/          # SQLite database setup
│   ├── middleware/        # Authentication middleware
│   ├── routes/            # API endpoints
│   └── server.js          # Main server file
├── chronocare_app/
│   ├── lib/
│   │   ├── screens/       # All app screens
│   │   ├── services/      # API service layer
│   │   └── providers/     # State management
│   └── pubspec.yaml       # Dependencies
└── README.md              # Full documentation
```

