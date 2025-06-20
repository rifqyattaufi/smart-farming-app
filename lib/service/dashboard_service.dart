import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farming_app/service/auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/dashboard';

  Future<Map<String, dynamic>> getDashboardPerkebunan() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/perkebunan');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await getDashboardPerkebunan();
    } else {
      throw Exception(
          'Failed to load dashboard perkebunan data ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDashboardPeternakan() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/peternakan');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await getDashboardPeternakan();
    } else {
      throw Exception('Failed to load dashboard peternakan data');
    }
  }

  Future<Map<String, dynamic>> riwayatAktivitasAll(
      {int page = 1, int limit = 20}) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final url = Uri.parse('$baseUrl/riwayat-aktivitas?page=$page&limit=$limit');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      return body as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await riwayatAktivitasAll(page: page, limit: limit);
    } else {
      final body = json.decode(response.body);
      throw Exception(
          'Failed to load riwayat aktivitas data: ${body['message'] ?? response.reasonPhrase}');
    }
  }
}
