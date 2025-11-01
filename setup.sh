#!/bin/bash

echo "========================================"
echo "ChronoCare - Complete Setup Script"
echo "========================================"
echo ""

echo "[1/3] Setting up Backend..."
cd backend

if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
fi

echo ""
echo "Initializing database..."
npm run init-db

echo ""
echo "[2/3] Setting up Flutter App..."
cd ../chronocare_app

if [ ! -d ".dart_tool" ]; then
    echo "Installing Flutter dependencies..."
    flutter pub get
fi

echo ""
echo "[3/3] Setup Complete!"
echo ""
echo "Backend: Ready at http://localhost:3000"
echo "Flutter: Ready to run with 'flutter run'"
echo ""
echo "To start backend:"
echo "  cd backend && npm run dev"
echo ""
echo "To run Flutter app:"
echo "  cd chronocare_app && flutter run"
echo ""

