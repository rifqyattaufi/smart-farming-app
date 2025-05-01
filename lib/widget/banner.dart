import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';

class BannerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showDate;

  const BannerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: green4,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: semibold20.copyWith(color: dark1),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: regular16.copyWith(color: dark1),
          ),
          if (showDate) ...[
            const SizedBox(height: 20),
            Text(
              DateFormat('EEEE, dd MMMM yyyy HH:mm').format(DateTime.now()),
              style: regular14.copyWith(color: dark1),
            ),
          ]
        ],
      ),
    );
  }
}
