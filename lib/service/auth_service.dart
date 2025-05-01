import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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
}
