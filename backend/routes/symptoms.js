const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');

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
      db.close();
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
      db.close();
    }
  );
});

// Create a new symptom analysis
router.post('/', (req, res) => {
  const { selectedSymptoms, customDescription } = req.body;

  if (!selectedSymptoms && !customDescription) {
    return res.status(400).json({ error: 'Either selectedSymptoms or customDescription is required' });
  }

  // Generate a basic analysis result
  // In a real app, this would call an AI service
  const symptoms = selectedSymptoms 
    ? (Array.isArray(selectedSymptoms) ? selectedSymptoms.join(', ') : selectedSymptoms)
    : '';
  
  const analysisResult = generateBasicAnalysis(symptoms, customDescription || '');

  const db = getDB();
  
  db.run(
    'INSERT INTO symptom_analyses (user_id, selected_symptoms, custom_description, analysis_result) VALUES (?, ?, ?, ?)',
    [
      req.user.id,
      symptoms || null,
      customDescription || null,
      analysisResult
    ],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Failed to create symptom analysis' });
      }

      // Get the created analysis
      db.get(
        'SELECT * FROM symptom_analyses WHERE id = ?',
        [this.lastID],
        (err, analysis) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to retrieve created analysis' });
          }
          res.status(201).json({ 
            message: 'Symptom analysis created successfully',
            analysis 
          });
          db.close();
        }
      );
    }
  );
});

// Helper function to generate basic analysis
// In production, this would call an AI API
function generateBasicAnalysis(selectedSymptoms, customDescription) {
  let result = '🤖 AI Analysis Results:\n\n';
  
  if (selectedSymptoms) {
    result += `Selected Symptoms: ${selectedSymptoms}\n\n`;
  }
  
  if (customDescription) {
    result += `Custom Description: ${customDescription}\n\n`;
  }
  
  result += '📊 Preliminary Assessment:\n';
  result += 'Based on your symptoms, I recommend:\n\n';
  result += '1. Monitor your symptoms closely\n';
  result += '2. Stay hydrated and rest well\n';
  result += '3. Consider over-the-counter pain relief if needed\n';
  result += '4. Contact a healthcare professional if symptoms worsen\n\n';
  result += '⚠️ Important: This is not a medical diagnosis.\n';
  result += 'Please consult with a healthcare provider for proper medical advice.';
  
  return result;
}

// Delete a symptom analysis
router.delete('/:id', (req, res) => {
  const db = getDB();
  
  db.run(
    'DELETE FROM symptom_analyses WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    function(err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Symptom analysis not found' });
      }
      res.json({ message: 'Symptom analysis deleted successfully' });
      db.close();
    }
  );
});

module.exports = router;
