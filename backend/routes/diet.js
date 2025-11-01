const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');
const dietRecommender = require('../ml/dietRecommender');

const router = express.Router();

// All routes require authentication
router.use(authenticateToken);

// Get all meal entries for the authenticated user
router.get('/', (req, res) => {
  const db = getDB();

  db.all(
    'SELECT * FROM meal_entries WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, meals) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ meals });
    }
  );
});

// Get meals for a specific date
router.get('/date/:date', (req, res) => {
  const db = getDB();
  const date = req.params.date; // Format: YYYY-MM-DD

  db.all(
    'SELECT * FROM meal_entries WHERE user_id = ? AND DATE(created_at) = ? ORDER BY created_at DESC',
    [req.user.id, date],
    (err, meals) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ meals });
    }
  );
});

// Get a specific meal entry
router.get('/:id', (req, res) => {
  const db = getDB();

  db.get(
    'SELECT * FROM meal_entries WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    (err, meal) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (!meal) {
        return res.status(404).json({ error: 'Meal entry not found' });
      }
      res.json({ meal });
    }
  );
});

// Create a new meal entry
router.post('/', (req, res) => {
  const { food, calories, mealType } = req.body;

  if (!food || calories === undefined || !mealType) {
    return res.status(400).json({ error: 'Food, calories, and mealType are required' });
  }

  const validMealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  if (!validMealTypes.includes(mealType)) {
    return res.status(400).json({ error: 'Invalid meal type. Must be Breakfast, Lunch, Dinner, or Snack' });
  }

  const db = getDB();

  db.run(
    'INSERT INTO meal_entries (user_id, food, calories, meal_type) VALUES (?, ?, ?, ?)',
    [req.user.id, food, calories, mealType],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Failed to create meal entry' });
      }

      // Get the created meal
      db.get(
        'SELECT * FROM meal_entries WHERE id = ?',
        [this.lastID],
        (err, meal) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to retrieve created meal' });
          }
          res.status(201).json({
            message: 'Meal entry created successfully',
            meal
          });
        }
      );
    }
  );
});

// Update a meal entry
router.put('/:id', (req, res) => {
  const { food, calories, mealType } = req.body;

  if (!food || calories === undefined || !mealType) {
    return res.status(400).json({ error: 'Food, calories, and mealType are required' });
  }

  const db = getDB();

  db.run(
    'UPDATE meal_entries SET food = ?, calories = ?, meal_type = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?',
    [food, calories, mealType, req.params.id, req.user.id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Meal entry not found' });
      }

      // Get the updated meal
      db.get(
        'SELECT * FROM meal_entries WHERE id = ?',
        [req.params.id],
        (err, meal) => {
          if (err) {
            return res.status(500).json({ error: 'Failed to retrieve updated meal' });
          }
          res.json({
            message: 'Meal entry updated successfully',
            meal
          });
        }
      );
    }
  );
});

// Delete a meal entry
router.delete('/:id', (req, res) => {
  const db = getDB();

  db.run(
    'DELETE FROM meal_entries WHERE id = ? AND user_id = ?',
    [req.params.id, req.user.id],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }
      if (this.changes === 0) {
        return res.status(404).json({ error: 'Meal entry not found' });
      }
      res.json({ message: 'Meal entry deleted successfully' });
    }
  );
});

// Get nutrition summary
router.get('/analytics/summary', (req, res) => {
  const db = getDB();

  db.all(
    'SELECT * FROM meal_entries WHERE user_id = ? ORDER BY created_at DESC',
    [req.user.id],
    (err, meals) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      const totalMeals = meals.length;
      const totalCalories = meals.reduce((sum, meal) => sum + meal.calories, 0);
      const avgCalories = totalMeals > 0 ? (totalCalories / totalMeals).toFixed(0) : 0;

      res.json({
        totalMeals,
        totalCalories,
        averageCalories: parseInt(avgCalories)
      });
    }
  );
});

// Get today's nutrition summary
router.get('/analytics/today', (req, res) => {
  const db = getDB();
  const today = new Date().toISOString().split('T')[0];

  db.all(
    'SELECT * FROM meal_entries WHERE user_id = ? AND DATE(created_at) = ?',
    [req.user.id, today],
    (err, meals) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      const totalMeals = meals.length;
      const totalCalories = meals.reduce((sum, meal) => sum + meal.calories, 0);
      const avgCalories = totalMeals > 0 ? (totalCalories / totalMeals).toFixed(0) : 0;

      res.json({
        date: today,
        totalMeals,
        totalCalories,
        averageCalories: parseInt(avgCalories),
        meals
      });
    }
  );
});

// Get AI diet recommendations
router.get('/recommendations', async (req, res) => {
  try {
    const db = getDB();

    // Get user profile
    db.get(
      'SELECT * FROM user_profiles WHERE user_id = ?',
      [req.user.id],
      async (err, profile) => {
        if (err) {
          return res.status(500).json({ error: 'Database error' });
        }

        if (!profile) {
          return res.status(404).json({
            error: 'Profile not found. Please set up your profile first.'
          });
        }

        // Get today's consumed meals
        const today = new Date().toISOString().split('T')[0];
        db.all(
          `SELECT SUM(calories) as total_calories, 
                  SUM(proteins) as total_protein, 
                  SUM(carbs) as total_carbs, 
                  SUM(fats) as total_fats
           FROM meal_entries 
           WHERE user_id = ? AND DATE(created_at) = ?`,
          [req.user.id, today],
          async (err, consumed) => {
            if (err) {
              return res.status(500).json({ error: 'Database error' });
            }

            const consumedToday = {
              calories: consumed[0]?.total_calories || 0,
              protein: consumed[0]?.total_protein || 0,
              carbs: consumed[0]?.total_carbs || 0,
              fats: consumed[0]?.total_fats || 0
            };

            // Generate meal plan
            const mealPlan = await dietRecommender.generateMealPlan(profile, consumedToday);

            // Save recommendation
            db.run(
              `INSERT INTO diet_recommendations 
               (user_id, recommendation_type, meal_plan, calories_target, macros_target)
               VALUES (?, ?, ?, ?, ?)`,
              [
                req.user.id,
                'daily_plan',
                JSON.stringify(mealPlan.meal_plan),
                mealPlan.daily_calories,
                JSON.stringify(mealPlan.daily_macros)
              ]
            );

            res.json({
              meal_plan: mealPlan,
              consumed_today: consumedToday
            });
          }
        );
      }
    );
  } catch (error) {
    console.error('Diet recommendation error:', error);
    res.status(500).json({ error: 'Failed to generate recommendations', message: error.message });
  }
});

module.exports = router;
