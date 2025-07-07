import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class SatuanService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL']}/satuan';

  Future<Map<String, dynamic>> getSatuan({
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
      queryParams['lambang'] = searchQuery;
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
        return await getSatuan(
            page: page, limit: limit, searchQuery: searchQuery);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load satuan'),
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

  Future<Map<String, dynamic>> getSatuanById(String id) async {
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
        return await getSatuanById(id);
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

  Future<Map<String, dynamic>> getSatuanSearch(
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
        return await getSatuanSearch(query, page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to search satuan'),
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

  Future<Map<String, dynamic>> createSatuan(Map<String, dynamic> data) async {
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
        return await createSatuan(data);
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

  Future<Map<String, dynamic>> updateSatuan(
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
        return await updateSatuan(id, data);
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

  Future<Map<String, dynamic>> deleteSatuan(String id) async {
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
        return await deleteSatuan(id);
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
