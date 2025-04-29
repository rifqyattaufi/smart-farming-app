import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/dashboard_grid.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/ringkasan_inv.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

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
                          context.push('/tambah-inventaris');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                      ListTile(
                        leading: Icon(Icons.category_outlined, color: green1),
                        title: const Text("Tambah Kategori Inventaris"),
                        onTap: () {
                          context.push('/tambah-kategori-inventaris');
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
      body: SafeArea(
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
                        value: '33',
                        icon: 'other',
                        bgColor: green3,
                        iconColor: yellow),
                    DashboardItem(
                        title: 'Stok Rendah',
                        value: '3',
                        icon: 'other',
                        bgColor: red2,
                        iconColor: red),
                    DashboardItem(
                        title: 'Item Baru',
                        value: '3',
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
                  totalItem: 33,
                  kategoriInventaris: 4,
                  seringDigunakan: 2,
                  jarangDigunakan: 2,
                  itemTersedia: 28,
                  stokRendah: 3,
                  itemBaru: 2,
                  tanggal: DateTime(2025, 2, 17, 8, 20),
                ),
                const SizedBox(height: 12),
                ListItem(
                  title: "Riwayat Pemakaian Terbaru",
                  type: "history",
                  items: const [
                    {
                      'name': 'Pupuk NPK',
                      'category': 'Pupuk',
                      'image': 'assets/images/pupuk.jpg',
                      'person': 'Pak Budi',
                      'date': '22 Apr 2025',
                      'time': '10:45',
                    },
                    {
                      'name': 'Disinfektan A',
                      'category': 'Disinfektan',
                      'image': 'assets/images/pupuk.jpg',
                      'person': 'Bu Sari',
                      'date': '21 Apr 2025',
                      'time': '14:30',
                    },
                  ],
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
                  items: const [
                    {
                      'name': 'Bibit Melon',
                      'category': 'Stok: 20 Pack',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'name': 'Pupuk A',
                      'category': 'Stok: 10 Kg',
                      'icon': 'assets/icons/goclub.svg',
                    }
                  ],
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
