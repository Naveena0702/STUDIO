// ML-based Water Reminder Predictor
// Predicts optimal reminder times based on user's water intake patterns

class WaterPredictor {
  constructor() {
    this.patterns = new Map();
  }

  // Analyze water intake pattern and predict next reminder time
  async predictNextReminder(waterEntries, goalGlasses, currentHour) {
    if (!waterEntries || waterEntries.length === 0) {
      // Default: remind every 2 hours starting from current time
      return {
        nextReminderMinutes: 120,
        predictedOptimalTime: new Date(Date.now() + 120 * 60 * 1000),
        confidence: 0.5,
        reason: 'No historical data available'
      };
    }

    // Calculate average time between water entries
    const intervals = [];
    for (let i = 1; i < waterEntries.length; i++) {
      const prev = new Date(waterEntries[i - 1].created_at);
      const curr = new Date(waterEntries[i].created_at);
      const diffMinutes = (curr - prev) / (1000 * 60);
      intervals.push(diffMinutes);
    }

    const avgInterval = intervals.length > 0
      ? intervals.reduce((a, b) => a + b, 0) / intervals.length
      : 120; // Default 2 hours

    // Calculate current intake
    const todayEntries = waterEntries.filter(entry => {
      const entryDate = new Date(entry.created_at);
      const today = new Date();
      return entryDate.toDateString() === today.toDateString();
    });

    const glassesConsumed = todayEntries.reduce((sum, entry) => sum + (entry.glasses || 0), 0);
    const remainingGlasses = goalGlasses - glassesConsumed;

    // Predict next reminder based on remaining glasses and time left in day
    const currentHourOfDay = currentHour || new Date().getHours();
    const hoursRemaining = 24 - currentHourOfDay;
    
    if (remainingGlasses <= 0) {
      return {
        nextReminderMinutes: 240, // 4 hours
        predictedOptimalTime: new Date(Date.now() + 240 * 60 * 1000),
        confidence: 0.9,
        reason: 'Goal achieved! Next reminder in 4 hours to maintain hydration.'
      };
    }

    // Optimal spacing: distribute remaining glasses over remaining hours
    const optimalInterval = hoursRemaining > 0
      ? Math.min((hoursRemaining * 60) / remainingGlasses, avgInterval)
      : avgInterval;

    const nextReminderMinutes = Math.max(30, Math.min(optimalInterval, 240)); // 30min to 4hrs

    // Adjust based on time of day (more frequent during active hours)
    let adjustedMinutes = nextReminderMinutes;
    if (currentHourOfDay >= 8 && currentHourOfDay <= 22) {
      adjustedMinutes = nextReminderMinutes * 0.8; // More frequent during active hours
    } else {
      adjustedMinutes = nextReminderMinutes * 1.5; // Less frequent during sleep hours
    }

    const confidence = Math.min(0.9, 0.5 + (waterEntries.length / 20)); // More data = higher confidence

    return {
      nextReminderMinutes: Math.round(adjustedMinutes),
      predictedOptimalTime: new Date(Date.now() + adjustedMinutes * 60 * 1000),
      confidence: confidence,
      reason: remainingGlasses > 0
        ? `Distribute ${remainingGlasses} remaining glasses over ${hoursRemaining.toFixed(1)} hours`
        : 'Maintain hydration throughout the day',
      glassesRemaining: remainingGlasses,
      hoursRemaining: hoursRemaining
    };
  }

  // Generate daily hydration schedule
  async generateSchedule(goalGlasses, wakeHour = 7, sleepHour = 23) {
    const activeHours = sleepHour - wakeHour;
    const glassesPerHour = goalGlasses / activeHours;
    const reminderInterval = Math.max(30, Math.min(120, (activeHours * 60) / goalGlasses));

    const schedule = [];
    let currentHour = wakeHour;

    while (currentHour < sleepHour && schedule.length < goalGlasses) {
      schedule.push({
        hour: currentHour,
        time: `${currentHour.toString().padStart(2, '0')}:00`,
        message: `Time for water! Glass ${schedule.length + 1} of ${goalGlasses}`
      });
      currentHour += reminderInterval / 60;
    }

    return {
      schedule: schedule,
      reminderInterval: Math.round(reminderInterval),
      totalReminders: schedule.length
    };
  }
}

module.exports = new WaterPredictor();

