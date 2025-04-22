import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: bold16.copyWith(color: dark3),
      ),
    );
  }
}
