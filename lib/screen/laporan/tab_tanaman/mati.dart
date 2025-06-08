import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/newest.dart';

class MatiTab extends StatelessWidget {
  const MatiTab({
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
                Text("Rangkuman Statistik Kematian",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, ditemukan 2 tanaman melon mati dengan deskripsi kekurangan nutrisi kritis dan serangan hama yang parah.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan Tanaman Mati',
            reports: const [
              {
                'id': 'mati_report_1',
                'text':
                    'Pak Budi melaporkan 1 tanaman Tomat mati karena layu fusarium',
                'icon': 'assets/icons/set/carbohydrates.png',
                'time': '20 Mei 2025',
              },
              {
                'id': 'mati_report_2',
                'text':
                    'Tanaman Melon #3 di Kebun A mati, diduga kekurangan air',
                'icon': 'assets/icons/set/carbohydrates.png',
                'time': '10 Apr 2025',
              },
            ],
            onItemTap: (itemContext, item) {
              final reportId = item['id'] as String?;
              final reportName = item['text'] ?? 'Laporan Tidak Dikenal';
              if (reportId != null) {
                // itemContext.push('/detail-laporan-kematian/$reportId');
                print(
                    'Navigasi ke detail laporan kematian: $reportName (ID: $reportId)');
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
              // context.push('/semua-laporan-kematian');
              print('Navigasi ke semua laporan kematian');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lihat Semua Laporan Kematian')));
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
