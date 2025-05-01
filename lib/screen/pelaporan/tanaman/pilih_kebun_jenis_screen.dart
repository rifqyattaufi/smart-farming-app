import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class PilihKebunJenisScreen extends StatelessWidget {
  const PilihKebunJenisScreen({super.key});

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
              title: 'Pelaporan Khusus',
              greeting: 'Pelaporan Nutrisi Tanaman'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const BannerWidget(
              title: 'Step 1 - Pilih Kebun/Jenis Tanaman',
              subtitle:
                  'Pilih kebun/jenis tanaman yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItem(
              title: 'Daftar Kebun',
              items: const [
                {
                  'name': 'Kebun A',
                  'category': 'Melon',
                  'icon': 'assets/icons/goclub.svg',
                },
                {
                  'name': 'Kebun B',
                  'category': 'Anggur',
                  'icon': 'assets/icons/goclub.svg',
                },
              ],
              type: 'basic',
              onItemTap: (context, item) {
                final name = item['name'] ?? '';
                context.push('/detail-laporan/$name');
              },
            ),
            const SizedBox(height: 12),
            ListItem(
              title: 'Pelaporan Per Jenis Tanaman',
              items: const [
                {
                  'name': 'Melon',
                  'category': 'Kebun A',
                  'icon': 'assets/icons/goclub.svg',
                },
                {
                  'name': 'Anggur',
                  'category': 'Kebun B',
                  'icon': 'assets/icons/goclub.svg',
                },
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            context.push('/pelaporan-nutrisi-tanaman');
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
