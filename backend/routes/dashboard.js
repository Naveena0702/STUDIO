const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken);

// Get comprehensive health dashboard
router.get('/', (req, res) => {
  const db = getDB();
  const today = new Date().toISOString().split('T')[0];

  // Get all today's data in parallel
  Promise.all([
    getTodayMood(db, req.user.id),
    getTodayMeals(db, req.user.id, today),
    getTodayWater(db, req.user.id, today),
    getRecentSymptoms(db, req.user.id),
    getWeeklyTrends(db, req.user.id),
    getUserProfile(db, req.user.id)
  ]).then(([mood, meals, water, symptoms, trends, profile]) => {
    // Calculate insights
    const insights = generateInsights({
      mood, meals, water, symptoms, trends, profile
    });

    res.json({
      today: {
        mood: mood,
        meals: {
          total: meals.count,
          calories: meals.calories,
          goal: profile?.daily_calorie_goal || 2000,
          progress: profile?.daily_calorie_goal
            ? (meals.calories / profile.daily_calorie_goal * 100).toFixed(1)
            : 0
        },
        water: {
          glasses: water.glasses,
          goal: profile?.daily_water_goal || 8,
          progress: profile?.daily_water_goal
            ? (water.glasses / profile.daily_water_goal * 100).toFixed(1)
            : 0
        },
        symptoms: symptoms.length
      },
      weekly_trends: trends,
      insights: insights,
      recommendations: generateRecommendations({
        mood, meals, water, symptoms, profile
      })
    });
  }).catch(err => {
    console.error('Dashboard error:', err);
    res.status(500).json({ error: 'Failed to load dashboard' });
  });
});

// Helper functions
function getTodayMood(db, userId) {
  return new Promise((resolve, reject) => {
    const today = new Date().toISOString().split('T')[0];
    db.get(
      `SELECT AVG(confidence_score) as avg_confidence, detected_mood 
       FROM mood_logs 
       WHERE user_id = ? AND DATE(created_at) = ?
       GROUP BY detected_mood
       ORDER BY COUNT(*) DESC
       LIMIT 1`,
      [userId, today],
      (err, row) => {
        if (err) reject(err);
        else resolve(row || { detected_mood: 'neutral', avg_confidence: 0.5 });
      }
    );
  });
}

function getTodayMeals(db, userId, today) {
  return new Promise((resolve, reject) => {
    db.all(
      `SELECT SUM(calories) as total, COUNT(*) as count 
       FROM meal_entries 
       WHERE user_id = ? AND DATE(created_at) = ?`,
      [userId, today],
      (err, rows) => {
        if (err) reject(err);
        else {
          const row = rows[0] || { total: 0, count: 0 };
          resolve({ calories: row.total || 0, count: row.count || 0 });
        }
      }
    );
  });
}

function getTodayWater(db, userId, today) {
  return new Promise((resolve, reject) => {
    db.get(
      `SELECT SUM(glasses) as total 
       FROM water_entries 
       WHERE user_id = ? AND DATE(created_at) = ?`,
      [userId, today],
      (err, row) => {
        if (err) reject(err);
        else resolve({ glasses: row?.total || 0 });
      }
    );
  });
}

function getRecentSymptoms(db, userId) {
  return new Promise((resolve, reject) => {
    db.all(
      `SELECT * FROM symptom_analyses 
       WHERE user_id = ? 
       ORDER BY created_at DESC 
       LIMIT 5`,
      [userId],
      (err, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      }
    );
  });
}

function getWeeklyTrends(db, userId) {
  return new Promise((resolve, reject) => {
    db.all(
      `SELECT DATE(created_at) as date,
              (SELECT AVG(confidence_score) FROM mood_logs 
               WHERE user_id = ? AND DATE(created_at) = DATE(health_analytics.date)) as mood,
              calories_total,
              water_glasses
       FROM health_analytics
       WHERE user_id = ? AND date >= date('now', '-7 days')
       ORDER BY date DESC`,
      [userId, userId],
      (err, rows) => {
        if (err) reject(err);
        else resolve(rows || []);
      }
    );
  });
}

function getUserProfile(db, userId) {
  return new Promise((resolve, reject) => {
    db.get(
      'SELECT * FROM user_profiles WHERE user_id = ?',
      [userId],
      (err, row) => {
        if (err) reject(err);
        else resolve(row || null);
      }
    );
  });
}

function generateInsights({ mood, meals, water, symptoms, trends, profile }) {
  const insights = [];

  // Mood insights
  if (mood.detected_mood === 'sad' || mood.detected_mood === 'anxious') {
    insights.push({
      type: 'mood',
      message: `Your mood has been ${mood.detected_mood} today. Consider activities that boost your mood.`,
      priority: 'medium'
    });
  }

  // Calorie insights
  if (profile?.daily_calorie_goal) {
    const progress = (meals.calories / profile.daily_calorie_goal) * 100;
    if (progress < 50) {
      insights.push({
        type: 'diet',
        message: 'You\'re below your calorie target. Consider adding healthy snacks.',
        priority: 'low'
      });
    } else if (progress > 120) {
      insights.push({
        type: 'diet',
        message: 'You\'ve exceeded your calorie goal. Light exercise can help balance it.',
        priority: 'medium'
      });
    }
  }

  // Water insights
  if (profile?.daily_water_goal) {
    const progress = (water.glasses / profile.daily_water_goal) * 100;
    if (progress < 50) {
      insights.push({
        type: 'water',
        message: 'Your hydration is below target. Drink more water throughout the day.',
        priority: 'medium'
      });
    }
  }

  // Symptom insights
  if (symptoms.length > 0) {
    const recentSymptom = symptoms[0];
    if (recentSymptom.triage_level === 'emergency') {
      insights.push({
        type: 'health',
        message: '⚠️ Recent symptom check suggests seeking medical attention.',
        priority: 'high'
      });
    }
  }

  return insights;
}

function generateRecommendations({ mood, meals, water, symptoms, profile }) {
  const recommendations = [];

  recommendations.push('Maintain a balanced diet with adequate protein and vegetables.');
  recommendations.push('Stay hydrated throughout the day - aim for 8+ glasses of water.');
  recommendations.push('Get 7-9 hours of quality sleep for optimal health.');

  if (mood.detected_mood === 'anxious' || mood.detected_mood === 'stressed') {
    recommendations.push('Practice deep breathing or meditation to reduce stress.');
  }

  return recommendations;
}

module.exports = router;


