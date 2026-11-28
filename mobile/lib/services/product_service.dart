import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/core/api_config.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class ProductService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi pengguna tidak ditemukan. Silakan login kembali.');
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parseResponse(String body) {
    final decoded = jsonDecode(body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Format response server tidak valid.');
    }

    return decoded;
  }

  static Future<Map<String, dynamic>> getProducts({
    String? search,
    int? categoryId,
    int? companyId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 10,
    String sortBy = 'created_at',
    String order = 'desc',
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'order': order,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (categoryId != null) {
      queryParameters['category_id'] = categoryId.toString();
    }

    if (companyId != null) {
      queryParameters['company_id'] = companyId.toString();
    }

    if (minPrice != null) {
      queryParameters['min_price'] = minPrice.toString();
    }

    if (maxPrice != null) {
      queryParameters['max_price'] = maxPrice.toString();
    }

    final uri = Uri.parse(ApiConfig.products)
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri);
    final responseData = _parseResponse(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return {
        'products': List<Map<String, dynamic>>.from(
          responseData['data'] ?? [],
        ),
        'pagination': responseData['pagination'],
      };
    }

    throw Exception(
      responseData['message'] ?? 'Gagal mengambil produk.',
    );
  }

  static Future<Map<String, dynamic>> getAdminProducts({
    String? search,
    String status = 'all',
    int? categoryId,
    int page = 1,
    int limit = 10,
    String sortBy = 'created_at',
    String order = 'desc',
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort_by': sortBy,
      'order': order,
      'status': status,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (categoryId != null) {
      queryParameters['category_id'] = categoryId.toString();
    }

    final uri = Uri.parse('${ApiConfig.products}/admin')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: await _authHeaders(),
    );

    final responseData = _parseResponse(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return {
        'products': List<Map<String, dynamic>>.from(
          responseData['data'] ?? [],
        ),
        'pagination': responseData['pagination'],
      };
    }

    throw Exception(
      responseData['message'] ?? 'Gagal mengambil produk Admin.',
    );
  }

  static Future<Map<String, dynamic>> getProductById(int id) async {
    final uri = Uri.parse('${ApiConfig.products}/$id');

    final response = await http.get(uri);
    final responseData = _parseResponse(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Gagal mengambil detail produk.',
    );
  }

  static Future<Map<String, dynamic>> createProduct({
    required Map<String, dynamic> productData,
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.products),
    );

    request.headers.addAll(await _authHeaders());

    productData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (image != null) {
      final extension = image.path.split('.').last.toLowerCase();

      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'webp' => MediaType('image', 'webp'),
        _ => throw Exception('Format gambar belum didukung: .$extension'),
      };

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: mimeType,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = _parseResponse(response.body);

    if (response.statusCode == 201 &&
        responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Gagal menambahkan produk.',
    );
  }

  static Future<Map<String, dynamic>> updateProduct({
    required int id,
    required Map<String, dynamic> productData,
    File? image,
  }) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.products}/$id'),
    );

    request.headers.addAll(await _authHeaders());

    productData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (image != null) {
      final extension = image.path.split('.').last.toLowerCase();

      final mimeType = switch (extension) {
        'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
        'png' => MediaType('image', 'png'),
        'webp' => MediaType('image', 'webp'),
        _ => throw Exception('Format gambar belum didukung: .$extension'),
      };

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: mimeType,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = _parseResponse(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Gagal memperbarui produk.',
    );
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.products}/$id'),
      headers: await _authHeaders(),
    );

    final responseData = _parseResponse(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return;
    }

    throw Exception(
      responseData['message'] ?? 'Gagal menghapus produk.',
    );
  }
}
