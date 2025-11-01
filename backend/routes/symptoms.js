const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');
const symptomChecker = require('../ml/symptomChecker');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Get all symptom analyses for the authenticated user
router.get('/', (req, res) => {
  const db = getDB();

  db.all(
    'SELECT * FROM symptom_analyses WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, analyses) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ analyses });
    }
  );
});

// Get a specific symptom analysis
router.get('/:id', (req, res) => {
  const db = getDB();

  db.get(
    'SELECT * FROM symptom_analyses WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    (err, analysis) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (!analysis) {
        return res.status(404).json({ error: 'Symptom analysis not found' });
      }
      res.json({ analysis });
    }
  );
});

// Create a new symptom analysis with AI
router.post('/', async (req, res) => {
  try {
    const { selectedSymptoms, customDescription } = req.body;

    if (!selectedSymptoms && !customDescription) {
      return res.status(400).json({ error: 'Either selectedSymptoms or customDescription is required' });
    }

    // Analyze symptoms using AI
    const symptomsArray = selectedSymptoms
      ? (Array.isArray(selectedSymptoms) ? selectedSymptoms : [selectedSymptoms])
      : [];

    const analysis = await symptomChecker.analyzeSymptoms(customDescription || '', symptomsArray);

    const db = getDB();

    db.run(
      `INSERT INTO symptom_analyses 
       (user_id, selected_symptoms, custom_description, analysis_result, predicted_condition, 
        severity_score, triage_level, recommendation) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        req.user.id,
        symptomsArray.join(', ') || null,
        customDescription || null,
        JSON.stringify(analysis),
        analysis.predicted_condition,
        analysis.severity_score,
        analysis.triage_level,
        analysis.recommendation
      ],
      function (err) {
        if (err) {
          console.error('Error saving symptom analysis:', err);
          return res.status(500).json({ error: 'Failed to create symptom analysis' });
        }

        // Log prediction
        db.run(
          `INSERT INTO model_predictions (user_id, model_type, input_data, prediction_result, confidence)
           VALUES (?, ?, ?, ?, ?)`,
          [
            req.user.id,
            'symptom_checker',
            JSON.stringify({ selectedSymptoms: symptomsArray, customDescription }),
            JSON.stringify(analysis),
            analysis.confidence
          ]
        );

        // Get the created analysis
        db.get(
          'SELECT * FROM symptom_analyses WHERE id = ?',
          [this.lastID],
          (err, analysisRecord) => {
            if (err) {
              return res.status(500).json({ error: 'Failed to retrieve created analysis' });
            }
            res.status(201).json({
              message: 'Symptom analysis created successfully',
              analysis: {
                ...analysisRecord,
                analysis_result: analysis
              }
            });
          }
        );
      }
    );
  } catch (error) {
    console.error('Symptom analysis error:', error);
    res.status(500).json({ error: 'Failed to analyze symptoms', message: error.message });
  }
});


// Delete a symptom analysis
router.delete('/:id', (req, res) => {
  const db = getDB();

  db.run(
    'DELETE FROM symptom_analyses WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Symptom analysis not found' });
      }
      res.json({ message: 'Symptom analysis deleted successfully' });
    }
  );
});

module.exports = router;
