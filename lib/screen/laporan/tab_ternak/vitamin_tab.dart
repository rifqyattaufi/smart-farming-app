import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
// import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';

class VitaminTab extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<double> data;

  const VitaminTab({
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
          //   titleStats: 'Statistik Pemberian Nutrisi Ternak',
          //   showCounter: true,
          //   textCounter: 'Data Pemberian Nutrisi',
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
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, telah dilakukan pelaporan pemberian nutrisi.",
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
                'text': 'Pak Adi telah melaporkan pemberian nutrisi',
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
          const SizedBox(height: 12),
          ListItem(
            title: 'Riwayat Pemberian Nutrisi',
            type: 'history',
            items: const [
              {
                'name': 'Vitamin A - Dosis 4 Ml',
                'category': 'Vitamin',
                'image': 'assets/images/rooftop.jpg',
                'person': 'Pak Adi',
                'date': 'Senin, 22 Apr 2025',
                'time': '10:45',
              },
            ],
            onItemTap: (itemContext, item) {
              final name = item['name'] ?? '';
              itemContext.push('/detail-laporan/$name');
            },
          ),
        ],
      ),
    );
  }
}
