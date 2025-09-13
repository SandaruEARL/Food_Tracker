import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  // Get auth token from storage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save token to storage
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Auth headers
  Future<Map<String, String>> _getHeaders({bool requireAuth = false}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // AUTHENTICATION APIS
  Future<Map<String, dynamic>> register(String name, String email, String password, String type) async {
    try {
      if (kDebugMode) {
        print('Attempting registration with URL: $baseUrl/api/auth/register');
        print('Registration data: name=$name, email=$email, type=$type');
      }


      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'type': type,
        }),
      );

      if (kDebugMode) {
        print('Registration response body: ${response.body}');
        print('Registration response status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true,
          'user': User.fromJson(data),
          'message': 'Registration successful'
        };
      } else {
        // Handle different error status codes
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Registration failed';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }

        return {
          'success': false,
          'user': null,
          'message': errorMessage
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Register error: $e');
      }
      return {
        'success': false,
        'user': null,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting login with URL: $baseUrl/api/auth/login');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (kDebugMode) {
        print('Login response status: ${response.statusCode}');
        print('Login response body: ${response.body}');

      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {
          'success': true,
          'user': User.fromJson(data),
          'message': 'Login successful'
        };
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Login failed';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          errorMessage = errorData['error'];
        }

        return {
          'success': false,
          'user': null,
          'message': errorMessage
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return {
        'success': false,
        'user': null,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // ORDER APIS (keeping them unchanged for now)
  Future<List<Order>> getRelevantOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/getrelavant'),
        headers: await _getHeaders(requireAuth: true),
      );
      if (kDebugMode) {
        print('Get orders response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Get orders error: $e');
      }
      return [];
    }
  }

  Future<List<Order>> getAvailableOrdersRestaurant() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/available/restaurant'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Get restaurant orders error: $e');
      }
      return [];
    }
  }

  Future<List<Order>> getAvailableOrdersDriver() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/available/driver'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Get driver orders error: $e');
      }
      return [];
    }
  }

  Future<bool> placeOrder(String description, double lat, double lng, String address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/order/place'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({
          'description': description,
          'customerLocation': {
            'lat': lat,
            'lng': lng,
            'address': address,
          }
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Place order error: $e');
      }
      return false;
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/order/$orderId/changestatus'),
        headers: await _getHeaders(requireAuth: true),
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Update order status error: $e');
      }
      return false;
    }
  }
}