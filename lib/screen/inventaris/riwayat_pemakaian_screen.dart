import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/theme.dart';

class RiwayatPemakaianScreen extends StatefulWidget {
  const RiwayatPemakaianScreen({super.key});

  @override
  State<RiwayatPemakaianScreen> createState() => _RiwayatPemakaianScreenState();
}

class _RiwayatPemakaianScreenState extends State<RiwayatPemakaianScreen> {
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
      final data = await _inventarisService.getRiwayatPenggunaanInventaris();
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
              headerType: HeaderType.back,
              title: 'Manajemen Inventaris',
              greeting: 'Riwayat Pemakaian Inventaris'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-pemakaian-inventaris');
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
                        onItemTap: (context, item) {
                          final name = item['name'] ?? '';
                          context.push('/detail-laporan/$name');
                        },
                      ),
                      const SizedBox(height: 12),
                      ListItem(
                        title: 'Semua Riwayat Pemakaian',
                        type: 'history',
                        items: (_inventarisData?['daftarPemakaian']
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
