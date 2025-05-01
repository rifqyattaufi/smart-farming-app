import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihKebunScreen extends StatelessWidget {
  const PilihKebunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> listKebun = [
      {
        'name': 'Kebun A',
        'category': 'Melon',
        'icon': 'assets/icons/goclub.svg',
      },
      {
        'name': 'Kebun B',
        'category': 'Anggur',
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
                'Pelaporan Harian', //or 'Pelaporan Hasil Panen' or 'Pelaporan Tanaman Sakit' or 'Pelaporan Tanaman Mati' or 'Pelaporan Nutrisi Tanaman'
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const BannerWidget(
              title: 'Step 1 - Pilih Kebun',
              subtitle: 'Pilih kebun yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItemSelectable(
              title: 'Daftar Kebun',
              type: ListItemType.simple,
              items: listKebun,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            context.push('/pilih-tanaman');
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
