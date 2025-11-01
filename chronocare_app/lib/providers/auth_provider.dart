import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentUser;
  
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentUser => _currentUser;
  
  // Check if user is already logged in
  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    _isAuthenticated = token != null;
    notifyListeners();
  }
  
  // Login
  Future<void> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      _currentUser = response['user'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Register
  Future<void> register(String email, String password, String? name) async {
    try {
      final response = await ApiService.register(email, password, name);
      _currentUser = response['user'];
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Logout
  Future<void> logout() async {
    await ApiService.removeToken();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}

