import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/core/api_config.dart';

class CompanyService {
  static Future<List<Map<String, dynamic>>> getCompanies() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.companies));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> companies = responseData['data'];

        return companies
            .map((company) => Map<String, dynamic>.from(company))
            .toList();
      }

      throw Exception(
        responseData['message'] ?? 'Gagal mengambil data perusahaan.',
      );
    } catch (error) {
      throw Exception('Gagal mengambil data perusahaan: $error');
    }
  }

  static Future<Map<String, dynamic>> getCompanyById(int id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.companies}/$id'));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return Map<String, dynamic>.from(responseData['data']);
      }

      throw Exception(
        responseData['message'] ?? 'Gagal mengambil detail perusahaan.',
      );
    } catch (error) {
      throw Exception('Gagal mengambil detail perusahaan: $error');
    }
  }
}
