import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/chart.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:dotted_border/dotted_border.dart';

class HarvestStatsScreen extends StatefulWidget {
  const HarvestStatsScreen({super.key});

  @override
  State<HarvestStatsScreen> createState() => _HarvestStatsScreenState();
}

class _HarvestStatsScreenState extends State<HarvestStatsScreen> {
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
    'Laporan Panen',
    'Laporan Harian',
    'Laporan Sakit',
    'Laporan Mati',
    'Laporan Nutrisi',
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
              title: 'Laporan Perkebunan',
              greeting: 'Laporan Tanaman Melon'),
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
                Text("Informasi Jenis Tanaman",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                infoItem("Nama jenis tanaman", "Melon"),
                infoItem("Nama latin", "Fujisawa no melon"),
                infoItem("Lokasi tanaman", "Kebun A"),
                infoItem("Jumlah tanaman", "20 tanaman"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status tanaman",
                          style: medium14.copyWith(color: dark1)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: green2.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Budidaya',
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
                Text("Deskripsi tanaman",
                    style: medium14.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  "Tanaman ini digunakan untuk budidaya buah A.",
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),
          ListItem(
            title: 'Daftar Tanaman',
            type: 'basic',
            items: const [
              {
                'name': 'Melon #1',
                'category': 'Kebun A',
                'icon': 'assets/icons/goclub.svg',
              },
              {
                'name': 'Melon #2',
                'category': 'Kebun A',
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
        children: [
          ChartWidget(
            firstDate: firstDate,
            lastDate: lastDate,
            data: data,
          ),
        ],
      ),
    );
  }

  Widget _buildHarian() {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [Text("Halo")],
      ),
    );
  }

  Widget _buildSakit() {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [Text("Halo")],
      ),
    );
  }

  Widget _buildMati() {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [Text("Halo")],
      ),
    );
  }

  Widget _buildNutrisi() {
    return const SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [Text("Halo")],
      ),
    );
  }
}
