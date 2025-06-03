import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
// import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/newest.dart';

class SakitTab extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<double> data;

  const SakitTab({
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
          //   title: 'Total Ternak Sakit',
          //   titleStats: 'Statistik Ternak Sakit',
          //   showCounter: true,
          //   textCounter: 'Ternak Sakit',
          //   counter: 2, // Mungkin perlu dinamis
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
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, didapatkan 2 ternak ayam dengan kondisi sakit. Penyakit ternak yang dilaporkan adalah Cacingan.",
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
                'text': 'Pak Adi telah melaporkan ternak sakit',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              }
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
