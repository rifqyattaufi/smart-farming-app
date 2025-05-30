import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/report';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getStatistikHarianJenisBudidaya(
      String id) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};

    final url = Uri.parse('$baseUrl/statistik-harian-kebun/$id');

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': true,
          'message': body['message'] as String? ?? 'success',
          'data': body['data'],
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getStatistikHarianJenisBudidaya(id);
      } else {
        return {
          'status': false,
          'message': body['message'] as String? ??
              (response.body.isNotEmpty
                  ? response.body
                  : 'Failed to load data by ID'),
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getStatistikLaporanHarian({
    required String jenisBudidayaId,
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
    final url = Uri.parse('$baseUrl/statistik-laporan-harian/$jenisBudidayaId')
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
        return await getStatistikLaporanHarian(
            jenisBudidayaId: jenisBudidayaId,
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

  Future<Map<String, dynamic>> getStatistikPenyiraman({
    required String jenisBudidayaId,
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
    final url = Uri.parse('$baseUrl/statistik-penyiraman/$jenisBudidayaId')
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
        return await getStatistikPenyiraman(
            jenisBudidayaId: jenisBudidayaId,
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

  Future<Map<String, dynamic>> getStatistikPemberianNutrisi({
    required String jenisBudidayaId,
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
    final url =
        Uri.parse('$baseUrl/statistik-pemberian-nutrisi/$jenisBudidayaId')
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
        return await getStatistikPemberianNutrisi(
            jenisBudidayaId: jenisBudidayaId,
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

  Future<Map<String, dynamic>> getRiwayatLaporanUmumJenisBudidaya({
    required String jenisBudidayaId,
    int limit = 5,
    int page = 1,
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final queryParams = {
      'limit': limit.toString(),
      'page': page.toString(),
    };

    final url = Uri.parse('$baseUrl/history/jenis-budidaya/$jenisBudidayaId')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        return {
          'status': true,
          'message': body['message'] ?? 'Success',
          'data': body['data'] ?? [],
          'currentPage': body['currentPage'] ?? 1,
          'totalPages': body['totalPages'] ?? 1,
          'totalItems': body['totalItems'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getRiwayatLaporanUmumJenisBudidaya(
            jenisBudidayaId: jenisBudidayaId, limit: limit, page: page);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load general report history',
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

  Future<Map<String, dynamic>> getRiwayatPemberianNutrisiJenisBudidaya({
    required String jenisBudidayaId,
    int limit = 3,
    int page = 1,
    String? tipeNutrisi, // misal: 'pupuk' atau 'vitamin,pupuk'
  }) async {
    final resolvedToken = await _authService.getToken();
    final headers = {'Authorization': 'Bearer $resolvedToken'};
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };
    if (tipeNutrisi != null && tipeNutrisi.isNotEmpty) {
      queryParams['tipeNutrisi'] = tipeNutrisi;
    }

    final url =
        Uri.parse('$baseUrl/history/nutrisi/jenis-budidaya/$jenisBudidayaId')
            .replace(queryParameters: queryParams);

    try {
      final response = await http.get(url, headers: headers);
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        return {
          'status': true,
          'message': body['message'] ?? 'Success',
          'data': body['data'] ?? [],
          'currentPage': body['currentPage'] ?? 1,
          'totalPages': body['totalPages'] ?? 1,
          'totalItems': body['totalItems'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        await _authService.refreshToken();
        return await getRiwayatPemberianNutrisiJenisBudidaya(
            jenisBudidayaId: jenisBudidayaId,
            limit: limit,
            page: page,
            tipeNutrisi: tipeNutrisi);
      } else {
        return {
          'status': false,
          'message': body['message'] ?? 'Failed to load nutrient history',
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
}
