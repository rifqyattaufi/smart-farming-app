import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihKandangScreen extends StatelessWidget {
  const PilihKandangScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<Map<String, String>> listKandang = [
      {
        'name': 'Kandang A',
        'category': 'Ayam',
        'icon': 'assets/icons/goclub.svg',
      },
      {
        'name': 'Kandang B',
        'category': 'Lele',
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
            greeting: 'Pelaporan Harian', //or 'Pelaporan Kematian Ternak' or 'Pelaporan Nutrisi Ternak' or 'Pelaporan Ternak Sakit' or 'Pelaporan Panen Ternak'
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const BannerWidget(
              title: 'Step 1 - Pilih Kandang',
              subtitle: 'Pilih kandang yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItemSelectable(
              title: 'Daftar Kandang',
              type: ListItemType.simple,
              items: listKandang,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            context.push('/pilih-ternak');
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
