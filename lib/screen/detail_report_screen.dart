import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

class DetailReportScreen extends StatelessWidget {
  final Map<String, String> report;

  const DetailReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Laporan', style: bold18),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: green2.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: report['icon'] != null
                    ? SvgPicture.asset(
                        report['icon']!,
                        width: 60,
                        height: 60,
                        color: green2,
                      )
                    : Icon(Icons.report, size: 60, color: green2),
              ),
            ),
            const SizedBox(height: 24),

            // Nama Laporan (Now properly aligned in a column)
            Text(
              "Nama Laporan",
              style: regular14.copyWith(color: dark2),
            ),
            const SizedBox(height: 4),
            Text(
              report['text'] ?? "Tidak Diketahui",
              style: semibold14.copyWith(color: dark1),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 20),

            // Other details (Tanggal & Waktu)
            _buildDetailColumn("Tanggal", report['date'] ?? "Tidak Diketahui"),
            const SizedBox(height: 8),
            _buildDetailColumn("Waktu", report['time'] ?? "Tidak Diketahui"),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: green2,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  "Kembali",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Column layout for labels & values
  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: regular14.copyWith(color: dark2)),
        const SizedBox(height: 4),
        Text(value, style: semibold14.copyWith(color: dark1)),
      ],
    );
  }
}
