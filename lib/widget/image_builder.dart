import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class ImageBuilder extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const ImageBuilder({super.key, required this.url, required this.fit});

  Future<String> _getContentType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.headers['content-type'] ?? 'unknown';
      }
    } catch (e) {
      debugPrint('Error fetching content type: $e');
    }
    return 'unknown';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getContentType(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == 'unknown') {
          return const Icon(Icons.broken_image, color: Colors.red);
        }

        final contentType = snapshot.data!;
        if (contentType.contains('svg')) {
          return SvgPicture.network(
            url,
            fit: fit,
            placeholderBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              color: Colors.red,
            ),
          );
        } else {
          return Image.network(
            url,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.broken_image,
              color: Colors.red,
            ),
          );
        }
      },
    );
  }
}
