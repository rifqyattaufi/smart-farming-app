import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_kandang_screen.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/menus.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/menu_card.dart';

class HomeScreenPetugas extends StatefulWidget {
  const HomeScreenPetugas({super.key});

  @override
  State<HomeScreenPetugas> createState() => _HomeScreenPetugasState();
}

class _HomeScreenPetugasState extends State<HomeScreenPetugas> {
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  bool _isLoading = true;

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
      final results = await Future.wait([
        _dashboardService.getDashboardPerkebunan(),
        _dashboardService.getDashboardPeternakan(),
      ]);

      if (!mounted) return;
      setState(() {
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
            const Text("Gagal memuat data perkebunan."),
            const SizedBox(height: 10),
            ElevatedButton(
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
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth / 2) - 24;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
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
                            context
                                .push('/pilih-kebun',
                                    extra: const PilihKebunScreen(
                                      greeting: "Pelaporan Harian",
                                      tipe: "harian",
                                    ))
                                .then((_) {
                              _fetchData(isRefresh: true);
                            });
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
                            context.push('/pelaporan-khusus-tanaman').then((_) {
                              _fetchData(isRefresh: true);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            MenuGrid(
              title: 'Menu Aplikasi Perkebunan',
              menuItems: [
                MenuItem(
                  title: 'Manajamen Kebun',
                  icon: Icons.warehouse,
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-kebun').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajamen Jenis Tanaman',
                  icon: Icons.yard,
                  backgroundColor: Colors.blue,
                  iconColor: Colors.white,
                  onTap: () =>
                      context.push('/manajemen-jenis-tanaman').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajamen Komoditas',
                  icon: Icons.inventory,
                  backgroundColor: Colors.cyan,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-komoditas').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Hama Kebun',
                  icon: Icons.pest_control,
                  backgroundColor: Colors.amber,
                  iconColor: Colors.white,
                  onTap: () => context.push('/laporan-hama'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            NewestReports(
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
                    const Text("Gagal memuat data perkebunan."),
                    const SizedBox(height: 10),
                    ElevatedButton(
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
            const Text("Gagal memuat data peternakan."),
            const SizedBox(height: 10),
            ElevatedButton(
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
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = (constraints.maxWidth / 2) - 24;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
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
                            context
                                .push('/pilih-kandang',
                                    extra: const PilihKandangScreen(
                                      greeting: "Pelaporan Harian",
                                      tipe: "harian",
                                    ))
                                .then((_) {
                              _fetchData(isRefresh: true);
                            });
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
                            context.push('/pelaporan-khusus-ternak').then((_) {
                              _fetchData(isRefresh: true);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            MenuGrid(
              title: 'Menu Aplikasi Peternakan',
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              menuItems: [
                MenuItem(
                  title: 'Manajemen Kandang',
                  icon: Icons.warehouse,
                  backgroundColor: Colors.brown,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-kandang').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Jenis Ternak',
                  icon: Icons.cruelty_free_rounded,
                  backgroundColor: Colors.orange,
                  iconColor: Colors.white,
                  onTap: () => context.push('/manajemen-ternak').then((_) {
                    _fetchData(isRefresh: true);
                  }),
                ),
                MenuItem(
                  title: 'Manajemen Komoditas',
                  icon: Icons.inventory,
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
                    const Text("Gagal memuat data peternakan."),
                    const SizedBox(height: 10),
                    ElevatedButton(
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
