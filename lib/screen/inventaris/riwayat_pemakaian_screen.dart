import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/theme.dart';

class RiwayatPemakaianScreen extends StatelessWidget {
  const RiwayatPemakaianScreen({super.key});

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
      body: SafeArea(
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
                  items: const [
                    {
                      'name': 'Pupuk NPK',
                      'category': 'Pupuk',
                      'image': 'assets/images/pupuk.jpg',
                      'person': 'Pak Budi',
                      'date': 'Senin, 22 Apr 2025',
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
                  onItemTap: (context, item) {
                    final name = item['name'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
                ),
                const SizedBox(height: 12),
                ListItem(
                  title: 'Semua Riwayat Pemakaian',
                  type: 'history',
                  items: const [
                    {
                      'name': 'Pupuk NPK',
                      'category': 'Pupuk',
                      'image': 'assets/images/pupuk.jpg',
                      'person': 'Pak Budi',
                      'date': 'Senin, 22 Apr 2025',
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
