import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class GlobalNotificationService {
  final AuthService _authService = AuthService();

  final String _baseUrl = '${dotenv.env['BASE_URL']}/globalNotification';

  Future<Map<String, dynamic>> getGlobalNotifications() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse(_baseUrl);

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
        return await getGlobalNotifications();
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

  Future<Map<String, dynamic>> getGlobalNotificationsById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_baseUrl/$id');

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
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getGlobalNotificationsById(id);
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

  Future<Map<String, dynamic>> createGLobalNotification(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse(_baseUrl);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': 'Notification created successfully',
          'data': json.decode(response.body)['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createGLobalNotification(data);
      } else {
        return {
          'status': false,
          'message': json.decode(response.body),
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateGlobalNotification(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$_baseUrl/${data['id']}');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'Notification updated successfully',
          'data': json.decode(response.body)['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateGlobalNotification(data);
      } else {
        return {
          'status': false,
          'message': json.decode(response.body),
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteGlobalNotification(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'Notification deleted successfully',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await deleteGlobalNotification(id);
      } else {
        return {
          'status': false,
          'message': json.decode(response.body),
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
