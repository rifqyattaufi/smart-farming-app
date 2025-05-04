import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class KomoditasService {
  AuthService _authService = AuthService();

  String baseUrl = '${dotenv.env['BASE_URL']}/komoditas';

  Future<Map<String, dynamic>> getKomoditas() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getKomoditas();
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

  Future<Map<String, dynamic>> getKomoditasById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.get(url, headers: headers);

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getKomoditasById(id);
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

  Future<Map<String, dynamic>> getKomoditasByTipe(String tipe) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/tipe/$tipe');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getKomoditasByTipe(tipe);
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

  Future<Map<String, dynamic>> getKomoditasSearch(
      String query, String tipe) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/search/$tipe?query=$query');

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
        return await getKomoditasSearch(query, tipe);
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

  Future<Map<String, dynamic>> createKomoditas(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse(baseUrl);

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
        return await createKomoditas(data);
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
