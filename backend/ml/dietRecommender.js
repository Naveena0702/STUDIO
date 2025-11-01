// AI Diet Recommender Service
// Simulates LightGBM-based diet recommendations
// In production, replace with actual trained ML model

class DietRecommender {
  constructor() {
    // Base meal templates
    this.mealTemplates = {
      breakfast: [
        { name: 'Oatmeal with fruits', calories: 350, protein: 12, carbs: 55, fats: 8 },
        { name: 'Scrambled eggs with whole grain toast', calories: 400, protein: 20, carbs: 35, fats: 18 },
        { name: 'Greek yogurt with berries', calories: 250, protein: 15, carbs: 30, fats: 5 },
        { name: 'Avocado toast', calories: 320, protein: 10, carbs: 30, fats: 20 }
      ],
      lunch: [
        { name: 'Grilled chicken salad', calories: 450, protein: 40, carbs: 25, fats: 20 },
        { name: 'Quinoa bowl with vegetables', calories: 380, protein: 15, carbs: 50, fats: 12 },
        { name: 'Salmon with sweet potato', calories: 500, protein: 35, carbs: 45, fats: 20 },
        { name: 'Turkey wrap with vegetables', calories: 350, protein: 25, carbs: 30, fats: 12 }
      ],
      dinner: [
        { name: 'Lean beef with brown rice', calories: 550, protein: 45, carbs: 50, fats: 18 },
        { name: 'Baked fish with vegetables', calories: 400, protein: 35, carbs: 30, fats: 15 },
        { name: 'Vegetarian stir-fry', calories: 350, protein: 15, carbs: 45, fats: 12 },
        { name: 'Chicken breast with quinoa', calories: 450, protein: 40, carbs: 40, fats: 15 }
      ],
      snack: [
        { name: 'Apple with almond butter', calories: 200, protein: 5, carbs: 25, fats: 10 },
        { name: 'Mixed nuts', calories: 180, protein: 6, carbs: 5, fats: 15 },
        { name: 'Protein smoothie', calories: 250, protein: 20, carbs: 30, fats: 5 },
        { name: 'Greek yogurt', calories: 150, protein: 12, carbs: 15, fats: 5 }
      ]
    };
  }

  // Calculate BMR (Basal Metabolic Rate)
  calculateBMR(age, gender, weight, height) {
    // Mifflin-St Jeor Equation
    if (gender === 'male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  // Calculate daily calorie needs
  calculateDailyCalories(bmr, activityLevel, goal) {
    const activityMultipliers = {
      sedentary: 1.2,
      lightly_active: 1.375,
      moderately_active: 1.55,
      very_active: 1.725,
      extra_active: 1.9
    };

    const tdee = bmr * (activityMultipliers[activityLevel] || 1.375);

    // Adjust based on goal
    if (goal === 'weight_loss') {
      return Math.round(tdee - 500); // 500 cal deficit
    } else if (goal === 'muscle_gain') {
      return Math.round(tdee + 300); // 300 cal surplus
    } else {
      return Math.round(tdee); // Maintenance
    }
  }

  // Calculate macro targets
  calculateMacros(calories, goal) {
    let proteinRatio, carbRatio, fatRatio;

    if (goal === 'weight_loss') {
      proteinRatio = 0.35;
      carbRatio = 0.35;
      fatRatio = 0.30;
    } else if (goal === 'muscle_gain') {
      proteinRatio = 0.30;
      carbRatio = 0.45;
      fatRatio = 0.25;
    } else {
      proteinRatio = 0.30;
      carbRatio = 0.40;
      fatRatio = 0.30;
    }

    return {
      protein: Math.round(calories * proteinRatio / 4), // 4 cal per gram
      carbs: Math.round(calories * carbRatio / 4),
      fats: Math.round(calories * fatRatio / 9) // 9 cal per gram
    };
  }

  // Generate meal plan
  async generateMealPlan(userProfile, consumedToday = { calories: 0, protein: 0, carbs: 0, fats: 0 }) {
    const { age, gender, weight, height, activity_level, health_goals } = userProfile;

    // Calculate targets
    const bmr = this.calculateBMR(age || 30, gender || 'male', weight || 70, height || 170);
    const dailyCalories = this.calculateDailyCalories(bmr, activity_level || 'moderately_active', health_goals || 'maintenance');
    const macros = this.calculateMacros(dailyCalories, health_goals || 'maintenance');

    // Remaining calories needed
    const remainingCalories = dailyCalories - consumedToday.calories;
    const remainingProtein = macros.protein - consumedToday.protein;
    const remainingCarbs = macros.carbs - consumedToday.carbs;
    const remainingFats = macros.fats - consumedToday.fats;

    // Generate meals to fill remaining needs
    const mealPlan = {
      breakfast: null,
      lunch: null,
      dinner: null,
      snack: null
    };

    // Distribute remaining calories across meals
    const mealDistribution = {
      breakfast: remainingCalories * 0.25,
      lunch: remainingCalories * 0.35,
      dinner: remainingCalories * 0.30,
      snack: remainingCalories * 0.10
    };

    // Select meals that best match remaining macros
    for (const [mealType, targetCalories] of Object.entries(mealDistribution)) {
      if (targetCalories > 50) {
        const candidates = this.mealTemplates[mealType];
        // Find meal closest to target
        const selected = candidates.reduce((best, current) => {
          const bestDiff = Math.abs(best.calories - targetCalories);
          const currentDiff = Math.abs(current.calories - targetCalories);
          return currentDiff < bestDiff ? current : best;
        });
        mealPlan[mealType] = selected;
      }
    }

    return {
      daily_calories: dailyCalories,
      daily_macros: macros,
      bmr: bmr,
      remaining_needs: {
        calories: remainingCalories,
        protein: remainingProtein,
        carbs: remainingCarbs,
        fats: remainingFats
      },
      meal_plan: mealPlan,
      recommendations: this.generateRecommendations(remainingCalories, macros, health_goals)
    };
  }

  generateRecommendations(remainingCalories, macros, goal) {
    const recommendations = [];

    if (remainingCalories < 200) {
      recommendations.push('You\'ve consumed most of your daily calories. Focus on nutrient-dense foods.');
    }

    if (goal === 'weight_loss' && remainingCalories < 0) {
      recommendations.push('You\'ve exceeded your calorie goal. Consider light exercise to balance intake.');
    }

    if (goal === 'muscle_gain') {
      recommendations.push('Ensure adequate protein intake (0.8-1g per lb bodyweight) for muscle growth.');
    }

    recommendations.push('Stay hydrated - drink at least 8 glasses of water daily.');
    recommendations.push('Include a variety of colorful fruits and vegetables in your meals.');

    return recommendations;
  }
}

module.exports = new DietRecommender();


