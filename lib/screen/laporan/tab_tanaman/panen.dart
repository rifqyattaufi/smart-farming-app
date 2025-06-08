import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/newest.dart';

class PanenTab extends StatelessWidget {
  const PanenTab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan panen tiap 2 bulan sekali, didapatkan hasil panen sangat optimal, dengan rata-rata di atas 18 buah yang dihasilkan per waktu panen.\n\nTerdapat 2 kondisi terbaik saat panen, yaitu pada bulan Agustus 2024 dan Februari 2025 dengan total panen, yaitu 20 buah.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan Panen',
            reports: const [
              {
                'id': 'panen_report_1',
                'text':
                    'Pak Adi telah melaporkan hasil panen Melon periode Mei',
                'icon': 'assets/icons/set/carbohydrates.png',
                'time': '28 Mei 2025', // Contoh waktu
              },
              {
                'id': 'panen_report_2',
                'text': 'Bu Susi melaporkan panen Cabai sebanyak 5 Kg',
                'icon': 'assets/icons/set/carbohydrates.png',
                'time': '15 Apr 2025', // Contoh waktu
              },
            ],
            onItemTap: (itemContext, item) {
              final reportId = item['id'] as String?;
              final reportName = item['text'] ?? 'Laporan Tidak Dikenal';
              if (reportId != null) {
                // itemContext.push('/detail-laporan-panen/$reportId');
                print(
                    'Navigasi ke detail laporan panen: $reportName (ID: $reportId)');
                ScaffoldMessenger.of(itemContext).showSnackBar(
                    SnackBar(content: Text('Tap pada: $reportName')));
              } else {
                print('Tap pada: $reportName (ID tidak tersedia)');
                ScaffoldMessenger.of(itemContext).showSnackBar(SnackBar(
                    content:
                        Text('Tap pada: $reportName (ID tidak tersedia)')));
              }
            },
            onViewAll: () {
              // context.push('/semua-laporan-panen');
              print('Navigasi ke semua laporan panen');
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lihat Semua Laporan Panen')));
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
