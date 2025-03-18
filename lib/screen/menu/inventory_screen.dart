import 'package:flutter/material.dart';
import 'package:smart_farming_app/screen/detail_item_screen.dart';
import 'package:smart_farming_app/screen/history_screen.dart';
import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
// import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: blue2,
        elevation: 0,
        toolbarHeight: 100,
        title: const Header(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Aksi Pelaporan",
                        style: medium16.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading:
                            const Icon(Icons.agriculture, color: Colors.green),
                        title: const Text("Laporan Harian Tanaman"),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.pets, color: Colors.blue),
                        title: const Text("Laporan Penggunaan Inventaris"),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              });
        },
        backgroundColor: blue2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Tabs(),
              const ChartWidget(),
              DashboardGrid(
                title: 'Statistik Mini',
                items: [
                  DashboardItem(title: 'Suhu (°C)', value: '28', icon: 'other'),
                  DashboardItem(
                      title: 'Total Tanaman', value: '65', icon: 'other'),
                  DashboardItem(
                      title: 'Tanaman Mati', value: '6.5', icon: 'other')
                ],
                crossAxisCount: 3,
                valueFontSize: 32,
                titleFontSize: 12,
                detailFontSize: 12,
                iconsWidth: 32,
              ),
              ListItem(
                title: "Riwayat Aktivitas",
                type: "history",
                items: const [
                  {
                    "name": "Panen Tomat",
                    "date": "17 Maret 2025",
                    "time": "10:30",
                    "image": "assets/icons/goclub.svg"
                  },
                  {
                    "name": "Penyiraman Tanaman",
                    "date": "16 Maret 2025",
                    "time": "08:00",
                    "image": "assets/icons/goclub.svg"
                  },
                ],
                navigateTo: (context) => const HistoryScreen(
                  title: "Riwayat Aktivitas",
                  items: [
                    {
                      "name": "Panen Tomat",
                      "date": "17 Maret 2025",
                      "time": "10:30"
                    },
                    {
                      "name": "Penyiraman Tanaman",
                      "date": "16 Maret 2025",
                      "time": "08:00"
                    },
                  ],
                ),
                onItemTap: (context, item) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailItemScreen(item: item),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
