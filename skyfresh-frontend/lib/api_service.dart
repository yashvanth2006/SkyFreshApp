import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyfresh/models/user_profile.dart';

class ApiService {
<<<<<<< ai
  static const String baseUrl = "http://localhost:5000/api";

  // ── REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await http.post(
=======
  static const String baseUrl = 'http://10.17.145.53:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Google login connection failed'};
    }
  }

  static Future<Map<String, dynamic>> login({String? phone, String? password}) async {
    try {
      print('Attempting login to: $baseUrl/auth/login');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone ?? '', 'password': password ?? ''}),
      );
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', data['token']);
      }
      return data;
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Login connection failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> registerUser(String name, String phone, String password) async {
    try {
      final response = await http.post(
>>>>>>> local
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'phone': phone, 'password': password}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userPhone', data['user']['phone']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── RESEND OTP
  static Future<Map<String, dynamic>> resendOtp({
    required String phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── LOGIN
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userName', data['user']['name']);
        await prefs.setString('userPhone', data['user']['phone']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── GET PRODUCTS
  static Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['products']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── PLACE ORDER
  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required int subtotal,
    required int deliveryFee,
    required int total,
    required String address,
    String? paymentMethod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Please log in again.'};
      }

      final res = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'subtotal': subtotal,
          'deliveryFee': deliveryFee,
          'total': total,
          'address': address,
          if (paymentMethod != null) 'paymentMethod': paymentMethod,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── GET MY ORDERS
  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return [];

      final res = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['orders']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── GET PROFILE
  static Future<UserProfile?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return null;

      final res = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['user'] != null) {
        final profile = UserProfile.fromJson(Map<String, dynamic>.from(data['user']));
        await prefs.setString('userName', profile.name);
        await prefs.setString('userPhone', profile.phone);
        return profile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── ADD ADDRESS
  static Future<Map<String, dynamic>> addAddress({
    required String line,
    String label = 'Home',
    bool isDefault = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Please log in again.'};
      }

      final res = await http.post(
        Uri.parse('$baseUrl/auth/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'label': label, 'line': line, 'isDefault': isDefault}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── DELETE ADDRESS
  static Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Please log in again.'};
      }

      final res = await http.delete(
        Uri.parse('$baseUrl/auth/addresses/$addressId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── SET DEFAULT ADDRESS
  static Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Please log in again.'};
      }

      final res = await http.patch(
        Uri.parse('$baseUrl/auth/addresses/$addressId/default'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── CHECK SERVICEABILITY
  static Future<Map<String, dynamic>> checkServiceability({
    required double lat,
    required double lng,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/serviceability/check?lat=$lat&lng=$lng'),
        headers: {'Content-Type': 'application/json'},
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'serviceable': false, 'message': 'Cannot connect to server.'};
    }
  }

  // ── LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── CHECK IF LOGGED IN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
}
