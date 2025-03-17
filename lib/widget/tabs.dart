import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: blue2,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'Perkebunan',
              style: semibold14.copyWith(color: Colors.white),
            ),
          ),
          ...['Peternakan'].map(
            (title) => Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(title, style: semibold14.copyWith(color: blue2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
