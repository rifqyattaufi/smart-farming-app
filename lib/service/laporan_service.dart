import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class LaporanService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/laporan';

  Future<Map<String, dynamic>> createLaporanHarianTernak(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$baseUrl/harian-ternak');

    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createLaporanHarianTernak(data);
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

  Future<Map<String, dynamic>> createLaporanPanen(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$baseUrl/panen');

    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createLaporanPanen(data);
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

  Future<Map<String, dynamic>> createLaporanSakit(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$baseUrl/sakit');
    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createLaporanSakit(data);
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

  Future<Map<String, dynamic>> createLaporanKematian(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$baseUrl/kematian');

    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      final body = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createLaporanKematian(data);
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
