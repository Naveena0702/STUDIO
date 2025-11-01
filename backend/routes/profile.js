const express = require('express');
const { getDB } = require('../database/database');
const { authenticateToken } = require('../middleware/auth');
const dietRecommender = require('../ml/dietRecommender');

const router = express.Router();
router.use(authenticateToken);

// Get user profile
router.get('/', (req, res) => {
    const db = getDB();

    db.get(
        'SELECT * FROM user_profiles WHERE user_id = ?',
        [req.user.id],
        (err, profile) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (!profile) {
                return res.json({ profile: null, message: 'Profile not set up yet' });
            }

            res.json({ profile });
        }
    );
});

// Create or update user profile
router.post('/', async (req, res) => {
    try {
        const { age, weight, height, gender, activity_level, health_goals } = req.body;

        // Validate required fields
        if (!age || !weight || !height || !gender || !activity_level || !health_goals) {
            return res.status(400).json({
                error: 'Missing required fields: age, weight, height, gender, activity_level, health_goals'
            });
        }

        // Calculate BMR and daily targets
        const bmr = dietRecommender.calculateBMR(age, gender, weight, height);
        const dailyCalories = dietRecommender.calculateDailyCalories(
            bmr,
            activity_level,
            health_goals
        );
        const macros = dietRecommender.calculateMacros(dailyCalories, health_goals);

        // Calculate water goal (ml to glasses approximation)
        const waterGoalMl = weight * 35; // 35ml per kg body weight
        const dailyWaterGoal = Math.round(waterGoalMl / 250); // ~250ml per glass

        const db = getDB();

        // Check if profile exists
        db.get(
            'SELECT id FROM user_profiles WHERE user_id = ?',
            [req.user.id],
            (err, existing) => {
                if (err) {
                    return res.status(500).json({ error: 'Database error' });
                }

                if (existing) {
                    // Update existing profile
                    db.run(
                        `UPDATE user_profiles 
             SET age = ?, weight = ?, height = ?, gender = ?, activity_level = ?, 
                 health_goals = ?, bmr = ?, daily_calorie_goal = ?, daily_water_goal = ?,
                 updated_at = CURRENT_TIMESTAMP
             WHERE user_id = ?`,
                        [
                            age, weight, height, gender, activity_level, health_goals,
                            bmr, dailyCalories, dailyWaterGoal, req.user.id
                        ],
                        function (err) {
                            if (err) {
                                return res.status(500).json({ error: 'Failed to update profile' });
                            }

                            res.json({
                                message: 'Profile updated successfully',
                                profile: {
                                    age, weight, height, gender, activity_level, health_goals,
                                    bmr, daily_calorie_goal: dailyCalories, daily_water_goal: dailyWaterGoal,
                                    macros
                                }
                            });
                        }
                    );
                } else {
                    // Create new profile
                    db.run(
                        `INSERT INTO user_profiles 
             (user_id, age, weight, height, gender, activity_level, health_goals, 
              bmr, daily_calorie_goal, daily_water_goal)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                        [
                            req.user.id, age, weight, height, gender, activity_level, health_goals,
                            bmr, dailyCalories, dailyWaterGoal
                        ],
                        function (err) {
                            if (err) {
                                return res.status(500).json({ error: 'Failed to create profile' });
                            }

                            res.status(201).json({
                                message: 'Profile created successfully',
                                profile: {
                                    age, weight, height, gender, activity_level, health_goals,
                                    bmr, daily_calorie_goal: dailyCalories, daily_water_goal: dailyWaterGoal,
                                    macros
                                }
                            });
                        }
                    );
                }
            }
        );
    } catch (error) {
        console.error('Profile error:', error);
        res.status(500).json({ error: 'Failed to process profile', message: error.message });
    }
});

// Update notification preferences
router.put('/notifications', (req, res) => {
    const { preferences } = req.body;

    if (!preferences || typeof preferences !== 'object') {
        return res.status(400).json({ error: 'Invalid notification preferences' });
    }

    const db = getDB();

    db.run(
        `UPDATE user_profiles 
     SET notification_preferences = ?, updated_at = CURRENT_TIMESTAMP
     WHERE user_id = ?`,
        [JSON.stringify(preferences), req.user.id],
        function (err) {
            if (err) {
                return res.status(500).json({ error: 'Failed to update preferences' });
            }

            if (this.changes === 0) {
                return res.status(404).json({ error: 'Profile not found. Please create profile first.' });
            }

            res.json({ message: 'Notification preferences updated successfully' });
        }
    );
});

module.exports = router;

