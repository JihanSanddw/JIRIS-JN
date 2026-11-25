import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/core/api_config.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:http_parser/http_parser.dart';

class CategoryService {
  // GET ALL CATEGORIES
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final uri = Uri.parse(ApiConfig.categories);
    final response = await http.get(uri);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return List<Map<String, dynamic>>.from(responseData['data']);
    }

    throw Exception(responseData['message'] ?? 'Gagal mengambil kategori.');
  }

  static Future<Map<String, dynamic>> getCategoryById(int id) async {
    final uri = Uri.parse('${ApiConfig.categories}/$id');
    final response = await http.get(uri);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(
      responseData['message'] ?? 'Gagal mengambil detail kategori.',
    );
  }

  static Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
    File? image,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token admin tidak ditemukan.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConfig.categories),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;

    if (description != null && description.trim().isNotEmpty) {
      request.fields['description'] = description.trim();
    }

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
    final responseData = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(responseData['message'] ?? 'Gagal menambahkan kategori.');
  }

  static Future<Map<String, dynamic>> updateCategory({
    required int id,
    required String name,
    String? description,
    File? image,
  }) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token admin tidak ditemukan.');
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${ApiConfig.categories}/$id'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;

    if (description != null) {
      request.fields['description'] = description;
    }

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
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return Map<String, dynamic>.from(responseData['data']);
    }

    throw Exception(responseData['message'] ?? 'Gagal memperbarui kategori.');
  }

  static Future<void> deleteCategory(int id) async {
    final token = await AuthService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token admin tidak ditemukan.');
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.categories}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return;
    }

    throw Exception(responseData['message'] ?? 'Gagal menghapus kategori.');
  }
}
