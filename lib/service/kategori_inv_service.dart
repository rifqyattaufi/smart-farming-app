import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class KategoriInvService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL']}/kategori-inventaris';

  Future<Map<String, dynamic>> getKategoriInventaris({
    int page = 1,
    int limit = 20,
    String? searchQuery,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams['nama'] = searchQuery;
    }

    final url = Uri.parse(baseUrl).replace(queryParameters: queryParams);

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
        return await getKategoriInventaris(
            page: page, limit: limit, searchQuery: searchQuery);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load kategori'),
          'data': [],
          'totalPages': 0,
          'currentPage': page,
          'totalItems': 0,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
        'totalPages': 0,
        'currentPage': page,
        'totalItems': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getKategoriInventarisOnly() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/only');

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
        return await getKategoriInventarisOnly();
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

  Future<Map<String, dynamic>> getKategoriInventarisById(String id) async {
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
        return await getKategoriInventarisById(id);
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

  Future<Map<String, dynamic>> getKategoriInventarisSearch(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final encodedQuery = Uri.encodeComponent(query);

    final Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final url = Uri.parse('$baseUrl/search/$encodedQuery')
        .replace(queryParameters: queryParams);

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
        return await getKategoriInventarisSearch(query,
            page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to search kategori'),
          'data': [],
          'totalPages': 0,
          'currentPage': page,
          'totalItems': 0,
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
        'totalPages': 0,
        'currentPage': page,
        'totalItems': 0,
      };
    }
  }

  Future<Map<String, dynamic>> createKategoriInventaris(
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
      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': 'success',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createKategoriInventaris(data);
      } else if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
        };
      } else if (response.statusCode == 400) {
        return {
          'status': false,
          'message': responseData['message'],
        };
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

  Future<Map<String, dynamic>> updateKategoriInventaris(
      String id, Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response =
          await http.put(url, headers: headers, body: json.encode(data));

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': 'success',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateKategoriInventaris(id, data);
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

  Future<Map<String, dynamic>> deleteKategoriInventaris(String id) async {
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
        return await deleteKategoriInventaris(id);
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
