import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/screen/kategory_inv/add_kategori_inv_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/menus.dart';
import 'package:smart_farming_app/widget/ringkasan_inv.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventarisService _inventarisService = InventarisService();
  Map<String, dynamic>? _inventarisData;
  bool _isLoading = true;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchInventarisData(isRefresh: false);
  }

  Future<void> _fetchInventarisData({bool isRefresh = false}) async {
    if (!isRefresh && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final data = await _inventarisService.getDashboardInventaris();
      if (mounted) {
        setState(() {
          _inventarisData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showAppToast(
          context,
          'Gagal memuat data inventaris. Silakan coba lagi.',
        );
      }
    }
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
              greeting: 'Inventaris'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          key: const Key('tambah_inventaris'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Container(
                  decoration: BoxDecoration(
                    color: white, // Ganti sesuai warna yang kamu mau
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
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
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      ListTile(
                        key: const Key('tambah_pemakaian_inventaris'),
                        leading: Image.asset(
                          'assets/icons/set/history.png',
                          width: 30,
                          color: green1,
                        ),
                        title: const Text("Tambah Pemakaian Inventaris"),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/tambah-pemakaian-inventaris');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      ListTile(
                        key: const Key('tambah_inventaris'),
                        leading: Image.asset(
                          'assets/icons/set/box-filled.png',
                          width: 30,
                          color: green1,
                        ),
                        title: const Text("Tambah Inventaris"),
                        onTap: () {
                          Navigator.pop(context);
                          context.push(
                            '/tambah-inventaris',
                            extra: AddInventarisScreen(
                              isEdit: false,
                              onInventarisAdded: _fetchInventarisData,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      ListTile(
                        key: const Key('tambah_kategori_inventaris'),
                        leading: Image.asset(
                          'assets/icons/set/category.png',
                          width: 30,
                          color: green1,
                        ),
                        title: const Text("Tambah Kategori Inventaris"),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/tambah-kategori-inventaris',
                              extra: AddKategoriInvScreen(
                                isUpdate: false,
                                id: '',
                                nama: '',
                                onKategoriInvAdded: _fetchInventarisData,
                              ));
                        },
                      ),
                    ],
                  ),
                );
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
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () => _fetchInventarisData(isRefresh: true),
                color: green1,
                backgroundColor: white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          kBottomNavigationBarHeight -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_inventarisData != null) ...[
                          DashboardGrid(
                            title: 'Statistik Inventaris Bulan Ini',
                            items: [
                              DashboardItem(
                                  title: 'Total Item',
                                  value: _inventarisData?['totalItem']
                                          .toString() ??
                                      '0',
                                  icon: 'assets/icons/set/boxes.png',
                                  bgColor: green3,
                                  iconColor: yellow),
                              DashboardItem(
                                  title: 'Stok Rendah',
                                  value: _inventarisData?['stokRendah']
                                          .toString() ??
                                      '0',
                                  icon: 'assets/icons/set/box-remove.png',
                                  bgColor: yellow1,
                                  iconColor: yellow2),
                              DashboardItem(
                                  title: 'Stok Habis',
                                  value: _inventarisData?['stokHabis']
                                          .toString() ??
                                      '0',
                                  icon: 'assets/icons/set/empty-box.png',
                                  bgColor: red2,
                                  iconColor: red),
                            ],
                            crossAxisCount: 3,
                            valueFontSize: 32,
                            titleFontSize: 14,
                            paddingSize: 10,
                            iconsWidth: 36,
                          ),
                          const SizedBox(height: 12),
                          RingkasanInv(
                            totalItem: _inventarisData?['totalItem'] ?? 0,
                            kategoriInventaris:
                                _inventarisData?['totalKategori'] ?? 0,
                            seringDigunakan:
                                _inventarisData?['seringDigunakanCount'] ?? 0,
                            jarangDigunakan:
                                _inventarisData?['jarangDigunakanCount'] ?? 0,
                            itemTersedia: _inventarisData?['itemTersedia'] ?? 0,
                            stokRendah: _inventarisData?['stokRendah'] ?? 0,
                            itemBaru: _inventarisData?['itemBaru'] ?? 0,
                          ),
                          const SizedBox(height: 12),
                          MenuGrid(
                            title: 'Menu Inventaris',
                            crossAxisCount: 4,
                            mainAxisSpacing: 8,
                            menuItems: [
                              MenuItem(
                                title: 'Kategori Inventaris',
                                icon: 'set/category.png',
                                backgroundColor: Colors.orange,
                                iconColor: Colors.white,
                                onTap: () => context
                                    .push('/kategori-inventaris')
                                    .then((_) {
                                  _fetchInventarisData(isRefresh: true);
                                }),
                              ),
                              MenuItem(
                                title: 'Manajemen Inventaris',
                                icon: 'set/box-filled.png',
                                backgroundColor: Colors.brown,
                                iconColor: Colors.white,
                                onTap: () =>
                                    context.push('/inventaris').then((_) {
                                  _fetchInventarisData(isRefresh: true);
                                }),
                              ),
                              MenuItem(
                                title: 'Riwayat Pemakaian',
                                icon: 'set/history.png',
                                backgroundColor: Colors.blue,
                                iconColor: Colors.white,
                                onTap: () => context
                                    .push('/riwayat-pemakaian-inventaris')
                                    .then((_) {
                                  _fetchInventarisData(isRefresh: true);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ListItem(
                            key: const Key('riwayat_pemakaian_terbaru'),
                            title: 'Riwayat Pemakaian Terbaru',
                            type: 'history',
                            items: (_inventarisData?['daftarPemakaianTerbaru']
                                        as List<dynamic>? ??
                                    [])
                                .map((item) => {
                                      'id': item['id'],
                                      'name': item['inventarisNama'],
                                      'image': item['laporanGambar'],
                                      'person': item['petugasNama'],
                                      'date': item['laporanTanggal'],
                                      'time': item['laporanWaktu'],
                                      'laporanId': item['laporanId'],
                                      'sourceTable': item['sourceTable'],
                                    })
                                .toList(),
                            onViewAll: () =>
                                context.push('/riwayat-pemakaian-inventaris'),
                            onItemTap: (context, item) {
                              final id = item['id'] ?? '';
                              final laporanId = item['laporanId'] ?? '';
                              if (item['sourceTable'] == 'vitamin') {
                                context
                                    .push('/detail-laporan-nutrisi/$laporanId');
                              } else {
                                context
                                    .push('/detail-pemakaian-inventaris/$id');
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          ListItem(
                            title: 'Daftar Inventaris',
                            key: const Key('daftar_inventaris'),
                            items: (_inventarisData?['daftarInventaris']
                                        as List<dynamic>? ??
                                    [])
                                .map((item) => {
                                      'id': item['id'],
                                      'name': item['nama'] ?? 'N/A',
                                      'icon': item['gambar'] as String?,
                                      'category':
                                          'Stok: ${formatNumber(item['jumlah'])} ${item['lambangSatuan'] ?? ''}',
                                    })
                                .toList(),
                            type: 'basic',
                            onViewAll: () => context.push('/inventaris'),
                            onItemTap: (context, item) {
                              final id = item['id'] ?? '';
                              context.push('/detail-inventaris/$id').then((_) {
                                _fetchInventarisData();
                              });
                            },
                          ),
                          const SizedBox(height: 40),
                        ] else if (!_isLoading) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Gagal memuat data dashboard.",
                                      style: regular12.copyWith(color: dark2),
                                      key: const Key('error_message')),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    key: const Key('retry_button'),
                                    onPressed: () =>
                                        _fetchInventarisData(isRefresh: true),
                                    child: const Text("Coba Lagi"),
                                  )
                                ],
                              ),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
