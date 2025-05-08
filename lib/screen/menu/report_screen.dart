import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/theme.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Perkebunan',
    'Peternakan',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.menu,
              title: 'Menu Aplikasi',
              greeting: 'Laporan'),
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
                children: [
                  // Perkebunan Tab
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        DashboardGrid(
                          title: 'Statistik Perkebunan Bulan Ini',
                          type: DashboardGridType.none,
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
                        ),
                        const SizedBox(height: 12),
                        ListItem(
                          title: 'Daftar Jenis Tanaman',
                          items: const [
                            {
                              'name': 'Melon',
                              'category': 'Kebun A',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onItemTap: (BuildContext context,
                              Map<String, dynamic> item) {
                            context.push('/statistik-laporan-tanaman');
                          },
                        ),
                        const SizedBox(height: 12),
                        ListItem(
                          title: 'Laporan Hama',
                          items: const [
                            {
                              'name': 'Tikus',
                              'category': 'Diidentifikasi terdapat 3 ekor',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'name': 'Ulat',
                              'category': 'Diidentifikasi terdapat 5 ekor',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onViewAll: () => context.push('/laporan-hama'),
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        DashboardGrid(
                          title: 'Statistik Peternakan Bulan Ini',
                          type: DashboardGridType.none,
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
                        ),
                        const SizedBox(height: 12),
                        ListItem(
                          title: 'Daftar Jenis Ternak',
                          items: const [
                            {
                              'name': 'Ayam',
                              'category': 'Kandang A',
                              'icon': 'assets/icons/goclub.svg',
                            }
                          ],
                          type: 'basic',
                          onItemTap: (BuildContext context,
                              Map<String, dynamic> item) {
                            context.push('/statistik-laporan-ternak');
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
