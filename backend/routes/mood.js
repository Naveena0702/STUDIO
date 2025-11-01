const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');
const moodClassifier = require('../ml/moodClassifier');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Analyze mood from text
router.post('/analyze', async (req, res) => {
  try {
    const { text, context } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({ error: 'Text input is required' });
    }

    // Classify mood using AI
    const analysis = await moodClassifier.classify(text);

    // Save to database
    const db = getDB();
    db.run(
      `INSERT INTO mood_logs (user_id, text_input, detected_mood, confidence_score, emotions, context)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        req.user.id,
        text,
        analysis.mood,
        analysis.confidence,
        JSON.stringify(analysis.emotions),
        context || null
      ],
      function (err) {
        if (err) {
          console.error('Error saving mood log:', err);
          return res.status(500).json({ error: 'Failed to save mood log' });
        }

        // Log prediction
        db.run(
          `INSERT INTO model_predictions (user_id, model_type, input_data, prediction_result, confidence)
           VALUES (?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'mood_classifier',
            JSON.stringify({ text }),
            JSON.stringify(analysis),
            analysis.confidence
          ]
        );

        res.json({
          message: 'Mood analyzed successfully',
          analysis: {
            mood: analysis.mood,
            confidence: analysis.confidence,
            emotions: analysis.emotions,
            sentiment: analysis.sentiment
          },
          log_id: this.lastID
        });
      }
    );
  } catch (error) {
    console.error('Mood analysis error:', error);
    res.status(500).json({ error: 'Failed to analyze mood', message: error.message });
  }
});

// Get mood history
router.get('/', (req, res) => {
  const db = getDB();
  const limit = parseInt(req.query.limit) || 50;

  db.all(
    `SELECT * FROM mood_logs 
     WHERE user_id = ? 
     ORDER BY created_at DESC 
     LIMIT ?`,
    [req.user.id, limit],
    (err, logs) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      // Parse JSON fields
      const parsedLogs = logs.map(log => ({
        ...log,
        emotions: JSON.parse(log.emotions || '{}')
      }));

      res.json({ logs: parsedLogs });
    }
  );
});

// Get mood analytics
router.get('/analytics', (req, res) => {
  const db = getDB();
  const days = parseInt(req.query.days) || 7;

  db.all(
    `SELECT * FROM mood_logs 
     WHERE user_id = ? 
     AND created_at >= datetime('now', '-${days} days')
     ORDER BY created_at ASC`,
    [req.user.id],
    (err, logs) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      // Calculate analytics
      const moodCounts = {};
      let totalConfidence = 0;
      const moodTrend = [];

      logs.forEach(log => {
        moodCounts[log.detected_mood] = (moodCounts[log.detected_mood] || 0) + 1;
        totalConfidence += log.confidence_score || 0;
        moodTrend.push({
          date: log.created_at,
          mood: log.detected_mood,
          confidence: log.confidence_score
        });
      });

      const avgConfidence = logs.length > 0 ? totalConfidence / logs.length : 0;
      const dominantMood = Object.keys(moodCounts).reduce((a, b) =>
        moodCounts[a] > moodCounts[b] ? a : b, 'neutral'
      );

      res.json({
        total_entries: logs.length,
        dominant_mood: dominantMood,
        mood_distribution: moodCounts,
        average_confidence: avgConfidence,
        mood_trend: moodTrend
      });
    }
  );
});

module.exports = router;


