import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'auth_service.dart';

class OrderService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        body['success'] == true) {
      return body;
    }

    throw Exception(body['message'] ?? 'Terjadi kesalahan pada pesanan.');
  }

  static Future<Map<String, dynamic>> checkout({
    required String recipientName,
    required String recipientPhone,
    required String shippingAddress,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.checkout),
      headers: await _headers(),
      body: jsonEncode({
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'shipping_address': shippingAddress,
        'notes': notes,
      }),
    );

    final result = _parseResponse(response);
    return Map<String, dynamic>.from(result['data']);
  }

  static Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await http.get(
      Uri.parse(ApiConfig.myOrders),
      headers: await _headers(),
    );

    final result = _parseResponse(response);
    final data = result['data'];

    if (data is! List) {
      throw Exception('Format data riwayat pesanan tidak valid.');
    }

    return data.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<Map<String, dynamic>> getOrderDetail(dynamic orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.myOrders}/$orderId'),
      headers: await _headers(),
    );

    final result = _parseResponse(response);
    return Map<String, dynamic>.from(result['data']);
  }
}
