import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DashboardService {
  final String baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/dashboard';

  final Map<String, String> headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImZjNTcxYWZhLWU2NmItNDM3Yi04YjE1LWRjZTY4ZWRlZTNmMyIsIm5hbWUiOiJwamF3YWIiLCJlbWFpbCI6InBqYXdhYkBlbWFpbC5jb20iLCJwaG9uZSI6IjA4MTIzNDU2Nzg5Iiwicm9sZSI6InBqYXdhYiIsImlhdCI6MTc0NTg1Mjk5OCwiZXhwIjoxNzQ1OTM5Mzk4fQ.JrIvxtlIPnEtGf0GzHHbjbkBkREYVE9ypMbmgfq--m0'
  };
  Future<Map<String, dynamic>> getDashboardPerkebunan() async {
    final url = Uri.parse('$baseUrl/perkebunan');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else {
      throw Exception(
          'Failed to load dashboard perkebunan data ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getDashboardPeternakan() async {
    final url = Uri.parse('$baseUrl/peternakan');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data'];
    } else {
      throw Exception('Failed to load dashboard peternakan data');
    }
  }
}
