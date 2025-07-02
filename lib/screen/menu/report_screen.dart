import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/chart_widget.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DashboardService _dashboardService = DashboardService();
  final HamaService _hamaService = HamaService();

  Map<String, dynamic>? _perkebunanData;
  Map<String, dynamic>? _peternakanData;
  List<dynamic> _laporanHamaList = [];
  bool _isLoading = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPerkebunanKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorPeternakanKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData(isRefresh: false);
  }

  Future<void> _fetchData({isRefresh = false}) async {
    if (!isRefresh && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _dashboardService.getDashboardPerkebunan(),
        _dashboardService.getDashboardPeternakan(),
        _hamaService.getLaporanHama(),
      ]);

      if (!mounted) return;
      setState(() {
        _perkebunanData = results[0];
        _peternakanData = results[1];
        _laporanHamaList = results[2]['data'] ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Method untuk menghitung statistik laporan hama
  Map<String, dynamic> _calculateHamaStatistics() {
    if (_laporanHamaList.isEmpty) {
      return {
        'jenisHamaStats': <ChartData>[],
        'totalLaporan': 0,
        'jenisHamaCount': 0,
      };
    }

    // Hitung frekuensi per jenis hama
    final Map<String, int> jenisHamaCount = {};

    for (final laporan in _laporanHamaList) {
      final jenisHama = laporan['Hama']?['JenisHama'];
      if (jenisHama != null && jenisHama['nama'] != null) {
        final namaJenis = jenisHama['nama'] as String;
        jenisHamaCount[namaJenis] = (jenisHamaCount[namaJenis] ?? 0) + 1;
      }
    }

    // Konversi ke ChartData dengan warna yang berbeda
    final List<Color> colors = [
      green2,
      green1,
      yellow,
      red,
      Colors.purple,
      Colors.orange
    ];
    final List<ChartData> jenisHamaStats = [];

    int colorIndex = 0;
    jenisHamaCount.entries.forEach((entry) {
      jenisHamaStats.add(ChartData(
        label: entry.key,
        value: entry.value,
        color: colors[colorIndex % colors.length],
      ));
      colorIndex++;
    });

    // Urutkan berdasarkan nilai tertinggi
    jenisHamaStats.sort((a, b) => b.value.compareTo(a.value));

    return {
      'jenisHamaStats': jenisHamaStats,
      'totalLaporan': _laporanHamaList.length,
      'jenisHamaCount': jenisHamaCount.length,
    };
  }

  // Method untuk menghitung statistik komoditas
  List<ChartData> _calculateKomoditasStatistics(List<dynamic> komoditasList) {
    if (komoditasList.isEmpty) {
      return [];
    }

    final List<Color> colors = [
      green2,
      green1,
      yellow,
      red,
      Colors.purple,
      Colors.orange
    ];
    final List<ChartData> komoditasStats = [];

    for (int i = 0; i < komoditasList.length && i < 6; i++) {
      final komoditas = komoditasList[i];
      komoditasStats.add(ChartData(
        label: komoditas['nama'] ?? 'N/A',
        value: komoditas['jumlah'] ?? 0,
        color: colors[i % colors.length],
      ));
    }

    return komoditasStats;
  }

  Widget _buildPerkebunanContent() {
    if (!_isLoading && _perkebunanData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gagal memuat data perkebunan.",
                style: regular12.copyWith(color: dark2),
                key: const Key('no_data_found')),
            const SizedBox(height: 10),
            ElevatedButton(
              key: const Key('retry_button'),
              onPressed: () {
                _fetchData(isRefresh: true);
              },
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
              items: [
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Jenis Tanaman Budidaya',
                  value: _perkebunanData?['jenisTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: blue3,
                  iconColor: blue1,
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
                  bgColor: yellow1,
                  iconColor: yellow,
                ),
                DashboardItem(
                  title: 'Tanaman',
                  value: _perkebunanData?['jumlahTanaman'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green4,
                  iconColor: green2,
                ),
                DashboardItem(
                  title: 'Tanaman Sakit',
                  value: _perkebunanData?['jumlahSakit'].toString() ?? '-',
                  icon: 'other',
                  bgColor: red2,
                  iconColor: red,
                ),
              ],
              crossAxisCount: 3,
              valueFontSize: 32,
              titleFontSize: 13.5,
              paddingSize: 10,
              iconsWidth: 36,
            ),
            const SizedBox(height: 12),
            ListItem(
              title: 'Hasil Laporan Per Jenis Tanaman',
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
                context.push('/statistik-laporan-tanaman/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
            ),
            () {
              final komoditasList =
                  _perkebunanData?['daftarKomoditas'] as List<dynamic>? ?? [];
              final komoditasStats =
                  _calculateKomoditasStatistics(komoditasList);

              if (komoditasStats.isNotEmpty) {
                return Column(
                  children: [
                    ChartWidget(
                      title: 'Statistik Jumlah Hasil Panen',
                      data: komoditasStats,
                      height: 180,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }(),
            ListItem(
              title: 'Hasil Komoditas Perkebunan',
              items:
                  (_perkebunanData?['daftarKomoditas'] as List<dynamic>? ?? [])
                      .map((tanaman) => {
                            'id': tanaman['id'],
                            'name': tanaman['nama'],
                            'category':
                                'Hasil panen: ${tanaman['jumlah']} ${tanaman['Satuan']?['lambang']}',
                            'icon': tanaman['gambar'],
                          })
                      .toList(),
              type: 'basic',
              onItemTap: (context, tanaman) {
                final id = tanaman['id'] as String?;
                if (id != null && id.isNotEmpty) {
                  context.push('/detail-komoditas/$id').then((_) {
                    _fetchData(isRefresh: true);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            () {
              final hamaStats = _calculateHamaStatistics();
              return Column(
                children: [
                  // Grid statistik ringkasan
                  DashboardGrid(
                    title: 'Ringkasan Laporan Hama',
                    items: [
                      DashboardItem(
                        title: 'Total Laporan',
                        value: hamaStats['totalLaporan'].toString(),
                        icon: 'other',
                        bgColor: red2,
                        iconColor: red,
                      ),
                      DashboardItem(
                        title: 'Jenis Hama',
                        value: hamaStats['jenisHamaCount'].toString(),
                        icon: 'other',
                        bgColor: yellow1,
                        iconColor: yellow,
                      ),
                    ],
                    crossAxisCount: 2,
                    valueFontSize: 60,
                  ),
                  ChartWidget(
                    title: 'Statistik Laporan Hama per Jenis',
                    data: hamaStats['jenisHamaStats'] as List<ChartData>,
                    height: 180,
                  ),
                ],
              );
            }(),
            ListItem(
              title: 'Laporan Hama Terbaru',
              type: 'history',
              personLabel: 'Pelaporan oleh',
              items: _laporanHamaList.map((laporan) {
                final jenisHama = laporan['Hama']?['JenisHama'];
                final unitBudidaya = laporan['UnitBudidaya'];
                final user = laporan['user'];

                final String tgl;
                final String waktu;
                if (laporan['createdAt'] != null) {
                  final dateTime = DateTime.parse(laporan['createdAt']);
                  tgl = DateFormat('EEEE, dd MMM yyyy').format(dateTime);
                  waktu = DateFormat('HH:mm').format(dateTime);
                } else {
                  tgl = 'N/A';
                  waktu = 'N/A';
                }

                // Membangun string kategori dengan lebih aman
                final kategoriParts = <String>[];
                if (jenisHama?['nama'] != null) {
                  kategoriParts.add("Jenis Hama: ${jenisHama['nama']}");
                }
                if (unitBudidaya?['nama'] != null) {
                  kategoriParts.add("Lokasi: ${unitBudidaya['nama']}");
                }
                if (laporan['Hama']?['jumlah'] != null) {
                  kategoriParts.add("Jumlah: ${laporan['Hama']['jumlah']}");
                }
                final kategori = kategoriParts.join('\n');

                return {
                  'name':
                      laporan['judul'] ?? jenisHama?['nama'] ?? 'Laporan Hama',
                  'category':
                      kategori.isNotEmpty ? kategori : 'Detail tidak tersedia',
                  'image':
                      laporan['gambar'] ?? 'assets/images/placeholder_hama.png',
                  'person': user?['name'] ?? 'Petugas Tidak Diketahui',
                  'date': tgl,
                  'time': waktu,
                  'id': laporan['id'],
                };
              }).toList(),
              onItemTap: (context, item) {
                final id = item['id'] as String?;
                if (id != null) {
                  // Pastikan route '/detail-laporan-hama/$id' sudah terdaftar di GoRouter
                  context.push('/detail-laporan-hama/$id').then((_) {
                    _fetchData(isRefresh: true);
                  });
                }
              },
            ),
            const SizedBox(height: 24),
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
    if (!_isLoading && _peternakanData == null) {
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
              type: DashboardGridType.none,
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
            ListItem(
              title: 'Hasil Laporan Per Jenis Ternak',
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
                context.push('/statistik-laporan-ternak/$id').then((_) {
                  _fetchData(isRefresh: true);
                });
              },
            ),
            const SizedBox(height: 12),
            // Chart Komoditas Peternakan
            () {
              final komoditasList =
                  _peternakanData?['daftarKomoditas'] as List<dynamic>? ?? [];
              final komoditasStats =
                  _calculateKomoditasStatistics(komoditasList);

              if (komoditasStats.isNotEmpty) {
                return Column(
                  children: [
                    ChartWidget(
                      title: 'Statistik Jumlah Hasil Panen',
                      data: komoditasStats,
                      height: 180,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }
              return const SizedBox.shrink();
            }(),
            ListItem(
              title: 'Hasil Komoditas Peternakan',
              items:
                  (_peternakanData?['daftarKomoditas'] as List<dynamic>? ?? [])
                      .map((ternak) => {
                            'id': ternak['id'],
                            'name': ternak['nama'],
                            'category':
                                'Hasil panen: ${ternak['jumlah']} ${ternak['Satuan']?['lambang']}',
                            'icon': ternak['gambar'],
                          })
                      .toList(),
              type: 'basic',
              onItemTap: (context, ternak) {
                final id = ternak['id'] as String?;
                if (id != null && id.isNotEmpty) {
                  context.push('/detail-komoditas/$id').then((_) {
                    _fetchData(isRefresh: true);
                  });
                }
              },
            ),
            const SizedBox(height: 24),
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
