// ✅ ChronoCare Backend — Fixed server.js

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { initDatabase } = require('./config/database');
const { sendMail } = require('./utils/email');

// Load environment variables
dotenv.config();

const app = express();

// ⚡ Use Render’s dynamic port (or fallback to 10000)
const PORT = process.env.PORT || 10000;

// ⚙ Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 🧠 Logging (production-safe)
app.use(morgan('combined'));

// 🛡️ CORS — restrict origins for production if needed
app.use(
  cors({
    origin: [
      'http://localhost:3000',
      'http://127.0.0.1:5500',
      'http://localhost:8080',
      'https://chronocare.yourdomain.com',
    ],
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
);

// 🚦 Rate limiting to prevent abuse
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests, please try again later.',
});
app.use(limiter);

// 🧩 Routes
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

// ✅ Test email sending route
app.get('/api/test-email', async (req, res) => {
  try {
    const result = await sendMail(
      'your-email@example.com', // change this to your real email to test
      'ChronoCare Email Test ✅',
      '<h2>Hello from ChronoCare Backend!</h2><p>Your email system works perfectly 🎉</p>'
    );

    res.json({
      success: true,
      message: 'Email sent successfully!',
      preview: result.preview || null,
    });
  } catch (error) {
    console.error('Email send failed:', error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// 🩺 Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'ChronoCare API is running smoothly ✅',
    timestamp: new Date().toISOString(),
  });
});

// 🌐 Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'ChronoCare AI-Powered Backend API',
    version: '2.0.0',
    endpoints: {
      health: '/api/health',
      testEmail: '/api/test-email',
      auth: '/api/auth',
      journal: '/api/journal',
      diet: '/api/diet',
      water: '/api/water',
      symptoms: '/api/symptoms',
      mood: '/api/mood',
      dashboard: '/api/dashboard',
      profile: '/api/profile',
      records: '/api/records',
      notifications: '/api/notifications',
    },
  });
});

// ❌ Catch-all route for undefined endpoints
app.use((req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl,
  });
});

// 🚀 Start server safely
try {
  initDatabase();
  app.listen(PORT, () => {
    console.log(`✅ Server running on port ${PORT}`);
  });
} catch (error) {
  console.error('❌ Database initialization failed:', error);
}
