import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class StatistikHarianCard extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const StatistikHarianCard({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error statistik: $errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (data == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Data statistik harian tidak tersedia.'),
      );
    }

    final int totalTanaman = data!['totalTanaman'] as int? ?? 0;
    final int tanamanSehat = data!['tanamanSehat'] as int? ?? 0;
    final int perluPerhatian = data!['perluPerhatian'] as int? ?? 0;
    final int kritis = data!['kritis'] as int? ?? 0;
    final String rekomendasi =
        data!['rekomendasi'] as String? ?? 'Tidak ada rekomendasi.';
    final double persentaseSehat =
        (data!['persentaseSehat'] as num?)?.toDouble() ?? 0.0;
    final double persentasePerluPerhatian =
        (data!['persentasePerluPerhatian'] as num?)?.toDouble() ?? 0.0;
    final double persentaseKritis =
        (data!['persentaseKritis'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Kesehatan Tanaman',
                style: bold16.copyWith(color: dark1),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Tanaman:',
                      style: medium14.copyWith(color: dark2)),
                  Text('$totalTanaman', style: bold14.copyWith(color: dark1)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tanaman Sehat:',
                      style: medium14.copyWith(color: green1)),
                  Text('$tanamanSehat (${persentaseSehat.toStringAsFixed(1)}%)',
                      style: bold14.copyWith(color: green1)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Perlu Perhatian:',
                      style: medium14.copyWith(color: Colors.orange)),
                  Text(
                      '$perluPerhatian (${persentasePerluPerhatian.toStringAsFixed(1)}%)',
                      style: bold14.copyWith(color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kritis:', style: medium14.copyWith(color: red)),
                  Text('$kritis (${persentaseKritis.toStringAsFixed(1)}%)',
                      style: bold14.copyWith(color: red)),
                ],
              ),
              const SizedBox(height: 12.0),
              const Divider(),
              const SizedBox(height: 8.0),
              Text(
                'Rekomendasi:',
                style: medium14.copyWith(color: dark1),
              ),
              const SizedBox(height: 4.0),
              Text(
                rekomendasi,
                style: regular14.copyWith(color: dark2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
