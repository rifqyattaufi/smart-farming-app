import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class ObjekBudidayaService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/objek-budidaya';

  Future<Map<String, dynamic>> getObjekBudidayaByUnitBudidaya(
      String unitBudidayaId) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/unit-budidaya/$unitBudidayaId');

    try {
      final response = await http.get(url, headers: headers);
      final body = response.body;

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': json.decode(body)['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getObjekBudidayaByUnitBudidaya(unitBudidayaId);
      } else {
        return {
          'status': false,
          'message': body,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createObjekBudidaya(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      final body = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
          'data': json.decode(body)['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createObjekBudidaya(data);
      } else {
        return {
          'status': false,
          'message':
              json.decode(body)['message'] ?? 'Failed to create objek budidaya',
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
