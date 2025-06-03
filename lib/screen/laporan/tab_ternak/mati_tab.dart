import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
// import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/newest.dart';

class MatiTab extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<double> data;

  const MatiTab({
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
          //   title: 'Total Kematian Ternak',
          //   titleStats: 'Statistik Kematian Ternak',
          //   showCounter: true,
          //   textCounter: 'Kematian Ternak',
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
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, ditemukan 2 ternak mati dengan deskripsi kekurangan nutrisi.",
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
                'text': 'Pak Adi telah melaporkan ternak mati',
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
