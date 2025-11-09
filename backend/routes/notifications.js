const express = require('express');
const { getDB } = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
router.use(authenticateToken);

// Get all notifications
router.get('/', (req, res) => {
    const db = getDB();
    const limit = parseInt(req.query.limit) || 50;
    const unreadOnly = req.query.unread === 'true';

    let query = `SELECT * FROM notifications 
               WHERE user_id = ?`;
    const params = [req.user.id];

    if (unreadOnly) {
        query += ' AND is_read = 0';
    }

    query += ' ORDER BY created_at DESC LIMIT ?';
    params.push(limit);

    db.all(query, params, (err, notifications) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        // Parse JSON fields
        const parsedNotifications = (notifications || []).map(notif => ({
            ...notif,
            action_data: notif.action_data ? JSON.parse(notif.action_data) : null
        }));

        res.json({ notifications: parsedNotifications });
    });
});

// Get unread count
router.get('/unread/count', (req, res) => {
    const db = getDB();

    db.get(
        `SELECT COUNT(*) as count 
     FROM notifications 
     WHERE user_id = ? AND is_read = 0`,
        [req.user.id],
        (err, row) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            res.json({ unread_count: row?.count || 0 });
        }
    );
});

// Mark notification as read
router.put('/:id/read', (req, res) => {
    const db = getDB();

    db.run(
        `UPDATE notifications 
     SET is_read = 1 
     WHERE id = ? AND user_id = ?`,
        [req.params.id, req.user.id],
        function (err) {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (this.changes === 0) {
                return res.status(404).json({ error: 'Notification not found' });
            }

            res.json({ message: 'Notification marked as read' });
        }
    );
});

// Mark all as read
router.put('/read-all', (req, res) => {
    const db = getDB();

    db.run(
        `UPDATE notifications 
     SET is_read = 1 
     WHERE user_id = ? AND is_read = 0`,
        [req.user.id],
        function (err) {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            res.json({ message: 'All notifications marked as read' });
        }
    );
});

// Generate personalized insights (AI-powered)
router.post('/generate', async (req, res) => {
    try {
        const db = getDB();
        const today = new Date().toISOString().split('T')[0];
        const userId = req.user.id;

        // Get user data for analysis
        const insights = await generateInsights(db, userId, today);

        // Create notifications for insights
        const createdNotifications = [];

        for (const insight of insights) {
            db.run(
                `INSERT INTO notifications (user_id, type, title, message, priority, action_data)
         VALUES (?, ?, ?, ?, ?, ?)`,
                [
                    userId,
                    insight.type,
                    insight.title,
                    insight.message,
                    insight.priority,
                    JSON.stringify(insight.action_data || {})
                ],
                function (err) {
                    if (!err) {
                        createdNotifications.push(this.lastID);
                    }
                }
            );
        }

        res.json({
            message: `Generated ${insights.length} insights`,
            insights: insights,
            notifications_created: createdNotifications.length
        });
    } catch (error) {
        console.error('Insight generation error:', error);
        res.status(500).json({ error: 'Failed to generate insights', message: error.message });
    }
});

// Helper function to generate AI insights
async function generateInsights(db, userId, today) {
    return new Promise((resolve, reject) => {
        const insights = [];

        // Get user profile
        db.get('SELECT * FROM user_profiles WHERE user_id = ?', [userId], async (err, profile) => {
            if (err) {
                return reject(err);
            }

            // Analyze mood trends
            db.all(
                `SELECT detected_mood, COUNT(*) as count 
         FROM mood_logs 
         WHERE user_id = ? AND DATE(created_at) >= date('now', '-7 days')
         GROUP BY detected_mood
         ORDER BY count DESC`,
                [userId],
                (err, moodData) => {
                    if (!err && moodData && moodData.length > 0) {
                        const dominantMood = moodData[0].detected_mood;
                        const totalMoods = moodData.reduce((sum, m) => sum + m.count, 0);

                        if (dominantMood === 'sad' || dominantMood === 'anxious') {
                            insights.push({
                                type: 'mood',
                                title: 'Mood Pattern Detected',
                                message: `Your mood has been ${dominantMood} in recent days. Consider activities that boost your mood, like exercise or talking to friends.`,
                                priority: 'medium',
                                action_data: { type: 'mood_tracker' }
                            });
                        }
                    }

                    // Analyze sleep patterns (if data available)
                    db.get(
                        `SELECT AVG(sleep_hours) as avg_sleep 
             FROM health_analytics 
             WHERE user_id = ? AND date >= date('now', '-7 days')`,
                        [userId],
                        (err, sleepData) => {
                            if (!err && sleepData && sleepData.avg_sleep) {
                                if (sleepData.avg_sleep < 6) {
                                    insights.push({
                                        type: 'sleep',
                                        title: 'Low Sleep Detected',
                                        message: `You've been averaging ${sleepData.avg_sleep.toFixed(1)} hours of sleep. Aim for 7-9 hours for optimal health.`,
                                        priority: 'medium',
                                        action_data: { type: 'sleep_tracker' }
                                    });
                                }
                            }

                            // Analyze diet patterns
                            db.get(
                                `SELECT SUM(calories) as total, COUNT(*) as count
                 FROM meal_entries 
                 WHERE user_id = ? AND DATE(created_at) >= date('now', '-3 days')`,
                                [userId],
                                (err, dietData) => {
                                    if (!err && dietData && profile) {
                                        const avgDaily = dietData.total / 3;
                                        const goal = profile.daily_calorie_goal || 2000;

                                        if (avgDaily < goal * 0.7) {
                                            insights.push({
                                                type: 'diet',
                                                title: 'Calorie Intake Low',
                                                message: `Your average calorie intake is below target. Consider adding healthy snacks to reach your ${goal} calorie goal.`,
                                                priority: 'low',
                                                action_data: { type: 'diet_tracker' }
                                            });
                                        } else if (avgDaily > goal * 1.2) {
                                            insights.push({
                                                type: 'diet',
                                                title: 'Calorie Intake High',
                                                message: `Your calorie intake is above your target. Light exercise can help balance your daily intake.`,
                                                priority: 'medium',
                                                action_data: { type: 'diet_tracker' }
                                            });
                                        }
                                    }

                                    // Analyze water intake
                                    db.get(
                                        `SELECT SUM(glasses) as total
                     FROM water_entries 
                     WHERE user_id = ? AND DATE(created_at) >= date('now', '-3 days')`,
                                        [userId],
                                        (err, waterData) => {
                                            if (!err && waterData && profile) {
                                                const avgDaily = waterData.total / 3;
                                                const goal = profile.daily_water_goal || 8;

                                                if (avgDaily < goal * 0.7) {
                                                    insights.push({
                                                        type: 'water',
                                                        title: 'Hydration Below Target',
                                                        message: `Your water intake is below your ${goal} glass daily goal. Stay hydrated for better health!`,
                                                        priority: 'medium',
                                                        action_data: { type: 'water_tracker' }
                                                    });
                                                }
                                            }

                                            resolve(insights);
                                        }
                                    );
                                }
                            );
                        }
                    );
                }
            );
        });
    });
}

module.exports = router;

