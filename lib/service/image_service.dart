import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageService {
  final String baseUrl = dotenv.env['CLOUDINARY_URL'] ?? '-';
  final String apiKey = dotenv.env['CLOUDINARY_KEY'] ?? '-';
  final String apiSecret = dotenv.env['CLOUDINARY_SECRET'] ?? '-';

  Future<Map<String, dynamic>> uploadImage(File image) async {
    final url = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = apiKey
      ..fields['upload_preset'] = 'default'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return {
          'status': true,
          'message': 'success',
          'data': data['secure_url'],
        };
      } else {
        final data = json.decode(responseBody);
        return {
          'status': false,
          'message': data['error'],
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
