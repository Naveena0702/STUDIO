// AI Mood Classifier Service
// This simulates a DistilBERT-based mood classifier
// In production, replace with actual ML model API calls

const natural = require('natural');
const compromise = require('compromise');

// Emotion keywords mapping
const emotionKeywords = {
  happy: ['happy', 'joy', 'excited', 'glad', 'pleased', 'delighted', 'cheerful', 'great', 'amazing', 'wonderful', 'fantastic', 'love', 'enjoy', 'fun'],
  sad: ['sad', 'down', 'depressed', 'unhappy', 'upset', 'disappointed', 'hurt', 'lonely', 'empty', 'hopeless', 'miserable', 'tired', 'exhausted'],
  anxious: ['anxious', 'worried', 'nervous', 'stressed', 'panic', 'fear', 'scared', 'uneasy', 'restless', 'tense', 'apprehensive', 'overwhelmed'],
  angry: ['angry', 'mad', 'furious', 'annoyed', 'irritated', 'frustrated', 'rage', 'hostile', 'resentful', 'bitter'],
  neutral: ['okay', 'fine', 'alright', 'normal', 'regular', 'average', 'meh'],
  calm: ['calm', 'peaceful', 'relaxed', 'content', 'serene', 'tranquil', 'at ease', 'comfortable']
};

class MoodClassifier {
  constructor() {
    this.tokenizer = new natural.WordTokenizer();
    this.stemmer = natural.PorterStemmer;
  }

  // Analyze text and detect mood
  async classify(text) {
    if (!text || text.trim().length === 0) {
      return {
        mood: 'neutral',
        confidence: 0.5,
        emotions: { neutral: 1.0 }
      };
    }

    const lowerText = text.toLowerCase();
    const tokens = this.tokenizer.tokenize(lowerText);

    // Score each emotion
    const emotionScores = {};
    let totalMatches = 0;

    for (const [emotion, keywords] of Object.entries(emotionKeywords)) {
      let score = 0;
      for (const keyword of keywords) {
        if (lowerText.includes(keyword)) {
          score += 1;
          totalMatches += 1;
        }
      }
      emotionScores[emotion] = score;
    }

    // Calculate confidence based on matches
    const maxEmotion = Object.keys(emotionScores).reduce((a, b) =>
      emotionScores[a] > emotionScores[b] ? a : b
    );
    const maxScore = emotionScores[maxEmotion];

    // Normalize emotion scores
    const totalScore = Object.values(emotionScores).reduce((a, b) => a + b, 0);
    const normalizedEmotions = {};
    for (const [emotion, score] of Object.entries(emotionScores)) {
      normalizedEmotions[emotion] = totalScore > 0 ? score / totalScore : 0;
    }

    // If no strong emotion detected, default to neutral
    const detectedMood = maxScore > 0 ? maxEmotion : 'neutral';
    const confidence = maxScore > 0 ? Math.min(maxScore / 3, 0.95) : 0.5;

    // Analyze sentiment using natural
    // Note: Some versions of 'natural' do not support a 'negation' option array.
    // We fall back to the default AFINN-based analyzer without extra language features.
    let sentiment = 0;
    try {
      const analyzer = new natural.SentimentAnalyzer('English', natural.PorterStemmer);
      sentiment = analyzer.getSentiment(tokens);
    } catch (err) {
      // Safe fallback if sentiment analyzer instantiation fails on this platform/version
      sentiment = 0;
    }

    // Adjust based on sentiment
    let finalMood = detectedMood;
    if (sentiment > 0.3 && detectedMood !== 'happy') {
      finalMood = 'happy';
    } else if (sentiment < -0.3 && detectedMood !== 'sad' && detectedMood !== 'angry') {
      finalMood = 'sad';
    }

    return {
      mood: finalMood,
      confidence: Math.max(confidence, Math.abs(sentiment) * 0.8),
      emotions: normalizedEmotions,
      sentiment: sentiment
    };
  }

  // Batch classification
  async classifyBatch(texts) {
    const results = [];
    for (const text of texts) {
      results.push(await this.classify(text));
    }
    return results;
  }
}

module.exports = new MoodClassifier();


