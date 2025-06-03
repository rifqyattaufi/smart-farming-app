import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
// import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/newest.dart';

class HarianTab extends StatelessWidget {
  final DateTime firstDates;
  final DateTime lastDates;
  final List<double> datas;

  const HarianTab({
    super.key,
    required this.firstDates,
    required this.lastDates,
    required this.datas,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // ChartWidget(
          //   firstDate: firstDates,
          //   lastDate: lastDates,
          //   data: datas,
          //   titleStats: 'Statistik Laporan Harian Ternak',
          //   textCounter: 'Data Laporan Harian',
          //   counter: 20, // Mungkin perlu dinamis
          //   showCounter: false,
          // ),
          // ChartWidget(
          //   firstDate: firstDates,
          //   lastDate: lastDates,
          //   data: datas,
          //   titleStats: 'Statistik Pemberian Pakan',
          //   showCounter: false,
          // ),
          // ChartWidget(
          //   firstDate: firstDates,
          //   lastDate: lastDates,
          //   data: datas,
          //   titleStats: 'Statistik Pengecekan Kandang',
          //   showCounter: false,
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
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, telah dilakukan pelaporan harian dengan rata-rata 18 laporan per hari.\n\nHari dengan pelaporan terendah pada tanggal 13 Februari 2025 dan hari dengan pelaporan terbanyak pada tanggal 14 & 17 Februari 2025.\n\nFrekuensi pemberian pakan ternak rata-rata 18 kali per hari. Kemudian, Pengecekan kandang ternak terjadi 1 kali pada tanggal 17 Februari 2025. Bukti pelaporan dapat dilihat pada detail riwayat pelaporan.",
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
                'text': 'Pak Adi telah melaporkan laporan harian ternak',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              },
              {
                'text': 'Pak Adi telah melaporkan laporan harian ternak',
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
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
