import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class KomoditasService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL']}/komoditas';

  Future<Map<String, dynamic>> getKomoditas({
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl?page=$page&limit=$limit');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data'] ?? [],
          'totalPages': body['totalPages'] ?? 0,
          'currentPage': body['currentPage'] ?? page,
          'totalItems': body['totalItems'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();

        return await getKomoditas(page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load data',
          'data': [],
          'totalPages': 0,
          'currentPage': page,
          'totalItems': 0,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
        'data': [],
        'totalPages': 0,
        'currentPage': page,
        'totalItems': 0,
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
          'message': body['message'] ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getKomoditasById(id);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load data by ID',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getKomoditasByTipe(
    String tipe, {
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final url = Uri.parse('$baseUrl/tipe/$tipe?page=$page&limit=$limit');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data'] ?? [],
          'totalPages': body['totalPages'] ?? 0,
          'currentPage': body['currentPage'] ?? page,
          'totalItems': body['totalItems'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getKomoditasByTipe(tipe, page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load data by tipe',
          'data': [],
          'totalPages': 0,
          'currentPage': page,
          'totalItems': 0,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
        'data': [],
        'totalPages': 0,
        'currentPage': page,
        'totalItems': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getKomoditasSearch(
    String query,
    String tipe, {
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final encodedQuery = Uri.encodeComponent(query);
    final encodedTipe = Uri.encodeComponent(tipe);
    final url = Uri.parse(
        '$baseUrl/search/$encodedQuery/$encodedTipe?page=$page&limit=$limit');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data'] ?? [],
          'totalPages': body['totalPages'] ?? 0,
          'currentPage': body['currentPage'] ?? page,
          'totalItems': body['totalItems'] ?? 0,
        };
      } else if (response.statusCode == 404) {
        return {
          'status': true,
          'message': body['message'] ?? 'Data not found',
          'data': [],
          'totalPages': 0,
          'currentPage': page,
          'totalItems': 0,
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getKomoditasSearch(query, tipe, page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to search data',
          'data': [],
          'totalPages': 0,
          'currentPage': page,
          'totalItems': 0,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
        'data': [],
        'totalPages': 0,
        'currentPage': page,
        'totalItems': 0,
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
          'message': body['message'] ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createKomoditas(data);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to create data',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateKomoditas(
      Map<String, dynamic> data, String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$baseUrl/$id');

    try {
      final response =
          await http.put(url, headers: headers, body: json.encode(data));
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateKomoditas(data, id);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to update data'),
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteKomoditas(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.delete(url, headers: headers);

      Map<String, dynamic>? body;
      if (response.body.isNotEmpty) {
        body = json.decode(response.body);
      }

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body?['message'] ?? 'success',
          'data': body?['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await deleteKomoditas(id);
      } else {
        return {
          'status': false,
          'message': body?['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to delete data'),
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
