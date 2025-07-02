import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_ternak_screen.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/menus.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  bool _isLoading = true;
  String? _userRole;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPerkebunanKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPeternakanKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchData(isRefresh: false);
  }

  Future<void> _fetchData({isRefresh = false}) async {
    if (isRefresh && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final role = await _authService.getUserRole();
      final results = await Future.wait([
        _dashboardService.getDashboardPerkebunan(),
        _dashboardService.getDashboardPeternakan(),
      ]);

      if (!mounted) return;
      setState(() {
        _userRole = role;
        _perkebunanData = results[0];
        _peternakanData = results[1];
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          if (_pageController.page?.round() != _selectedTabIndex) {
            _pageController.jumpToPage(_selectedTabIndex);
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Perkebunan',
    'Peternakan',
  ];
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPerkebunanContent() {
    if (_isLoading && _perkebunanData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isLoading && _perkebunanData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gagal memuat data perkebunan.",
                style: regular12.copyWith(color: dark2),
                key: const Key('perkebunanErrorText')),
            const SizedBox(height: 10),
            ElevatedButton(
              key: const Key('retryPerkebunanButton'),
              onPressed: () => _fetchData(isRefresh: true),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorPerkebunanKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (_perkebunanData != null) ...[
            DashboardGrid(
              title: 'Statistik Perkebunan Bulan Ini',
              type: DashboardGridType.basic,
              onViewAll: () {
                context.push('/report').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              items: [
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jenis Tanaman',
                  value: _perkebunanData?['jenisTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
                DashboardItem(
                  title: 'Tanaman Mati',
                  value: _perkebunanData?['jumlahKematian'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Laporan Panen',
                  value: _perkebunanData?['jumlahPanen'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 60,
            ),
            const SizedBox(height: 12),
            MenuGrid(
              title: 'Menu Aplikasi Perkebunan',
              menuItems: [
                MenuItem(
                  title: 'Manajamen Kebun',
                  icon: 'set/hydroponics-filled.png',
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-kebun').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajamen Jenis Tanaman',
                  icon: 'set/appleSeed-filled.png',
                  backgroundColor: Colors.blue,
                  iconColor: Colors.white,
                  onTap: () =>
                      context.push('/manajemen-jenis-tanaman').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajamen Komoditas',
                  icon: 'set/fruitbag-filled.png',
                  backgroundColor: Colors.cyan,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-komoditas').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Hama Kebun',
                  icon: 'set/slugEating-filled.png',
                  backgroundColor: Colors.amber,
                  iconColor: Colors.white,
                  onTap: () => context.push('/laporan-hama'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewestReports(
              key: const Key('aktivitasTerbaruPerkebunan'),
              title: 'Aktivitas Terbaru',
              reports:
                  (_perkebunanData?['aktivitasTerbaru'] as List<dynamic>? ?? [])
                      .map((aktivitas) => {
                            'text': aktivitas['judul'] ?? '-',
                            'time': aktivitas['createdAt'],
                            'icon': aktivitas['userAvatarUrl'] ?? '-',
                            'tipe': aktivitas['tipe'] ?? 'unknown',
                            'jenisBudidaya':
                                aktivitas['jenisBudidayaTipe'] ?? 'unknown',
                            'id': aktivitas['id'],
                          })
                      .toList(),
              onViewAll: () => context.push('/riwayat-aktivitas').then((_) {
                _fetchData(isRefresh: true);
              }),
              onItemTap: (context, item) {
                navigateToDetailLaporan(context,
                    idLaporan: item['id'],
                    jenisLaporan: item['tipe'],
                    jenisBudidaya: item['jenisBudidaya']);
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftarKebunPerkebunan'),
              title: 'Daftar Kebun',
              items: (_perkebunanData?['daftarKebun'] as List<dynamic>? ?? [])
                  .map((kebun) => {
                        'id': kebun['id'],
                        'name': kebun['nama'],
                        'category': kebun['JenisBudidaya']['nama'],
                        'icon': kebun['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-kebun/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () => context.push('/manajemen-kebun').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftarTanamanPerkebunan'),
              title: 'Daftar Jenis Tanaman',
              items: (_perkebunanData?['daftarTanaman'] as List<dynamic>? ?? [])
                  .map((tanaman) => {
                        'id': tanaman['id'],
                        'name': tanaman['nama'],
                        'isActive': tanaman['status'],
                        'icon': tanaman['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-tanaman/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () =>
                  context.push('/manajemen-jenis-tanaman').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftarKomoditasPerkebunan'),
              title: 'Daftar Komoditas',
              items:
                  (_perkebunanData?['daftarKomoditas'] as List<dynamic>? ?? [])
                      .map((komoditas) => {
                            'id': komoditas['id'],
                            'name': komoditas['nama'],
                            'category': komoditas['JenisBudidaya']['nama'],
                            'icon': komoditas['gambar'],
                          })
                      .toList(),
              type: 'basic',
              onViewAll: () => context.push('/manajemen-komoditas').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 80),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Gagal memuat data perkebunan.",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('perkebunanErrorText')),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: const Key('retryPerkebunanButton'),
                      onPressed: () => _fetchData(isRefresh: true),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildPeternakanContent() {
    if (_isLoading && _peternakanData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_isLoading && _peternakanData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gagal memuat data peternakan.",
                style: regular12.copyWith(color: dark2),
                key: const Key('peternakanErrorText')),
            const SizedBox(height: 10),
            ElevatedButton(
              key: const Key('retryPeternakanButton'),
              onPressed: () => _fetchData(isRefresh: true),
              child: const Text("Coba Lagi"),
            )
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshIndicatorPeternakanKey,
      onRefresh: () => _fetchData(isRefresh: true),
      color: green1,
      backgroundColor: white,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          if (_peternakanData != null) ...[
            DashboardGrid(
              title: 'Statistik Peternakan Bulan Ini',
              type: DashboardGridType.basic,
              onViewAll: () {
                context.push('/report').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              items: [
                DashboardItem(
                  title: 'Jumlah Ternak',
                  value: _peternakanData?['jumlahTernak'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green3,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jenis Ternak',
                  value: _peternakanData?['jenisTernak'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
                DashboardItem(
                  title: 'Ternak Mati',
                  value: _peternakanData?['jumlahKematian'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
                DashboardItem(
                  title: 'Laporan Panen',
                  value: _peternakanData?['jumlahPanen'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
                ),
              ],
              crossAxisCount: 2,
              valueFontSize: 60,
            ),
            const SizedBox(height: 12),
            MenuGrid(
              title: 'Menu Aplikasi Peternakan',
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              menuItems: [
                MenuItem(
                  title: 'Manajemen Kandang',
                  icon: 'set/farm-filled.png',
                  backgroundColor: Colors.brown,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-kandang').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Jenis Ternak',
                  icon: 'set/chicken-filled.png',
                  backgroundColor: Colors.orange,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-ternak').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Komoditas',
                  icon: 'set/dozenEggs-filled.png',
                  backgroundColor: Colors.teal,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-komoditas').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewestReports(
              key: const Key('aktivitasTerbaruPeternakan'),
              title: 'Aktivitas Terbaru',
              reports:
                  (_peternakanData?['aktivitasTerbaru'] as List<dynamic>? ?? [])
                      .map((aktivitas) => {
                            'id': aktivitas['id'],
                            'text': aktivitas['judul'] ?? '-',
                            'time': aktivitas['createdAt'],
                            'icon': aktivitas['userAvatarUrl'] ?? '-',
                            'tipe': aktivitas['tipe'] ?? 'unknown',
                            'jenisBudidaya':
                                aktivitas['jenisBudidayaTipe'] ?? 'unknown',
                          })
                      .toList(),
              onViewAll: () => context.push('/riwayat-aktivitas').then((_) {
                _fetchData(isRefresh: true);
              }),
              onItemTap: (context, item) {
                navigateToDetailLaporan(context,
                    idLaporan: item['id'],
                    jenisLaporan: item['tipe'],
                    jenisBudidaya: item['jenisBudidaya']);
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftarKandangPeternakan'),
              title: 'Daftar Kandang',
              items: (_peternakanData?['daftarKandang'] as List<dynamic>? ?? [])
                  .map((kandang) => {
                        'id': kandang['id'],
                        'name': kandang['nama'],
                        'category': kandang['JenisBudidaya']['nama'],
                        'icon': kandang['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-kandang/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () => context.push('/manajemen-kandang').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftarTernakPeternakan'),
              title: 'Daftar Jenis Ternak',
              items: (_peternakanData?['daftarTernak'] as List<dynamic>? ?? [])
                  .map((ternak) => {
                        'id': ternak['id'],
                        'name': ternak['nama'],
                        'isActive': ternak['status'],
                        'icon': ternak['gambar'],
                      })
                  .toList(),
              type: 'basic',
              onItemTap: (context, item) {
                final id = item['id'] ?? '';
                context.push('/detail-ternak/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
              onViewAll: () => context.push('/manajemen-ternak').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 12),
            ListItem(
              key: const Key('daftarKomoditasPeternakan'),
              title: 'Daftar Komoditas',
              items:
                  (_peternakanData?['daftarKomoditas'] as List<dynamic>? ?? [])
                      .map((komoditas) => {
                            'id': komoditas['id'],
                            'name': komoditas['nama'],
                            'category': komoditas['JenisBudidaya']['nama'],
                            'icon': komoditas['gambar'],
                          })
                      .toList(),
              type: 'basic',
              onViewAll: () => context.push('/manajemen-komoditas').then((_) {
                _fetchData(isRefresh: true);
              }),
            ),
            const SizedBox(height: 80),
          ] else if (!_isLoading) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Gagal memuat data peternakan.",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('peternakanErrorText')),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: const Key('retryPeternakanButton'),
                      onPressed: () => _fetchData(isRefresh: true),
                      child: const Text("Coba Lagi"),
                    )
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 0,
              titleSpacing: 0,
              toolbarHeight: 80,
              title: const Header(headerType: HeaderType.basic)),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: _userRole == "pjawab"
            ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      if (_selectedTabIndex == 0) {
                        // Perkebunan
                        return Container(
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Aksi Cepat",
                                  style: semibold16.copyWith(
                                    color: dark1,
                                  )),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, color: Color(0xFFE8E8E8)),
                              ListTile(
                                key: const Key('tambahKebun'),
                                leading: Image.asset(
                                  'assets/icons/set/hydroponics-filled.png',
                                  width: 30,
                                  color: green1,
                                ),
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
                              const Divider(
                                  height: 1, color: Color(0xFFE8E8E8)),
                              ListTile(
                                key: const Key('tambahTanaman'),
                                leading: Image.asset(
                                  'assets/icons/set/appleSeed-filled.png',
                                  width: 30,
                                  color: green1,
                                ),
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
                              const Divider(
                                  height: 1, color: Color(0xFFE8E8E8)),
                              ListTile(
                                key: const Key('tambahKomoditasTanaman'),
                                leading: Image.asset(
                                    'assets/icons/set/fruitbag-filled.png',
                                    width: 30,
                                    color: green1),
                                title: const Text("Tambah Komoditas Tanaman"),
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
                        // Peternakan
                        return Container(
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Aksi Cepat",
                                style: semibold16.copyWith(
                                  color: dark1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(
                                  height: 1, color: Color(0xFFE8E8E8)),
                              ListTile(
                                key: const Key('tambahKandang'),
                                leading: Image.asset(
                                  'assets/icons/set/farm-filled.png',
                                  width: 30,
                                  color: green1,
                                ),
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
                              const Divider(
                                  height: 1, color: Color(0xFFE8E8E8)),
                              ListTile(
                                key: const Key('tambahTernak'),
                                leading: Image.asset(
                                  'assets/icons/set/chicken-filled.png',
                                  width: 30,
                                  color: green1,
                                ),
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
                              const Divider(
                                  height: 1, color: Color(0xFFE8E8E8)),
                              ListTile(
                                key: const Key('tambahKomoditasTernak'),
                                leading: Image.asset(
                                  'assets/icons/set/dozenEggs-filled.png',
                                  width: 30,
                                  color: green1,
                                ),
                                title: const Text("Tambah Komoditas Ternak"),
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
              )
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: _isLoading &&
                      (_perkebunanData == null || _peternakanData == null)
                  ? const Center(child: CircularProgressIndicator())
                  : NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          const SliverToBoxAdapter(
                            child: BannerWidget(
                              title:
                                  'Kelola Perkebunan dan Peternakan dengan FarmCenter.',
                              subtitle:
                                  'Pantau, lapor, dan tingkatkan hasil panen produk budidaya mu!',
                              showDate: true,
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(
                              Container(
                                color: Colors.white,
                                child: Tabs(
                                  key: const Key('homeTabs'),
                                  onTabChanged: _onTabChanged,
                                  selectedIndex: _selectedTabIndex,
                                  tabTitles: tabList,
                                ),
                              ),
                              60.0,
                            ),
                            pinned: true,
                          ),
                        ];
                      },
                      body: Column(
                        children: [
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
                                _buildPerkebunanContent(),
                                _buildPeternakanContent(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._child, this._height);

  final Widget _child;
  final double _height;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: _child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return oldDelegate._child != _child || oldDelegate._height != _height;
  }
}
