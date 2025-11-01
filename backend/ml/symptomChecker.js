// AI Symptom Checker Service
// Simulates LightGBM-based symptom analysis with medical triage logic
// In production, replace with actual trained ML model

const medicalKnowledge = {
  conditions: {
    'common_cold': {
      symptoms: ['cough', 'runny nose', 'sneezing', 'sore throat', 'congestion'],
      severity: 'mild',
      triage: 'self_care'
    },
    'flu': {
      symptoms: ['fever', 'chills', 'body aches', 'fatigue', 'cough', 'headache'],
      severity: 'moderate',
      triage: 'consult_doctor'
    },
    'migraine': {
      symptoms: ['severe headache', 'nausea', 'sensitivity to light', 'throbbing pain'],
      severity: 'moderate',
      triage: 'self_care'
    },
    'anxiety': {
      symptoms: ['worry', 'nervousness', 'restlessness', 'panic', 'trouble sleeping'],
      severity: 'moderate',
      triage: 'consult_doctor'
    },
    'urinary_tract_infection': {
      symptoms: ['frequent urination', 'burning sensation', 'cloudy urine', 'pelvic pain'],
      severity: 'moderate',
      triage: 'consult_doctor'
    },
    'gastroenteritis': {
      symptoms: ['diarrhea', 'nausea', 'vomiting', 'stomach pain', 'fever'],
      severity: 'moderate',
      triage: 'consult_doctor'
    },
    'emergency_chest_pain': {
      symptoms: ['chest pain', 'shortness of breath', 'dizziness', 'nausea'],
      severity: 'severe',
      triage: 'emergency'
    },
    'emergency_stroke': {
      symptoms: ['sudden weakness', 'speech difficulty', 'facial drooping', 'severe headache'],
      severity: 'severe',
      triage: 'emergency'
    }
  },

  emergency_symptoms: [
    'chest pain', 'difficulty breathing', 'severe allergic reaction',
    'loss of consciousness', 'severe bleeding', 'stroke symptoms'
  ]
};

class SymptomChecker {
  constructor() {
    this.conditionPatterns = this.buildPatterns();
  }

  buildPatterns() {
    const patterns = {};
    for (const [condition, data] of Object.entries(medicalKnowledge.conditions)) {
      patterns[condition] = {
        keywords: data.symptoms.map(s => s.toLowerCase()),
        severity: data.severity,
        triage: data.triage
      };
    }
    return patterns;
  }

  // Analyze symptoms and predict condition
  async analyzeSymptoms(symptomText, selectedSymptoms = []) {
    const allSymptoms = [
      ...selectedSymptoms.map(s => s.toLowerCase()),
      ...this.extractSymptoms(symptomText)
    ];

    if (allSymptoms.length === 0) {
      return {
        predicted_condition: 'unknown',
        confidence: 0,
        severity_score: 0,
        triage_level: 'self_care',
        recommendation: 'Please provide more details about your symptoms.'
      };
    }

    // Check for emergency symptoms first
    const emergencyDetected = this.checkEmergency(allSymptoms);
    if (emergencyDetected) {
      return {
        predicted_condition: 'potential_emergency',
        confidence: 0.9,
        severity_score: 0.9,
        triage_level: 'emergency',
        recommendation: '🚨 URGENT: Please seek immediate medical attention or call emergency services. Do not delay.'
      };
    }

    // Match symptoms to conditions
    const conditionScores = {};
    for (const [condition, pattern] of Object.entries(this.conditionPatterns)) {
      let score = 0;
      let matches = 0;

      for (const symptom of allSymptoms) {
        for (const keyword of pattern.keywords) {
          if (symptom.includes(keyword) || keyword.includes(symptom)) {
            score += 1;
            matches += 1;
          }
        }
      }

      if (matches > 0) {
        conditionScores[condition] = {
          score: score / pattern.keywords.length, // Normalized score
          matches: matches,
          severity: pattern.severity,
          triage: pattern.triage
        };
      }
    }

    // Find best match
    const sortedConditions = Object.entries(conditionScores)
      .sort((a, b) => b[1].score - a[1].score);

    if (sortedConditions.length === 0) {
      return {
        predicted_condition: 'general_illness',
        confidence: 0.5,
        severity_score: 0.5,
        triage_level: 'consult_doctor',
        recommendation: 'Monitor your symptoms. If they persist or worsen, consult a healthcare professional.'
      };
    }

    const [topCondition, topData] = sortedConditions[0];
    const confidence = Math.min(topData.score, 0.95);

    // Calculate severity
    let severityScore = 0.5;
    if (topData.severity === 'severe') severityScore = 0.8;
    else if (topData.severity === 'moderate') severityScore = 0.6;
    else severityScore = 0.3;

    // Generate recommendation
    const recommendation = this.generateRecommendation(
      topCondition,
      topData.triage,
      topData.severity,
      allSymptoms
    );

    return {
      predicted_condition: topCondition,
      confidence: confidence,
      severity_score: severityScore,
      triage_level: topData.triage,
      recommendation: recommendation,
      matched_symptoms: allSymptoms.slice(0, 5),
      alternative_conditions: sortedConditions.slice(1, 3).map(([cond, data]) => ({
        condition: cond,
        confidence: data.score * 0.8
      }))
    };
  }

  extractSymptoms(text) {
    if (!text) return [];
    const lowerText = text.toLowerCase();
    const symptomList = [];

    // Extract common symptom phrases
    const symptomPhrases = [
      'headache', 'fever', 'cough', 'sore throat', 'runny nose',
      'nausea', 'vomiting', 'diarrhea', 'stomach pain', 'chest pain',
      'shortness of breath', 'dizziness', 'fatigue', 'body aches',
      'chills', 'sweating', 'joint pain', 'muscle pain', 'back pain'
    ];

    for (const phrase of symptomPhrases) {
      if (lowerText.includes(phrase)) {
        symptomList.push(phrase);
      }
    }

    return symptomList;
  }

  checkEmergency(symptoms) {
    for (const symptom of symptoms) {
      for (const emergency of medicalKnowledge.emergency_symptoms) {
        if (symptom.includes(emergency) || emergency.includes(symptom)) {
          return true;
        }
      }
    }
    return false;
  }

  generateRecommendation(condition, triage, severity, symptoms) {
    const recommendations = {
      self_care: {
        general: 'Monitor your symptoms at home. Rest, stay hydrated, and take over-the-counter medications as needed.',
        specific: {
          'common_cold': 'Rest, drink plenty of fluids, use saline nasal spray, and consider over-the-counter cold medicine.',
          'migraine': 'Rest in a dark, quiet room. Stay hydrated. Consider over-the-counter pain relief. Avoid triggers.'
        }
      },
      consult_doctor: {
        general: 'Schedule an appointment with your healthcare provider. Monitor symptoms and seek care if they worsen.',
        specific: {
          'flu': 'See a doctor for antiviral medication if caught early. Rest, stay hydrated, and monitor for complications.',
          'urinary_tract_infection': 'Consult a doctor for antibiotics. Drink plenty of water and avoid irritants.',
          'gastroenteritis': 'See a doctor if symptoms persist. Stay hydrated with electrolyte solutions.'
        }
      },
      emergency: '🚨 SEEK IMMEDIATE MEDICAL ATTENTION. Call emergency services or go to the nearest emergency room.'
    };

    const triageRecs = recommendations[triage];
    if (triageRecs === '🚨 SEEK IMMEDIATE MEDICAL ATTENTION.') {
      return triageRecs;
    }

    if (triageRecs.specific && triageRecs.specific[condition]) {
      return triageRecs.specific[condition];
    }

    return triageRecs.general + '\n\n⚠️ Note: This is not a medical diagnosis. Always consult healthcare professionals for proper medical advice.';
  }
}

module.exports = new SymptomChecker();


