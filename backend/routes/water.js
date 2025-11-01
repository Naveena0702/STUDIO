const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Get all water entries for the authenticated user
router.get('/', (req, res) => {
  const db = getDB();
  
  db.all(
    'SELECT * FROM water_entries WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, entries) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ entries });
      db.close();
    }
  );
});

// Get water entries for a specific date
router.get('/date/:date', (req, res) => {
  const db = getDB();
  const date = req.params.date; // Format: YYYY-MM-DD
  
  db.all(
    'SELECT * FROM water_entries WHERE user_id = ? AND DATE(created_at) = ? ORDER BY created_at DESC',
    [req.user.id, date],
    (err, entries) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ entries });
      db.close();
    }
  );
});

// Get a specific water entry
router.get('/:id', (req, res) => {
  const db = getDB();
  
  db.get(
    'SELECT * FROM water_entries WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    (err, entry) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (!entry) {
        return res.status(404).json({ error: 'Water entry not found' });
      }
      res.json({ entry });
      db.close();
    }
  );
});

// Create a new water entry
router.post('/', (req, res) => {
  const { glasses } = req.body;
  const glassesToAdd = glasses || 1;

  if (glassesToAdd < 1) {
    return res.status(400).json({ error: 'Glasses must be at least 1' });
  }

  const db = getDB();
  
  db.run(
    'INSERT INTO water_entries (user_id, glasses) VALUES (?, ?)',
    [req.user.id, glassesToAdd],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Failed to create water entry' });
      }

      // Get the created entry
      db.get(
        'SELECT * FROM water_entries WHERE id = ?',
        [this.lastID],
        (err, entry) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to retrieve created entry' });
          }
          res.status(201).json({ 
            message: 'Water entry created successfully',
            entry 
          });
          db.close();
        }
      );
    }
  );
});

// Delete a water entry
router.delete('/:id', (req, res) => {
  const db = getDB();
  
  db.run(
    'DELETE FROM water_entries WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Water entry not found' });
      }
      res.json({ message: 'Water entry deleted successfully' });
      db.close();
    }
  );
});

// Get today's water summary
router.get('/analytics/today', (req, res) => {
  const db = getDB();
  const today = new Date().toISOString().split('T')[0];
  
  db.all(
    'SELECT * FROM water_entries WHERE user_id = ? AND DATE(created_at) = ?',
    [req.user.id, today],
    (err, entries) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      const totalGlasses = entries.reduce((sum, entry) => sum + entry.glasses, 0);

      res.json({
        date: today,
        totalGlasses,
        entries
      });

      db.close();
    }
  );
});

// Get water analytics summary
router.get('/analytics/summary', (req, res) => {
  const db = getDB();
  
  db.all(
    'SELECT * FROM water_entries WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, entries) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      const totalEntries = entries.length;
      const totalGlasses = entries.reduce((sum, entry) => sum + entry.glasses, 0);
      const avgGlassesPerDay = totalEntries > 0 ? (totalGlasses / totalEntries).toFixed(1) : 0;

      res.json({
        totalEntries,
        totalGlasses,
        averageGlassesPerDay: parseFloat(avgGlassesPerDay)
      });

      db.close();
    }
  );
});

module.exports = router;
