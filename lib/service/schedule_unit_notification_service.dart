import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class ScheduleUnitNotificationService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL']}/scheduledUnitNotification';

  Future<Map<String, dynamic>> getScheduleUnitNotificationByUnitBudidaya(
      String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/unitBudidaya/$id');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'status': true,
          'message': 'Data not found',
          'data': [],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getScheduleUnitNotificationByUnitBudidaya(id);
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
}
