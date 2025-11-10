const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { initDatabase } = require('./config/database');

// Load environment variables
dotenv.config();

const app = express();

// ⚡️ Use Render’s dynamic port (don’t lock to 3000)
const PORT = process.env.PORT || 10000;

// ⚡️ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ⚡️ Stronger CORS setup — allows mobile Flutter app access
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/journal', require('./routes/journal'));
app.use('/api/diet', require('./routes/diet'));
app.use('/api/water', require('./routes/water'));
app.use('/api/symptoms', require('./routes/symptoms'));
app.use('/api/mood', require('./routes/mood'));
app.use('/api/dashboard', require('./routes/dashboard'));
app.use('/api/profile', require('./routes/profile'));
app.use('/api/records', require('./routes/records'));
app.use('/api/notifications', require('./routes/notifications'));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'ChronoCare API is running',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'ChronoCare AI-Powered Backend API',
    version: '2.0.0',
    endpoints: {
      health: '/api/health',
      auth: '/api/auth',
      journal: '/api/journal',
      diet: '/api/diet',
      water: '/api/water',
      symptoms: '/api/symptoms',
      mood: '/api/mood',
      dashboard: '/api/dashboard',
      profile: '/api/profile',
      records: '/api/records',
      notifications: '/api/notifications'
    }
  });
});

// ⚡️ Catch-all route for undefined endpoints
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something went wrong!',
    message: err.message
  });
});

// ⚡️ Initialize SQLite database before starting server
initDatabase();

// ⚡️ Start server
app.listen(PORT, '0.0.0.0', () => { // ← Listen on all network interfaces!
  console.log(`🚀 ChronoCare Backend Server running on port ${PORT}`);
  console.log(`📍 Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
