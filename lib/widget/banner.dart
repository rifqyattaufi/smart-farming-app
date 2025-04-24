import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';

class BannerWidget extends StatelessWidget {
  const BannerWidget({super.key});

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
              'Kelola Perkebunan dan Peternakan dengan FarmCenter.',
              style: semibold16.copyWith(color: dark1),
            ),
            const SizedBox(height: 8),
            Text(
              'Pantau, lapor, dan tingkatkan hasil panen produk budidayamu!',
              style: regular14.copyWith(color: dark1),
            ),
            const SizedBox(height: 20),
            Text(
              DateFormat('EEEE, dd MMMM yyyy HH:mm').format(DateTime.now()),
              style: regular14.copyWith(color: dark1),
            ),
          ],
        ));
  }
}
