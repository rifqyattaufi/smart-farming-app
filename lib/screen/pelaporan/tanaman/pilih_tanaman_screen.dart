import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihTanamanScreen extends StatelessWidget {
  const PilihTanamanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> listTanaman = [
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
    ];

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
            title: 'Menu Pelaporan', //or 'Pelaporan Khusus'
            greeting:
                'Pelaporan Harian', //or 'Pelaporan Tanaman Sakit' or 'Pelaporan Tanaman Mati' or 'Pelaporan Nutrisi Tanaman'
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const BannerWidget(
              title: 'Step 2 - Pilih Tanaman',
              subtitle: 'Pilih tanaman yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItemSelectable(
              title: 'Daftar Tanaman', // or 'Pelaporan Per Tanaman'
              type: ListItemType.basic,
              items: listTanaman,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            context.push('/pelaporan-harian-tanaman');
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
