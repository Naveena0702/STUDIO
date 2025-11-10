import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // TEMP FIX: Force Android emulator endpoint and updated port (backend now on 3001).
  // Replace with your deployed URL when you move to production, e.g.:
  // static const String baseUrl = 'https://your-app.onrender.com/api';
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Remove token (logout)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers with auth token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Auth endpoints
  static Future<Map<String, dynamic>> register(String email, String password, String? name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Registration failed');
    }
  }
  
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await saveToken(data['token']);
      }
      return data;
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login failed');
    }
  }
  
  // Journal endpoints
  static Future<List<dynamic>> getJournalEntries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['entries'] ?? [];
    } else {
      throw Exception('Failed to load journal entries');
    }
  }
  
  static Future<Map<String, dynamic>> createJournalEntry(String content, int mood, int energy) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal'),
      headers: await getHeaders(),
      body: jsonEncode({
        'content': content,
        'mood': mood,
        'energy': energy,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create journal entry');
    }
  }
  
  static Future<void> deleteJournalEntry(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/journal/$id'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete journal entry');
    }
  }
  
  // Diet endpoints
  static Future<List<dynamic>> getMealEntries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/diet'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['meals'] ?? [];
    } else {
      throw Exception('Failed to load meal entries');
    }
  }
  
  static Future<Map<String, dynamic>> createMealEntry(String food, int calories, String mealType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/diet'),
      headers: await getHeaders(),
      body: jsonEncode({
        'food': food,
        'calories': calories,
        'mealType': mealType,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create meal entry');
    }
  }
  
  static Future<void> deleteMealEntry(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/diet/$id'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete meal entry');
    }
  }
  
  // Water endpoints
  static Future<List<dynamic>> getWaterEntries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/water'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['entries'] ?? [];
    } else {
      throw Exception('Failed to load water entries');
    }
  }
  
  static Future<Map<String, dynamic>> createWaterEntry(int glasses) async {
    final response = await http.post(
      Uri.parse('$baseUrl/water'),
      headers: await getHeaders(),
      body: jsonEncode({
        'glasses': glasses,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create water entry');
    }
  }
  
  static Future<void> deleteWaterEntry(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/water/$id'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete water entry');
    }
  }
  
  // Symptoms endpoints
  static Future<List<dynamic>> getSymptomAnalyses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/symptoms'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['analyses'] ?? [];
    } else {
      throw Exception('Failed to load symptom analyses');
    }
  }
  
  static Future<Map<String, dynamic>> createSymptomAnalysis(String selectedSymptoms, String? customDescription) async {
    final response = await http.post(
      Uri.parse('$baseUrl/symptoms'),
      headers: await getHeaders(),
      body: jsonEncode({
        'selectedSymptoms': selectedSymptoms.isNotEmpty ? selectedSymptoms.split(', ') : [],
        'customDescription': customDescription,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to create symptom analysis');
    }
  }
  
  static Future<void> deleteSymptomAnalysis(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/symptoms/$id'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete symptom analysis');
    }
  }
  
  // Mood endpoints
  static Future<Map<String, dynamic>> analyzeMood(String text, String? context) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood/analyze'),
      headers: await getHeaders(),
      body: jsonEncode({
        'text': text,
        'context': context,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to analyze mood');
    }
  }
  
  static Future<List<dynamic>> getMoodHistory({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood?limit=$limit'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['logs'] ?? [];
    } else {
      throw Exception('Failed to load mood history');
    }
  }
  
  static Future<Map<String, dynamic>> getMoodAnalytics({int days = 7}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood/analytics?days=$days'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load mood analytics');
    }
  }
  
  // Dashboard endpoint
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard');
    }
  }
  
  // Profile endpoints
  static Future<Map<String, dynamic>?> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['profile'];
    } else {
      throw Exception('Failed to load profile');
    }
  }
  
  static Future<Map<String, dynamic>> updateProfile({
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
    required String healthGoals,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile'),
      headers: await getHeaders(),
      body: jsonEncode({
        'age': age,
        'weight': weight,
        'height': height,
        'gender': gender,
        'activity_level': activityLevel,
        'health_goals': healthGoals,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Failed to update profile');
    }
  }
  
  // Medical records endpoints (file upload uses multipart - handled in screen)
  static Future<List<dynamic>> getMedicalRecords() async {
    final response = await http.get(
      Uri.parse('$baseUrl/records'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['records'] ?? [];
    } else {
      throw Exception('Failed to load medical records');
    }
  }
  
  static Future<void> deleteMedicalRecord(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/records/$id'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete medical record');
    }
  }
  
  // Notifications endpoints
  static Future<List<dynamic>> getNotifications({bool unreadOnly = false, int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications?unread=${unreadOnly ? 'true' : 'false'}&limit=$limit'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['notifications'] ?? [];
    } else {
      throw Exception('Failed to load notifications');
    }
  }
  
  static Future<int> getUnreadNotificationCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread/count'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['unread_count'] ?? 0;
    } else {
      throw Exception('Failed to load notification count');
    }
  }
  
  static Future<void> markNotificationRead(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$id/read'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
  
  static Future<void> markAllNotificationsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }
  
  static Future<Map<String, dynamic>> generateInsights() async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/generate'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate insights');
    }
  }
  
  // Diet recommendations
  static Future<Map<String, dynamic>> getDietRecommendations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/diet/recommendations'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get diet recommendations');
    }
  }
  
  // Water predictions
  static Future<Map<String, dynamic>> getWaterPrediction() async {
    final response = await http.get(
      Uri.parse('$baseUrl/water/prediction/next-reminder'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get water prediction');
    }
  }
  
  static Future<Map<String, dynamic>> getWaterSchedule() async {
    final response = await http.get(
      Uri.parse('$baseUrl/water/schedule'),
      headers: await getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get water schedule');
    }
  }
}

