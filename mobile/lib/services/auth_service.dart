import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile/core/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiConfig.login);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final data = responseData['data'];
      final token = data['token'];
      final user = data['user'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('auth_token', token);
      await prefs.setString('user_data', jsonEncode(user));

      return data;
    }

    throw Exception(responseData['message'] ?? 'Login gagal.');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(ApiConfig.register);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201 && responseData['success'] == true) {
      return responseData['data'];
    }

    throw Exception(responseData['message'] ?? 'Registrasi gagal.');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi pengguna tidak ditemukan.');
    }

    final response = await http.get(
      Uri.parse(ApiConfig.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      return responseData['data']['user'];
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      await logout();
    }

    throw Exception(responseData['message'] ?? 'Gagal mengambil profil.');
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String name,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi pengguna tidak ditemukan.');
    }

    final response = await http.put(
      Uri.parse(ApiConfig.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name.trim()}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final prefs = await SharedPreferences.getInstance();

      final updatedUser = responseData['data']?['user'];

      if (updatedUser != null) {
        await prefs.setString('user_data', jsonEncode(updatedUser));
        return Map<String, dynamic>.from(updatedUser);
      }

      return {'name': name.trim()};
    }

    throw Exception(responseData['message'] ?? 'Gagal memperbarui profil.');
  }

  static Future<Map<String, dynamic>> updateProfileImage({
    required File image,
    required bool isBanner,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi pengguna tidak ditemukan.');
    }

    final endpoint = isBanner
        ? '${ApiConfig.profile}/banner'
        : '${ApiConfig.profile}/image';

    final request = http.MultipartRequest('PUT', Uri.parse(endpoint));

    request.headers['Authorization'] = 'Bearer $token';

    final extension = image.path.split('.').last.toLowerCase();

    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => throw Exception('Format gambar harus JPG, PNG, atau WEBP.'),
    };

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: mimeType,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final updatedUser = responseData['data']['user'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_data', jsonEncode(updatedUser));

      return Map<String, dynamic>.from(updatedUser);
    }

    throw Exception(responseData['message'] ?? 'Gagal mengunggah gambar.');
  }

  static Future<Map<String, dynamic>> removeProfileImage() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Sesi pengguna tidak ditemukan.');
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.profile}/image'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      final updatedUser = responseData['data']['user'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_data', jsonEncode(updatedUser));

      return Map<String, dynamic>.from(updatedUser);
    }

    throw Exception(responseData['message'] ?? 'Gagal menghapus foto profil.');
  }
}
