import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/newest.dart';

class RiwayatAktivitasScreen extends StatefulWidget {
  const RiwayatAktivitasScreen({super.key});

  @override
  State<RiwayatAktivitasScreen> createState() => _RiwayatAktivitasScreenState();
}

class _RiwayatAktivitasScreenState extends State<RiwayatAktivitasScreen> {
  int selectedTab = 0;
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Menu Aplikasi',
            greeting: 'Riwayat Aktivitas Pelaporan',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
                NewestReports(
                  title: 'Aktivitas Terbaru',
                  reports: const [
                    {
                      'text': 'Pak Adi telah melaporkan kondisi tanaman',
                      'time': 'Senin, 17 Februari 2025 | 08.20',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Pak Adi telah melaporkan kondisi ternak',
                      'time': 'Senin, 17 Februari 2025 | 08.20',
                      'icon': 'assets/icons/goclub.svg',
                    },
                  ],
                  onItemTap: (context, item) {
                    final name = item['text'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
                const SizedBox(height: 12),
                NewestReports(
                  title: 'Seluruh Aktivitas',
                  reports: const [
                    {
                      'text': 'Pak Adi telah melaporkan kondisi tanaman',
                      'time': 'Senin, 17 Februari 2025 | 08.20',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Pak Adi telah melaporkan kondisi ternak',
                      'time': 'Senin, 17 Februari 2025 | 08.20',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Pak Adi telah melaporkan tanaman sakit',
                      'time': 'Senin, 17 Februari 2025 | 08.20',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Pak Adi telah melaporkan ternak sakit',
                      'time': 'Senin, 17 Februari 2025 | 08.20',
                      'icon': 'assets/icons/goclub.svg',
                    },
                  ],
                  onItemTap: (context, item) {
                    final name = item['text'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
