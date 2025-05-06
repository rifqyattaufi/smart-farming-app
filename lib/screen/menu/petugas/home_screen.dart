import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/menu_card.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/banner.dart';

class HomePetugasScreen extends StatefulWidget {
  const HomePetugasScreen({super.key});

  @override
  State<HomePetugasScreen> createState() => _HomePetugasScreenState();
}

class _HomePetugasScreenState extends State<HomePetugasScreen> {
  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Perkebunan',
    'Peternakan',
  ];
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              tabTitles: tabList,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Menu Pelaporan',
                                style: bold18.copyWith(color: dark1),
                              ),
                            ],
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double cardWidth = (constraints.maxWidth / 2) - 24;
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: MenuCard(
                                      bgColor: yellow1,
                                      iconColor: yellow,
                                      icon: Icons.add,
                                      title: 'Pelaporan Harian',
                                      subtitle:
                                          'Pelaporan rutin kondisi tanaman setiap hari',
                                      onTap: () {
                                        context.push('/detail');
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: MenuCard(
                                      bgColor: const Color(0xFFDDE7D9),
                                      iconColor: Colors.green,
                                      icon: Icons.edit,
                                      title: 'Pelaporan Khusus',
                                      subtitle:
                                          'Pelaporan khusus kondisi tanaman seperti sakit, mati, atau panen',
                                      onTap: () {
                                        context.push('/detail');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        NewestReports(
                          title: 'Aktivitas Terbaru',
                          reports: const [
                            {
                              'text':
                                  'Pak Adi telah melaporkan kondisi tanaman',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'text': 'Pak Adi telah melaporkan tanaman sakit',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Menu Pelaporan',
                                style: bold18.copyWith(color: dark1),
                              ),
                            ],
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double cardWidth = (constraints.maxWidth / 2) - 24;
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: MenuCard(
                                      bgColor: yellow1,
                                      iconColor: yellow,
                                      icon: Icons.add,
                                      title: 'Pelaporan Harian',
                                      subtitle:
                                          'Pelaporan rutin kondisi ternak setiap hari',
                                      onTap: () {
                                        context.push('/detail');
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: MenuCard(
                                      bgColor: const Color(0xFFDDE7D9),
                                      iconColor: Colors.green,
                                      icon: Icons.edit,
                                      title: 'Pelaporan Khusus',
                                      subtitle:
                                          'Pelaporan khusus kondisi ternak seperti sakit, mati, atau panen',
                                      onTap: () {
                                        context.push('/detail');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        NewestReports(
                          title: 'Aktivitas Terbaru',
                          reports: const [
                            {
                              'text': 'Pak Adi telah melaporkan kondisi ternak',
                              'icon': 'assets/icons/goclub.svg',
                            },
                            {
                              'text': 'Pak Adi telah melaporkan ternak sakit',
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
