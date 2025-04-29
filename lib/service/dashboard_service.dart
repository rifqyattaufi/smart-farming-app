import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farming_app/service/auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  late final Future<String?> token;

  DashboardService() {
    token = _authService.getToken();
  }

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/dashboard';

  Future<Map<String, dynamic>> getDashboardPerkebunan() async {
    final resolvedToken = await token;
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/perkebunan');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else {
      throw Exception(
          'Failed to load dashboard perkebunan data ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDashboardPeternakan() async {
    final resolvedToken = await token;
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/peternakan');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else {
      throw Exception('Failed to load dashboard peternakan data');
    }
  }
}
