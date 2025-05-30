import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';

class StatistikTernakReport extends StatefulWidget {
  const StatistikTernakReport({super.key});

  @override
  State<StatistikTernakReport> createState() => _StatistikTernakReportState();
}

class _StatistikTernakReportState extends State<StatistikTernakReport> {
  DateTimeRange? _selectedRange;

  void _openDatePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Informasi',
    'Panen',
    'Harian',
    'Sakit',
    'Mati',
    'Nutrisi',
  ];
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Definisikan tanggal pertama dan terakhir
  DateTime firstDate = DateTime(2025, 1, 1);
  DateTime lastDate = DateTime(2025, 1, 31);

  // Data laporan (contoh data)
  List<double> data = [
    10,
    15,
    30,
    25,
    20,
    35,
    40,
    50,
    45,
  ];

  // Definisikan tanggal pertama dan terakhir
  DateTime firstDates = DateTime(2025, 1, 1);
  DateTime lastDates = DateTime(2025, 1, 31);

  // Data laporan (contoh data)
  List<double> datas = [
    10,
    15,
    30,
    25,
    20,
    35,
    40,
    50,
    45,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Laporan Peternakan',
              greeting: 'Laporan Ternak Ayam'),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tabs(
              onTabChanged: _onTabChanged,
              selectedIndex: _selectedTabIndex,
              tabTitles: tabList,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                children: [_buildTabContent()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInfo();
      case 1:
        return _buildPanen();
      case 2:
        return _buildHarian();
      case 3:
        return _buildSakit();
      case 4:
        return _buildMati();
      case 5:
        return _buildNutrisi();
      default:
        return const Center(child: Text('Tab tidak dikenal'));
    }
  }

  Widget _buildInfo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DottedBorder(
              color: green1,
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/rooftop.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Informasi Jenis Ternak",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                infoItem("Nama jenis ternak", "Ayam"),
                infoItem("Nama latin", "Gallus gallus domesticus"),
                infoItem("Lokasi ternak", "Kandang A"),
                infoItem("Jumlah ternak", "20 ekor"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status ternak",
                          style: medium14.copyWith(color: dark1)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: green2.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Aktif',
                          style: regular12.copyWith(color: green2),
                        ),
                      ),
                    ],
                  ),
                ),
                infoItem("Tanggal didaftarkan",
                    DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now())),
                infoItem("Waktu didaftarkan",
                    DateFormat('HH:mm').format(DateTime.now())),
                const SizedBox(height: 8),
                Text("Deskripsi ternak",
                    style: medium14.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  "Ternak ini digunakan untuk budidaya komoditas A dan B.",
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),
          ListItem(
            title: 'Daftar Ternak',
            type: 'basic',
            items: const [
              {
                'name': 'Ayam #1',
                'category': 'Kandang A',
                'icon': 'assets/icons/goclub.svg',
              },
              {
                'name': 'Ayam #2',
                'category': 'Kandang A',
                'icon': 'assets/icons/goclub.svg',
              },
            ],
            onItemTap: (context, item) {
              final name = item['name'] ?? '';
              context.push('/detail-laporan/$name');
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }

  Widget _buildPanen() {
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
          //   counter: 20,
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
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
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

  Widget _buildHarian() {
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
          //   counter: 20,
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
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
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

  Widget _buildSakit() {
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
          //   counter: 2,
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
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
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

  Widget _buildMati() {
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
          //   counter: 2,
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
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
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

  Widget _buildNutrisi() {
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
          //   counter: 20,
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
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
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
            onItemTap: (context, item) {
              final name = item['name'] ?? '';
              context.push('/detail-laporan/$name');
            },
          ),
        ],
      ),
    );
  }
}
