import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class PilihTanamanScreen extends StatelessWidget {
  const PilihTanamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(
          headerType: HeaderType.menu,
          title: 'Menu Pelaporan',
          greeting: 'Pelaporan Harian',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
            bottom: 100), // kasih space bawah biar gak ketutupan tombol
        children: [
          const BannerWidget(
            title: 'Step 2 - Pilih Tanaman',
            subtitle: 'Pilih tanaman yang akan dilakukan pelaporan!',
            showDate: true,
          ),
          const SizedBox(height: 12),
          ListItem(
            title: 'Daftar Jenis Tanaman',
            items: const [
              {
                'name': 'Melon #1',
                'category': 'Kebun A',
                'icon': 'assets/icons/goclub.svg',
              },
              {
                'name': 'Melon #2',
                'category': 'Kebun A',
                'icon': 'assets/icons/goclub.svg',
              },
              {
                'name': 'Melon #3',
                'category': 'Kebun A',
                'icon': 'assets/icons/goclub.svg',
              }
            ],
            type: 'basic',
            onItemTap: (context, item) {
              final name = item['name'] ?? '';
              context.push('/detail-laporan/$name');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            // Your action here
          },
          buttonText: 'Selanjutnya',
          backgroundColor: green1,
          textStyle: semibold16,
          textColor: white,
        ),
      ),
    );
  }
}
