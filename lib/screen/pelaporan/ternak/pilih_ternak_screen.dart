import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihTernakScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihTernakScreen(
      {super.key,
      this.data = const {},
      required this.greeting,
      required this.tipe,
      this.step = 1});

  @override
  State<PilihTernakScreen> createState() => _PilihTernakScreenState();
}

class _PilihTernakScreenState extends State<PilihTernakScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> listTernak = [
      {
        'name': 'Ayam #1',
        'category': 'Kandang A',
        'icon': 'assets/icons/goclub.svg',
      },
      {
        'name': 'Ayam #2',
        'category': 'Kandang A',
        'icon': 'assets/icons/goclub.svg',
      },
      {
        'name': 'Ayam #3',
        'category': 'Kandang A',
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
          title: Header(
            headerType: HeaderType.back,
            title: 'Menu Pelaporan', //or 'Pelaporan Khusus'
            greeting: widget.greeting,
            // 'Pelaporan Ternak Sakit', // or 'Pelaporan Kematian Ternak' or 'Pelaporan Nutrisi Ternak'
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Pilih Ternak',
              subtitle: 'Pilih ternak yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItemSelectable(
              title: 'Daftar Ternak', // or 'Pelaporan Per Ternak'
              type: ListItemType.basic,
              items: listTernak,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            context.push('/pelaporan-harian-ternak');
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
