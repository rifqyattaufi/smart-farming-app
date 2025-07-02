import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class HamaService {
  final AuthService _authService = AuthService();

  final String _jenisHamaBaseUrl = '${dotenv.env['BASE_URL']}/jenis-hama';

  final String _baseUrl = '${dotenv.env['BASE_URL']}';

  Future<Map<String, dynamic>> getDaftarHama({
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_jenisHamaBaseUrl?page=$page&limit=$limit');

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
        return await getDaftarHama(page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load daftar hama'),
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

  Future<Map<String, dynamic>> searchDaftarHama(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
        '$_jenisHamaBaseUrl/search/$encodedQuery?page=$page&limit=$limit');

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
        return await searchDaftarHama(query, page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to search daftar hama'),
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

  Future<Map<String, dynamic>> getJenisHamaById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_jenisHamaBaseUrl/$id');

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
        return await getJenisHamaById(id);
      } else {
        return {'status': false, 'message': body['message'] ?? response.body};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createJenisHama(
      Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse(_jenisHamaBaseUrl);

    try {
      final response =
          await http.post(url, headers: headers, body: json.encode(data));
      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        return {
          'status': true,
          'message': responseData['message'] ?? 'success',
          'data': responseData['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await createJenisHama(data);
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

  Future<Map<String, dynamic>> updateJenisHama(
      String id, Map<String, dynamic> data) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json'
    };
    final url = Uri.parse('$_jenisHamaBaseUrl/$id');

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
        return await updateJenisHama(id, data);
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

  Future<Map<String, dynamic>> deleteJenisHama(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_jenisHamaBaseUrl/$id');

    try {
      final response = await http.delete(url, headers: headers);
      Map<String, dynamic>? body;
      if (response.body.isNotEmpty) body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body?['message'] ?? 'success',
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await deleteJenisHama(id);
      } else {
        return {'status': false, 'message': body?['message'] ?? response.body};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getLaporanHama({
    int page = 1,
    int limit = 10,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final url = Uri.parse('$_baseUrl/laporan-hama?page=$page&limit=$limit');

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
        return await getLaporanHama(page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load laporan hama'),
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

  Future<Map<String, dynamic>> searchLaporanHama(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final encodedQuery = Uri.encodeComponent(query);

    final url = Uri.parse(
        '$_baseUrl/hama/search/$encodedQuery?page=$page&limit=$limit');

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
        return await searchLaporanHama(query, page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to search laporan hama'),
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

  Future<Map<String, dynamic>> getLaporanHamaById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$_baseUrl/laporan-hama/$id');

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
        return await getLaporanHamaById(id);
      } else {
        return {'status': false, 'message': body['message'] ?? response.body};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> updateStatusHama(
      String idLaporanHama, bool status) async {
    final resolvedToken = await _authService.getToken();
    final headers = {
      'Authorization': 'Bearer $resolvedToken',
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$_baseUrl/laporan-hama/$idLaporanHama/status');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({'status': status}),
      );
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'Status hama berhasil diupdate',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await updateStatusHama(idLaporanHama, status);
      } else {
        return {'status': false, 'message': body['message'] ?? response.body};
      }
    } catch (e) {
      return {'status': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
