const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { getDB } = require('../config/database');

const router = express.Router();

/* =========================
   REGISTER NEW USER
========================= */
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const db = getDB();

    // ✅ Check if user already exists
    const existingUser = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM users WHERE email = ?', [email], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // ✅ Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // ✅ Insert new user
    const newUserId = await new Promise((resolve, reject) => {
      db.run(
        'INSERT INTO users (email, password, name) VALUES (?, ?, ?)',
        [email, hashedPassword, name || null],
        function (err) {
          if (err) reject(err);
          else resolve(this.lastID);
        }
      );
    });

    // ✅ Generate JWT token
    const token = jwt.sign(
      { id: newUserId, email },
      process.env.JWT_SECRET || 'default-secret',
      { expiresIn: '7d' }
    );

    // ✅ Success response
    res.status(201).json({
      message: 'User registered successfully',
      token,
      user: {
        id: newUserId,
        email,
        name: name || null,
      },
    });
  } catch (error) {
    console.error('REGISTER ERROR:', error);
    res.status(500).json({ error: 'Server error', message: error.message });
  }
});

/* =========================
   LOGIN USER
========================= */
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const db = getDB();

    // ✅ Find user
    const user = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM users WHERE email = ?', [email], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // ✅ Verify password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // ✅ Generate token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET || 'default-secret',
      { expiresIn: '7d' }
    );

    // ✅ Success
    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      },
    });
  } catch (error) {
    console.error('LOGIN ERROR:', error);
    res.status(500).json({ error: 'Server error', message: error.message });
  }
});

/* =========================
   VERIFY TOKEN
========================= */
router.get('/verify', (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'default-secret', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    res.json({ valid: true, user });
  });
});

module.exports = router;

