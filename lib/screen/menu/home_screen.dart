import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_ternak_screen.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/menu_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final perkebunanData = await _dashboardService.getDashboardPerkebunan();
      final peternakanData = await _dashboardService.getDashboardPeternakan();

      setState(() {
        _perkebunanData = perkebunanData;
        _peternakanData = peternakanData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

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
                            Navigator.pop(context);

                            context.push('/tambah-kebun',
                                extra: AddKebunScreen(
                                  isEdit: false,
                                  onKebunAdded: _fetchData,
                                ));
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.pets_outlined, color: green1),
                          title: const Text("Tambah Jenis Tanaman"),
                          onTap: () {
                            Navigator.pop(context);

                            context.push('/tambah-tanaman',
                                extra: AddTanamanScreen(
                                  isEdit: false,
                                  onTanamanAdded: _fetchData,
                                ));
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.category_outlined, color: green1),
                          title: const Text("Tambah Komoditas"),
                          onTap: () {
                            Navigator.pop(context);

                            context.push('/tambah-komoditas-tanaman',
                                extra: AddKomoditasTanamanScreen(
                                  isEdit: false,
                                  onKomoditasTanamanAdded: _fetchData,
                                ));
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
                            Navigator.pop(context);

                            context.push('/tambah-kandang',
                                extra: AddKandangScreen(
                                  isEdit: false,
                                  onKandangAdded: _fetchData,
                                ));
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.pets_outlined, color: green1),
                          title: const Text("Tambah Jenis Ternak"),
                          onTap: () {
                            Navigator.pop(context);

                            context.push('/tambah-ternak',
                                extra: AddTernakScreen(
                                  isEdit: false,
                                  onTernakAdded: _fetchData,
                                ));
                          },
                        ),
                        const Divider(height: 1, color: Color(0xFFE8E8E8)),
                        ListTile(
                          leading: Icon(Icons.category_outlined, color: green1),
                          title: const Text("Tambah Komoditas"),
                          onTap: () {
                            Navigator.pop(context);

                            context.push('/tambah-komoditas-ternak',
                                extra: AddKomoditasTernakScreen(
                                  isEdit: false,
                                  onKomoditasAdded: _fetchData,
                                ));
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Column(
                children: [
                  const BannerWidget(
                    title:
                        'Kelola Perkebunan dan Peternakan dengan FarmCenter.',
                    subtitle:
                        'Pantau, lapor, dan tingkatkan hasil panen produk budidaya mu!',
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
                              const SizedBox(height: 12),
                              DashboardGrid(
                                title: 'Statistik Perkebunan Bulan Ini',
                                type: DashboardGridType.basic,
                                onViewAll: () {
                                  context.push('/report');
                                },
                                items: [
                                  DashboardItem(
                                    title: 'Suhu (°C)',
                                    value:
                                        _perkebunanData?['suhu'].toString() ??
                                            '-',
                                    icon: 'other',
                                    bgColor: green3,
                                    iconColor: yellow,
                                  ),
                                  DashboardItem(
                                    title: 'Jenis Tanaman',
                                    value: _perkebunanData?['jenisTanaman']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: green4,
                                    iconColor: green2,
                                  ),
                                  DashboardItem(
                                    title: 'Tanaman Mati',
                                    value: _perkebunanData?['jumlahKematian']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: red2,
                                    iconColor: red,
                                  ),
                                  DashboardItem(
                                    title: 'Laporan Panen',
                                    value: _perkebunanData?['jumlahPanen']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: blue3,
                                    iconColor: blue1,
                                  ),
                                ],
                                crossAxisCount: 2,
                                valueFontSize: 60,
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double cardWidth =
                                      (constraints.maxWidth / 2) - 24;
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
                                              context.push('/pilih-kebun');
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
                                              context.push(
                                                  '/pelaporan-khusus-tanaman');
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
                                reports: (_perkebunanData?['aktivitasTerbaru']
                                            as List<dynamic>? ??
                                        [])
                                    .map((aktivitas) => {
                                          'text': aktivitas['judul'] ?? '-',
                                          'time': aktivitas['createdAt'],
                                          'icon':
                                              aktivitas['userAvatarUrl'] ?? '-',
                                        })
                                    .toList(),
                                onViewAll: () =>
                                    context.push('/riwayat-aktivitas'),
                                onItemTap: (context, item) {
                                  final name = item['text'] ?? '';
                                  context.push('/detail-laporan/$name');
                                },
                                mode: NewestReportsMode.full,
                                titleTextStyle: bold18.copyWith(color: dark1),
                                reportTextStyle:
                                    medium12.copyWith(color: dark1),
                                timeTextStyle: regular12.copyWith(color: dark2),
                              ),
                              const SizedBox(height: 12),
                              ListItem(
                                title: 'Daftar Kebun',
                                items: (_perkebunanData?['daftarKebun']
                                            as List<dynamic>? ??
                                        [])
                                    .map((kebun) => {
                                          'name': kebun['nama'],
                                          'category': kebun['JenisBudidaya']
                                              ['nama'],
                                          'icon': kebun['gambar'],
                                        })
                                    .toList(),
                                type: 'basic',
                                onItemTap: (context, item) {
                                  final name = item['name'] ?? '';
                                  context.push('/detail-laporan/$name');
                                },
                                onViewAll: () =>
                                    context.push('/manajemen-kebun'),
                              ),
                              const SizedBox(height: 12),
                              ListItem(
                                title: 'Daftar Jenis Tanaman',
                                items: (_perkebunanData?['daftarTanaman']
                                            as List<dynamic>? ??
                                        [])
                                    .map((tanaman) => {
                                          'name': tanaman['nama'],
                                          'isActive': tanaman['status'],
                                          'icon': tanaman['gambar'],
                                        })
                                    .toList(),
                                type: 'basic',
                                onItemTap: (context, item) {
                                  final name = item['name'] ?? '';
                                  context.push('/detail-laporan/$name');
                                },
                                onViewAll: () =>
                                    context.push('/manajemen-jenis-tanaman'),
                              ),
                              const SizedBox(height: 12),
                              ListItem(
                                title: 'Daftar Komoditas',
                                items: (_perkebunanData?['daftarKomoditas']
                                            as List<dynamic>? ??
                                        [])
                                    .map((komoditas) => {
                                          'name': komoditas['nama'],
                                          'category': komoditas['JenisBudidaya']
                                              ['nama'],
                                          'icon': komoditas['gambar'],
                                        })
                                    .toList(),
                                type: 'basic',
                                onViewAll: () =>
                                    context.push('/manajemen-komoditas'),
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
                                onViewAll: () {
                                  context.push('/report');
                                },
                                items: [
                                  DashboardItem(
                                    title: 'Jumlah Ternak',
                                    value: _peternakanData?['jumlahTernak']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: green3,
                                    iconColor: yellow,
                                  ),
                                  DashboardItem(
                                    title: 'Jenis Ternak',
                                    value: _peternakanData?['jenisTernak']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: green4,
                                    iconColor: green2,
                                  ),
                                  DashboardItem(
                                    title: 'Ternak Mati',
                                    value: _peternakanData?['jumlahKematian']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: red2,
                                    iconColor: red,
                                  ),
                                  DashboardItem(
                                    title: 'Laporan Panen',
                                    value: _peternakanData?['jumlahPanen']
                                            .toString() ??
                                        '-',
                                    icon: 'other',
                                    bgColor: blue3,
                                    iconColor: blue1,
                                  ),
                                ],
                                crossAxisCount: 2,
                                valueFontSize: 60,
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double cardWidth =
                                      (constraints.maxWidth / 2) - 24;
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
                                              context.push('/pilih-kandang');
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
                                              context.push(
                                                  '/pelaporan-khusus-ternak');
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
                                reports: (_peternakanData?['aktivitasTerbaru']
                                            as List<dynamic>? ??
                                        [])
                                    .map((aktivitas) => {
                                          'text': aktivitas['judul'] ?? '-',
                                          'time': aktivitas['createdAt'],
                                          'icon':
                                              aktivitas['userAvatarUrl'] ?? '-',
                                        })
                                    .toList(),
                                onViewAll: () =>
                                    context.push('/riwayat-aktivitas'),
                                onItemTap: (context, item) {
                                  final name = item['text'] ?? '';
                                  context.push('/detail-laporan/$name');
                                },
                                mode: NewestReportsMode.full,
                                titleTextStyle: bold18.copyWith(color: dark1),
                                reportTextStyle:
                                    medium12.copyWith(color: dark1),
                                timeTextStyle: regular12.copyWith(color: dark2),
                              ),
                              const SizedBox(height: 12),
                              ListItem(
                                title: 'Daftar Kandang',
                                items: (_peternakanData?['daftarKandang']
                                            as List<dynamic>? ??
                                        [])
                                    .map((kandang) => {
                                          'name': kandang['nama'],
                                          'category': kandang['JenisBudidaya']
                                              ['nama'],
                                          'icon': kandang['gambar'],
                                        })
                                    .toList(),
                                type: 'basic',
                                onItemTap: (context, item) {
                                  final name = item['name'] ?? '';
                                  context.push('/detail-laporan/$name');
                                },
                                onViewAll: () =>
                                    context.push('/manajemen-kandang'),
                              ),
                              const SizedBox(height: 12),
                              ListItem(
                                title: 'Daftar Jenis Ternak',
                                items: (_peternakanData?['daftarTernak']
                                            as List<dynamic>? ??
                                        [])
                                    .map((tanaman) => {
                                          'name': tanaman['nama'],
                                          'isActive': tanaman['status'],
                                          'icon': tanaman['gambar'],
                                        })
                                    .toList(),
                                type: 'basic',
                                onItemTap: (context, item) {
                                  final name = item['name'] ?? '';
                                  context.push('/detail-laporan/$name');
                                },
                                onViewAll: () =>
                                    context.push('/manajemen-ternak'),
                              ),
                              const SizedBox(height: 12),
                              ListItem(
                                title: 'Daftar Komoditas',
                                items: (_peternakanData?['daftarKomoditas']
                                            as List<dynamic>? ??
                                        [])
                                    .map((komoditas) => {
                                          'name': komoditas['nama'],
                                          'category': komoditas['JenisBudidaya']
                                              ['nama'],
                                          'icon': komoditas['gambar'],
                                        })
                                    .toList(),
                                type: 'basic',
                                onViewAll: () =>
                                    context.push('/manajemen-komoditas'),
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
