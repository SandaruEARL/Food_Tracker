import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/order.dart';
import '../utils/constant.dart';


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
  Future<User?> register(String name, String email, String password, String type) async {
    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // ORDER APIS
  Future<List<Order>> getRelevantOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/order/getrelavant'),
        headers: await _getHeaders(requireAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get orders error: $e');
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
      print('Get restaurant orders error: $e');
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
      print('Get driver orders error: $e');
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

      return response.statusCode == 200;
    } catch (e) {
      print('Place order error: $e');
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
      print('Update order status error: $e');
      return false;
    }
  }
}