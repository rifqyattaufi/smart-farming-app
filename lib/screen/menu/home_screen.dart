import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  String? selectedType;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(headerType: HeaderType.basic)),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                if (_selectedTabIndex == 0) {
                  return Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Aksi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.house_outlined, color: green1),
                          title: const Text("Tambah Kebun"),
                          onTap: () {
                            context.push('/tambah-kebun');
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.pets_outlined, color: green1),
                          title: const Text("Tambah Jenis Tanaman"),
                          onTap: () {
                            context.push('/tambah-tanaman');
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.category_outlined, color: green1),
                          title: const Text("Tambah Komoditas"),
                          onTap: () {
                            context.push('/tambah-komoditas-tanaman');
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Aksi",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.house_outlined, color: green1),
                          title: const Text("Tambah Kandang"),
                          onTap: () {
                            context.push('/tambah-kandang');
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.pets_outlined, color: green1),
                          title: const Text("Tambah Ternak"),
                          onTap: () {
                            context.push('/tambah-ternak');
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.category_outlined, color: green1),
                          title: const Text("Tambah Komoditas"),
                          onTap: () {
                            context.push('/tambah-komoditas-ternak');
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            );
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BannerWidget(
              title: 'Kelola Perkebunan dan Peternakan dangen FarmCenter.',
              subtitle:
                  'Pantau, lapor, dan tingkatkan hasil panen produk budidayamu!',
              showDate: true,
            ),
            Tabs(
              onTabChanged: _onTabChanged,
              selectedIndex: _selectedTabIndex,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                children: [
                  // Perkebunan Tab
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        DashboardGrid(
                          title: 'Statistik Perkebunan Bulan Ini',
                          type: DashboardGridType.basic,
                          items: [
                            DashboardItem(
                              title: 'Suhu (°C)',
                              value: '28',
                              icon: 'other',
                              bgColor: green3,
                              iconColor: yellow,
                            ),
                            DashboardItem(
                              title: 'Jenis Tanaman',
                              value: '18',
                              icon: 'other',
                              bgColor: green4,
                              iconColor: green2,
                            ),
                            DashboardItem(
                              title: 'Tanaman Mati',
                              value: '2',
                              icon: 'other',
                              bgColor: red2,
                              iconColor: red,
                            ),
                            DashboardItem(
                              title: 'Laporan Panen',
                              value: '8',
                              icon: 'other',
                              bgColor: blue3,
                              iconColor: blue1,
                            ),
                          ],
                          crossAxisCount: 2,
                          valueFontSize: 60,
                          onViewAll: () => context.push('/report'),
                        ),
                        const SizedBox(height: 12),
                        NewestReports(
                          title: 'Aktivitas Terbaru',
                          reports: const [
                            {
                              'text':
                                  'Pak Adi telah melaporkan kondisi tanaman',
                              'time': 'Senin, 17 Februari 2025 | 08.20',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'text': 'Pak Adi telah melaporkan tanaman sakit',
                              'time': 'Senin, 17 Februari 2025 | 08.20',
                              'icon': 'assets/icons/goclub.svg',
                            },
                          ],
                          onViewAll: () => context.push('/riwayat-aktivitas'),
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
                        ListItem(
                          title: 'Daftar Kebun',
                          items: const [
                            {
                              'name': 'Kebun A',
                              'category': 'Melon',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'name': 'Kebun B',
                              'category': 'Anggur',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onViewAll: () => context.push('/manajemen-kebun'),
                          onItemTap: (context, item) {
                            final name = item['name'] ?? '';
                            context.push('/detail-laporan/$name');
                          },
                        ),
                        const SizedBox(height: 12),
                        ListItem(
                          title: 'Daftar Jenis Tanaman',
                          items: const [
                            {
                              'name': 'Melon',
                              'category': 'Kebun A',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'name': 'Anggur',
                              'category': 'Kebun B',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onViewAll: () =>
                              context.push('/manajemen-jenis-tanaman'),
                          onItemTap: (context, item) {
                            final name = item['name'] ?? '';
                            context.push('/detail-laporan/$name');
                          },
                        ),
                      ],
                    ),
                  ),
                  // Peternakan Tab
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        DashboardGrid(
                          title: 'Statistik Peternakan Bulan Ini',
                          type: DashboardGridType.basic,
                          items: [
                            DashboardItem(
                              title: 'Jumlah Ternak',
                              value: '30',
                              icon: 'other',
                              bgColor: green3,
                              iconColor: yellow,
                            ),
                            DashboardItem(
                              title: 'Jenis Ternak',
                              value: '18',
                              icon: 'other',
                              bgColor: green4,
                              iconColor: green2,
                            ),
                            DashboardItem(
                              title: 'Ternak Mati',
                              value: '2',
                              icon: 'other',
                              bgColor: red2,
                              iconColor: red,
                            ),
                            DashboardItem(
                              title: 'Laporan Panen',
                              value: '8',
                              icon: 'other',
                              bgColor: blue3,
                              iconColor: blue1,
                            ),
                          ],
                          crossAxisCount: 2,
                          valueFontSize: 60,
                          onViewAll: () => context.push('/report'),
                        ),
                        const SizedBox(height: 12),
                        NewestReports(
                          title: 'Aktivitas Terbaru',
                          reports: const [
                            {
                              'text': 'Pak Adi telah melaporkan kondisi ternak',
                              'time': 'Senin, 17 Februari 2025 | 08.20',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'text': 'Pak Adi telah melaporkan ternak sakit',
                              'time': 'Senin, 17 Februari 2025 | 08.20',
                              'icon': 'assets/icons/goclub.svg',
                            },
                          ],
                          onViewAll: () => context.push('/riwayat-aktivitas'),
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
                        ListItem(
                          title: 'Daftar Kandang',
                          items: const [
                            {
                              'name': 'Kandang A',
                              'category': 'Ayam',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'name': 'Kandang B',
                              'category': 'Lele',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onViewAll: () => context.push('/manajemen-kandang'),
                          onItemTap: (context, item) {
                            final name = item['name'] ?? '';
                            context.push('/detail-laporan/$name');
                          },
                        ),
                        const SizedBox(height: 12),
                        ListItem(
                          title: 'Daftar Jenis Ternak',
                          items: const [
                            {
                              'name': 'Ayam',
                              'category': 'Kandang A',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'name': 'Lele',
                              'category': 'Kandang B',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onViewAll: () => context.push('/manajemen-ternak'),
                          onItemTap: (context, item) {
                            final name = item['name'] ?? '';
                            context.push('/detail-laporan/$name');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
