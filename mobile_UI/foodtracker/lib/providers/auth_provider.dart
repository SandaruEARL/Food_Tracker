import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/web_socket_service.dart';


class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();
  final WebSocketService _webSocketService = WebSocketService();

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  WebSocketService get webSocketService => _webSocketService;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    _setLoading(true);

    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      _user = User.fromJson(jsonDecode(userData));
      await _webSocketService.connect(_user!);
    }

    _setLoading(false);
  }

  // Register
  Future<bool> register(String name, String email, String password, String type) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.register(name, email, password, type);
      if (user != null) {
        await _setUser(user);
        return true;
      } else {
        _setError('Registration failed. Please try again.');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.login(email, password);
      if (user != null) {
        await _setUser(user);
        return true;
      } else {
        _setError('Invalid email or password.');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    await _apiService.logout();
    _webSocketService.disconnect();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');

    _user = null;
    _clearError();
    _setLoading(false);
  }

  // Private helper methods
  Future<void> _setUser(User user) async {
    _user = user;

    // Save user data to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(user.toJson()));

    // Connect to WebSocket
    await _webSocketService.connect(user);

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}