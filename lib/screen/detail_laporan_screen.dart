import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DetailLaporanScreen extends StatelessWidget {
  final String name;

  const DetailLaporanScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan', style: semibold16.copyWith(color: dark1)),
        backgroundColor: Colors.white,
        foregroundColor: dark1,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: bold20.copyWith(color: dark1),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE8E8E8)),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Kategori", style: regular14.copyWith(color: dark2)),
                  const SizedBox(height: 4),
                  Text("Contoh Kategori", style: semibold14.copyWith(color: dark1)),
                  const SizedBox(height: 16),
                  Text("Tanggal", style: regular14.copyWith(color: dark2)),
                  const SizedBox(height: 4),
                  Text("22 April 2025", style: semibold14.copyWith(color: dark1)),
                  const SizedBox(height: 16),
                  Text("Petugas", style: regular14.copyWith(color: dark2)),
                  const SizedBox(height: 4),
                  Text("Pak Budi", style: semibold14.copyWith(color: dark1)),
                  const SizedBox(height: 16),
                  Text("Deskripsi", style: regular14.copyWith(color: dark2)),
                  const SizedBox(height: 4),
                  Text(
                    "Laporan ini mencatat pemberian pupuk NPK pada tanaman tomat di rooftop zone 3.",
                    style: regular14.copyWith(color: dark1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
