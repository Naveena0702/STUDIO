const express = require('express');

const { getDB } = require('../config/database');

const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Get all journal entries for the authenticated user
router.get('/', (req, res) => {
  const db = getDB();

  db.all(
    'SELECT * FROM journal_entries WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, entries) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ entries });
    }
  );
});

// Get a specific journal entry
router.get('/:id', (req, res) => {
  const db = getDB();

  db.get(
    'SELECT * FROM journal_entries WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    (err, entry) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (!entry) {
        return res.status(404).json({ error: 'Journal entry not found' });
      }
      res.json({ entry });
    }
  );
});

// Create a new journal entry
router.post('/', (req, res) => {
  const { content, mood, energy } = req.body;

  if (!content || !mood || !energy) {
    return res.status(400).json({ error: 'Content, mood, and energy are required' });
  }

  if (mood < 1 || mood > 5 || energy < 1 || energy > 5) {
    return res.status(400).json({ error: 'Mood and energy must be between 1 and 5' });
  }

  const db = getDB();

  db.run(
    'INSERT INTO journal_entries (user_id, content, mood, energy) VALUES (?, ?, ?, ?)',
    [req.user.id, content, mood, energy],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Failed to create journal entry' });
      }

      // Get the created entry
      db.get(
        'SELECT * FROM journal_entries WHERE id = ?',
        [this.lastID],
        (err, entry) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to retrieve created entry' });
          }
          res.status(201).json({
            message: 'Journal entry created successfully',
            entry
          });
        }
      );
    }
  );
});

// Update a journal entry
router.put('/:id', (req, res) => {
  const { content, mood, energy } = req.body;

  if (!content || !mood || !energy) {
    return res.status(400).json({ error: 'Content, mood, and energy are required' });
  }

  const db = getDB();

  db.run(
    'UPDATE journal_entries SET content = ?, mood = ?, energy = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?',
    [content, mood, energy, req.params.id, req.user.id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Journal entry not found' });
      }

      // Get the updated entry
      db.get(
        'SELECT * FROM journal_entries WHERE id = ?',
        [req.params.id],
        (err, entry) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to retrieve updated entry' });
          }
          res.json({
            message: 'Journal entry updated successfully',
            entry
          });
        }
      );
    }
  );
});

// Delete a journal entry
router.delete('/:id', (req, res) => {
  const db = getDB();

  db.run(
    'DELETE FROM journal_entries WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Journal entry not found' });
      }
      res.json({ message: 'Journal entry deleted successfully' });
    }
  );
});

// Get journal analytics
router.get('/analytics/summary', (req, res) => {
  const db = getDB();

  db.all(
    'SELECT * FROM journal_entries WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, entries) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      const totalEntries = entries.length;
      const avgMood = totalEntries > 0
        ? (entries.reduce((sum, e) => sum + e.mood, 0) / totalEntries).toFixed(2)
        : null;
      const avgEnergy = totalEntries > 0
        ? (entries.reduce((sum, e) => sum + e.energy, 0) / totalEntries).toFixed(2)
        : null;

      res.json({
        totalEntries,
        averageMood: avgMood ? parseFloat(avgMood) : null,
        averageEnergy: avgEnergy ? parseFloat(avgEnergy) : null
      });
    }
  );
});

module.exports = router;
