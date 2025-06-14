import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class InventarisService {
  final AuthService _authService = AuthService();

  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/inventaris';

  final String dashboardUrl =
      '${dotenv.env['BASE_URL'] ?? ''}/dashboard/inventaris';

  Future<Map<String, dynamic>> getDashboardInventaris() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse(dashboardUrl);
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await getDashboardInventaris();
    } else {
      throw Exception(
          'Failed to load dashboard inventaris data ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getRiwayatPenggunaanInventaris() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/riwayat-penggunaan-inventaris');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await getRiwayatPenggunaanInventaris();
    } else {
      throw Exception(
          'Failed to load dashboard inventaris data ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPagedInventaris({
    int page = 1,
    int limit = 20,
    String? kategoriId,
    String? searchQuery,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (kategoriId != null &&
        kategoriId.isNotEmpty &&
        kategoriId.toLowerCase() != 'all') {
      queryParams['kategoriId'] = kategoriId;
    }
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
        return await getPagedInventaris(
            page: page,
            limit: limit,
            kategoriId: kategoriId,
            searchQuery: searchQuery);
      } else {
        return {
          'status': false,
          'message': body['message'] ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load inventaris'),
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

  Future<Map<String, dynamic>> getOldRiwayatPenggunaanInventaris() async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/riwayat-penggunaan-inventaris');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return {'status': true, 'data': body['data']};
    } else if (response.statusCode == 401) {
      await _authService.refreshToken();
      return await getOldRiwayatPenggunaanInventaris();
    } else {
      return {
        'status': false,
        'message': 'Failed to load old riwayat: ${response.statusCode}'
      };
    }
  }

  Future<Map<String, dynamic>> getRiwayatPemakaianInventarisPaginated({
    required String inventarisId,
    int page = 1,
    int limit = 10,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    final url = Uri.parse('$baseUrl/$inventarisId/riwayat-pemakaian')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'Success',
          'data': body['data'] ?? [],
          'totalPages': body['totalPages'] ?? 0,
          'currentPage': body['currentPage'] ?? page,
          'totalItems': body['totalItems'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getRiwayatPemakaianInventarisPaginated(
            inventarisId: inventarisId, page: page, limit: limit);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load paginated riwayat',
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

  Future<Map<String, dynamic>> getStatistikPemakaianInventaris({
    required String inventarisId,
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final queryParams = {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'groupBy': groupBy,
    };
    final url = Uri.parse('$baseUrl/$inventarisId/statistik-pemakaian')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] ?? 'Success',
          'data': body['data'] ?? [],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getStatistikPemakaianInventaris(
            inventarisId: inventarisId,
            startDate: startDate,
            endDate: endDate,
            groupBy: groupBy);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load statistics',
          'data': [],
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: ${e.toString()}',
        'data': [],
      };
    }
  }

  Future<Map<String, dynamic>> getInventaris() async {
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
        return await getInventaris();
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

  Future<Map<String, dynamic>> getInventarisById(String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/$id');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getInventarisById(id);
      } else {
        final body = response.body;
        return {
          'status': false,
          'message': body.isNotEmpty
              ? json.decode(body)['message']
              : 'Failed to load data',
          'data': null
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
        'data': null
      };
    }
  }

  Future<Map<String, dynamic>> getInventarisByKategoriName(String name) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/kategori/name/$name');

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
          'message': 'Inventaris not found',
          'data': [],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getInventarisByKategoriName(name);
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

  Future<Map<String, dynamic>> getInventarisByKategoriId(
      String kategoriId) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/kategori/$kategoriId');

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
          'message': 'Inventaris not found',
          'data': [],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getInventarisByKategoriId(kategoriId);
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

  Future<Map<String, dynamic>> createInventaris(
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
        return await createInventaris(data);
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

  Future<Map<String, dynamic>> updateInventaris(
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
        return await updateInventaris(data);
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

  Future<Map<String, dynamic>> deleteInventaris(String id) async {
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
        return await deleteInventaris(id);
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

  Future<Map<String, dynamic>> getPemakaianInventarisById(
      String idInventaris) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final url = Uri.parse('$baseUrl/$idInventaris/detail-pemakaian-inventaris');

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return {
          'status': true,
          'message': body['message'] ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getPemakaianInventarisById(idInventaris);
      } else {
        final body = response.body;
        return {
          'status': false,
          'message': body.isNotEmpty
              ? json.decode(body)['message']
              : 'Failed to load data',
          'data': null
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
        'data': null
      };
    }
  }
}
