import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/report';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getStatistikHarianJenisBudidaya(
      String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final url = Uri.parse('$baseUrl/statistik-harian-kebun/$id');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] as String? ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getStatistikHarianJenisBudidaya(id);
      } else {
        return {
          'status': false,
          'message': body['message'] as String? ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load data by ID'),
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }
}
