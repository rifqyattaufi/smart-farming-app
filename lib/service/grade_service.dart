import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class GradeService {
  final AuthService _authService = AuthService();
  final String _baseUrl = '${dotenv.env['BASE_URL']}/grade';

  Future<Map<String, dynamic>> getPagedGrades({
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

    final url = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

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
        return await getPagedGrades(
            page: page, limit: limit, searchQuery: searchQuery);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load grades'),
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

  Future<Map<String, dynamic>> getGradeById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_baseUrl/$id');
    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data']
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getGradeById(id);
      } else {
        return {'status': false, 'message': body['message'] ?? response.body};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createGrade(Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse(_baseUrl);
    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      final responseData = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'status': true,
          'message': responseData['message'] ?? 'success',
          'data': responseData['data']
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createGrade(data);
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? response.body
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateGrade(
      String id, Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$_baseUrl/$id');
    try {
      final response =
          await http.put(url, headers: headers, body: json.encode(data));
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': responseData['message'] ?? 'success',
          'data': responseData['data']
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateGrade(id, data);
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? response.body
        };
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteGrade(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_baseUrl/$id');
    try {
      final response = await http.delete(url, headers: headers);
      Map<String, dynamic>? body;
      if (response.body.isNotEmpty) body = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'status': true, 'message': body?['message'] ?? 'success'};
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await deleteGrade(id);
      } else {
        return {'status': false, 'message': body?['message'] ?? response.body};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
