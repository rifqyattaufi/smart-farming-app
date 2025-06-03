import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
// import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/newest.dart';

class PanenTab extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<double> data;

  const PanenTab({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ChartWidget(
          //   firstDate: firstDate,
          //   lastDate: lastDate,
          //   data: data,
          //   title: 'Total Hasil Panen',
          //   titleStats: 'Statistik Hasil Panen Ternak',
          //   showCounter: true,
          //   counter: 20, // Mungkin perlu dinamis
          // ),
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
                  "Berdasarkan statistik pelaporan panen ayam komoditas telur menghasilkan rata-rata 18 butir telur yang dihasilkan setiap hari.\n\nSedangkan, untuk komoditas daging berhasil panen dengan total berat 4 Kg per 17 Februari 2025.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan',
            reports: const [
              {
                'text': 'Pak Adi telah melaporkan hasil panen',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              },
              {
                'text': 'Pak Adi telah melaporkan hasil panen',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              },
            ],
            onItemTap: (itemContext, item) {
              final name = item['text'] ?? '';
              itemContext.push('/detail-laporan/$name');
            },
            onViewAll: () {
              context.push('/');
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
        ],
      ),
    );
  }
}
