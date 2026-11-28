import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/api_config.dart';
import 'package:mobile/services/auth_service.dart';

class CartService {
  // HEADER AUTHENTICATION
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi pengguna tidak ditemukan.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final responseData = jsonDecode(response.body);

    if (responseData is! Map<String, dynamic>) {
      throw Exception('Format respons server tidak valid.');
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        responseData['success'] == true) {
      return responseData;
    }

    throw Exception(
      responseData['message'] ?? 'Terjadi kesalahan pada keranjang.',
    );
  }

  static Future<Map<String, dynamic>> getCart() async {
    final response = await http.get(
      Uri.parse(ApiConfig.cart),
      headers: await _headers(),
    );

    final responseData = _parseResponse(response);

    return Map<String, dynamic>.from(responseData['data']);
  }

  static Future<Map<String, dynamic>> addCartItem({
    required int productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.cart}/items'),
      headers: await _headers(),
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );

    final responseData = _parseResponse(response);

    return Map<String, dynamic>.from(responseData['data']);
  }

  static Future<Map<String, dynamic>> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.cart}/items/$cartItemId'),
      headers: await _headers(),
      body: jsonEncode({'quantity': quantity}),
    );

    final responseData = _parseResponse(response);

    return Map<String, dynamic>.from(responseData['data']);
  }

  static Future<void> deleteCartItem({required int cartItemId}) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.cart}/items/$cartItemId'),
      headers: await _headers(),
    );

    _parseResponse(response);
  }
}
