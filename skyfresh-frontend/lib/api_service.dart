import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyfresh/models/user_profile.dart';

class ApiService {
  static const String baseUrl = kIsWeb 
    ? 'http://localhost:5000/api' 
    : 'http://10.191.134.53:5000/api';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to send OTP'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', data['token']);
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Verification connection failed'};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
  }

  static Future<UserProfile?> getProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return UserProfile.fromJson(data['user'] ?? data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // UPDATED: Now accepts optional search and category parameters
  static Future<List<dynamic>> getProducts({String? search, String? category}) async {
    try {
      Map<String, String> queryParams = {};
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }

      String queryString = Uri(queryParameters: queryParams).query;
      String url = '$baseUrl/products';
      if (queryString.isNotEmpty) {
        url += '?$queryString'; 
      }

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      
      // Handle array response directly
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['orders'] != null) {
        return List<Map<String, dynamic>>.from(data['orders']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // FIXED: Added "String? line" to the parameters and the fallback map!
  static Future<Map<String, dynamic>> addAddress({
    Map<String, dynamic>? addressData,
    String? address,
    String? addressLine,
    String? line, 
    String? title,
    String? label, 
    String? name,
    String? landmark,
    bool? isDefault,
  }) async {
    try {
      final token = await getToken();
      final Map<String, dynamic> finalBody = addressData ?? {
        'label': label ?? title ?? 'Home',
        'line': line ?? address ?? addressLine ?? '',
        'isDefault': isDefault,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/addresses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(finalBody),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to add address'};
    }
  }

  static Future<Map<String, dynamic>> setDefaultAddress(String addressId) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/addresses/$addressId/default'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to set default address'};
    }
  }

  static Future<Map<String, dynamic>> deleteAddress(String addressId) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/addresses/$addressId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete address'};
    }
  }

  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    required num subtotal,
    required num deliveryCharge,
    required num totalAmount,
    required String shippingAddress,
    String? paymentMethod, 
  }) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'items': items,
          'subtotal': subtotal,
          'deliveryCharge': deliveryCharge,
          'totalAmount': totalAmount,
          'shippingAddress': shippingAddress,
          'paymentMethod': paymentMethod ?? 'Cash on Delivery',
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Order placement failed'};
    }
  }

  static Future<Map<String, dynamic>> askNutritionist(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'recommendedProducts': data['recommendedProducts'] ?? [],
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to get recommendations'};
    } catch (e) {
      print('Error asking nutritionist: $e');
      return {'success': false, 'message': 'Connection failed'};
    }
  }
}
