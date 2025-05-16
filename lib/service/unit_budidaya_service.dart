import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class UnitBudidayaService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/unit-budidaya';

  Future<Map<String, dynamic>> getUnitBudidaya() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse(baseUrl);

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
        return await getUnitBudidaya();
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

  Future<Map<String, dynamic>> getUnitBudidayaById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getUnitBudidayaById(id);
      } else {
        final body = response.body;
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

  Future<Map<String, dynamic>> getUnitBudidayaSearch(
      String search, String tipe) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/search/$search/$tipe');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
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
        return await getUnitBudidayaSearch(search, tipe);
      } else {
        final body = response.body;
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

  Future<Map<String, dynamic>> getUnitBudidayaByTipe(String tipe) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/tipe/$tipe');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getUnitBudidayaByTipe(tipe);
      } else {
        final body = response.body;
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

  Future<Map<String, dynamic>> getUnitBudidayaByJenisBudidaya(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/jenis-budidaya/$id');
    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getUnitBudidayaByJenisBudidaya(id);
      } else {
        final body = response.body;
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

  Future<Map<String, dynamic>> createUnitBudidaya(
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

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createUnitBudidaya(data);
      } else {
        final body = response.body;
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

  Future<Map<String, dynamic>> updateUnitBudidaya(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$baseUrl/${data['id']}');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateUnitBudidaya(data);
      } else {
        final body = response.body;
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

  Future<Map<String, dynamic>> deleteUnitBudidaya(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await deleteUnitBudidaya(id);
      } else {
        final body = response.body;
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
