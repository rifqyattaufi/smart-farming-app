import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchInventarisData();
  }

  Future<void> _fetchInventarisData() async {
    try {
      final data = await _inventarisService.getDashboardInventaris();
      setState(() {
        _inventarisData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
          onPressed: () {
            showModalBottomSheet(
              context: context,
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
                        title: const Text("Tambah Pemakaian Inventaris"),
                        onTap: () {
                          context.push('/tambah-pemakaian-inventaris');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      ListTile(
                        leading: Icon(Icons.pets_outlined, color: green1),
                        title: const Text("Tambah Inventaris"),
                        onTap: () {
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
                        leading: Icon(Icons.category_outlined, color: green1),
                        title: const Text("Kategori Inventaris"),
                        onTap: () {
                          context.push('/kategori-inventaris');
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
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardGrid(
                        title: 'Statistik Inventaris Bulan Ini',
                        items: [
                          DashboardItem(
                              title: 'Total Item',
                              value: _inventarisData?['totalItem'].toString() ??
                                  '0',
                              icon: 'other',
                              bgColor: green3,
                              iconColor: yellow),
                          DashboardItem(
                              title: 'Stok Rendah',
                              value:
                                  _inventarisData?['stokRendah'].toString() ??
                                      '0',
                              icon: 'other',
                              bgColor: red2,
                              iconColor: red),
                          DashboardItem(
                              title: 'Item Baru',
                              value: _inventarisData?['itemBaru'].toString() ??
                                  '0',
                              icon: 'other',
                              bgColor: green4,
                              iconColor: green2),
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
                        tanggal: DateTime.now(),
                      ),
                      const SizedBox(height: 12),
                      ListItem(
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
                                })
                            .toList(),
                        onViewAll: () =>
                            context.push('/riwayat-pemakaian-inventaris'),
                        onItemTap: (context, item) {
                          final name = item['name'] ?? '';
                          context.push('/detail-laporan/$name');
                        },
                      ),
                      const SizedBox(height: 12),
                      ListItem(
                        title: 'Daftar Inventaris',
                        items: (_inventarisData?['daftarInventaris']
                                    as List<dynamic>? ??
                                [])
                            .map((item) => {
                                  'id': item['id'],
                                  'name': item['nama'],
                                  'icon': item['gambar'],
                                  'category':
                                      'Stok: ${item['jumlah']} ${item['lambangSatuan']}',
                                })
                            .toList(),
                        type: 'basic',
                        onViewAll: () => context.push('/inventaris'),
                        onItemTap: (context, item) {
                          final name = item['name'] ?? '';
                          context.push('/detail-laporan/$name');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
