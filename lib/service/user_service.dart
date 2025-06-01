import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  final AuthService _authService = AuthService();
  final String _baseUrl =
      dotenv.env['AUTH_BASE_URL'] ?? 'http://localhost:8000/api';

  Future<Map<String, dynamic>> getUserGroupByRole() async {
    final resolvedToken = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/byRole'),
        headers: {
          'Authorization': 'Bearer $resolvedToken',
        },
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'Data not found',
          'data': [],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getUserGroupByRole();
      } else {
        return {
          'status': false,
          'message': body.isNotEmpty ? body : 'Failed to load user data',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
        'data': [],
      };
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    final resolvedToken = await _authService.getToken();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user/id/$id'),
        headers: {
          'Authorization': 'Bearer $resolvedToken',
        },
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'User not found',
          'data': {},
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getUserById(id);
      } else {
        return {
          'status': false,
          'message': body.isNotEmpty ? body : 'Failed to load user data',
          'data': {},
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
        'data': {},
      };
    }
  }

  Future<Map<String, dynamic>> deactivateUser(String id) async {
    final resolvedToken = await _authService.getToken();
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/user/deactivate/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'User deactivated successfully',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'User not found',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await deactivateUser(id);
      } else {
        return {
          'status': false,
          'message': body.isNotEmpty ? body : 'Failed to deactivate user',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> activateUser(String id) async {
    final resolvedToken = await _authService.getToken();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/activate/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'User activated successfully',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'User not found',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await activateUser(id);
      } else {
        return {
          'status': false,
          'message': body.isNotEmpty ? body : 'Failed to activate user',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: json.encode(data),
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'User updated successfully',
          'data': body['data'],
        };
      } else if (response.statusCode == 404) {
        return {
          'status': false,
          'message': 'User not found',
          'data': {},
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateUser(id, data);
      } else {
        return {
          'status': false,
          'message': body.isNotEmpty ? body : 'Failed to update user',
          'data': {},
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': e.toString(),
        'data': {},
      };
    }
  }
}
