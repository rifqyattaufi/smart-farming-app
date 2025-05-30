import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:toastification/toastification.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
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
      ]);

      if (!mounted) return;
      setState(() {
        _perkebunanData = results[0];
        _peternakanData = results[1];
        if (isRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Data berhasil diperbarui!'),
                backgroundColor: green1),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  Widget _buildPerkebunanContent() {
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
            DashboardGrid(
              title: 'Statistik Perkebunan Bulan Ini',
              type: DashboardGridType.none,
              items: [
                DashboardItem(
                  title: 'Suhu (°C)',
                  value: _perkebunanData?['suhu'].toString() ?? '-',
                  icon: 'other',
                  bgColor: green3,
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
            ElevatedButton(
              onPressed: () {
                toastification.show(
                  context:
                      context, // Diperlukan untuk membangun widget default jika type bukan custom
                  title: const Text('Halo dari Toastification! 👋'),
                  description:
                      const Text('Ini adalah notifikasi toast sederhana.'),
                  type: ToastificationType
                      .success, // Jenis toast (success, info, warning, error)
                  style: ToastificationStyle
                      .flat, // Gaya toast (flat, filled, outlined)
                  autoCloseDuration:
                      const Duration(seconds: 5), // Durasi toast ditampilkan
                  alignment: Alignment.topCenter, // Opsional: Atur posisi
                  // animationBuilder: (context, animation, alignment, child) { // Opsional: Kustomisasi animasi
                  //   return ScaleTransition(scale: animation, child: child);
                  // },
                  // icon: const Icon(Icons.check), // Opsional: Ikon kustom
                  // primaryColor: Colors.green, // Opsional: Warna utama
                  // backgroundColor: Colors.lightGreenAccent, // Opsional: Warna latar belakang
                  // foregroundColor: Colors.black, // Opsional: Warna teks
                  // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Opsional: Padding
                  // margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Opsional: Margin
                  // borderRadius: BorderRadius.circular(12), // Opsional: Border radius
                  // boxShadow: lowModeShadow, // Opsional: Bayangan
                  // showProgressBar: true, // Opsional: Tampilkan progress bar
                  // closeButtonShowType: CloseButtonShowType.onHover, // Opsional: Kapan tombol close ditampilkan
                  // closeOnClick: true, // Opsional: Tutup toast saat diklik
                  // pauseOnHover: true, // Opsional: Jeda auto-close saat di-hover
                  // dragToClose: true, // Opsional: Geser untuk menutup
                  // applyBlurEffect: true, // Opsional: Terapkan efek blur
                  // callbacks: ToastificationCallbacks( // Opsional: Callbacks
                  //   onTap: (toastItem) => print('Toast diketuk'),
                  //   onCloseButtonTap: (toastItem) => print('Tombol close diketuk'),
                  //   onAutoCompleteCompleted: (toastItem) => print('Auto close selesai'),
                  //   onDismissed: (toastItem) => print('Toast di-dismiss'),
                  // ),
                );
              },
              child: const Text('Tampilkan Toast'),
            ),
            const SizedBox(height: 12),
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
