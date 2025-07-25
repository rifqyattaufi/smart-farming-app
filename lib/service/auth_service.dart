import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:smart_farming_app/main.dart';
import 'package:smart_farming_app/service/database_helper.dart';

class AuthService {
  final String baseUrl = dotenv.env['AUTH_BASE_URL'] ?? '';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        await _secureStorage.write(key: 'token', value: body['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: body['refreshToken']);
        await _secureStorage.write(
            key: 'user', value: json.encode(body['data']));

        await fcmService.getTokenAndSendToServer();

        return body;
      } else {
        final body = json.decode(response.body);
        return {
          'status': false,
          'message': body['message'] ?? 'Login failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteAllNotifications();
    await fcmService.deleteToken();
    await _secureStorage.deleteAll();
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final user = await _secureStorage.read(key: 'user');
    if (user != null) {
      return json.decode(user);
    }
    return null;
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    final url = Uri.parse('$baseUrl/auth/refresh');

    if (refreshToken == null) {
      return false;
    }

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'bearer $refreshToken'});

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        await _secureStorage.deleteAll();
        await _secureStorage.write(key: 'token', value: body['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: body['refreshToken']);
        await _secureStorage.write(
            key: 'user', value: json.encode(body['data']));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserRole() async {
    final user = await getUser();
    return user?['role'];
  }

  Future<Map<String, dynamic>> updateFcm(String token) async {
    final resolvedToken = await getToken();
    if (resolvedToken == null) {
      return {
        'status': false,
        'message': 'User not authenticated',
      };
    }

    final url = Uri.parse('$baseUrl/auth/fcmToken');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resolvedToken',
        },
        body: json.encode({'fcmToken': token}),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'FCM token updated successfully',
        };
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to update FCM token',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': body['message'] ?? 'Registration successful',
          'data': body['data'],
        };
      } else {
        return {
          'status': false,
          'message':
              body['message'] ?? 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> lupaPassword(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/auth/forgotPassword');
    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'Password reset link sent successfully',
        };
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to send password reset link',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/auth/resendOtp');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'OTP resent successfully',
        };
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> checkOtp(Map<String, dynamic> data) {
    final url = "$baseUrl/auth/checkOtp";

    try {
      return http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      )
          .then((response) {
        final body = json.decode(response.body);
        if (response.statusCode == 200) {
          return {
            'status': true,
            'message': body['message'] ?? 'OTP verified successfully',
          };
        } else {
          return {
            'status': false,
            'message': body['message'] ?? 'Failed to verify OTP',
          };
        }
      });
    } catch (e) {
      return Future.value({
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      });
    }
  }

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/auth/resetPassword');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to reset password',
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
