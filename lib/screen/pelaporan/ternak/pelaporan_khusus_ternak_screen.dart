import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_kandang_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_komoditas_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class PelaporanKhususTernakScreen extends StatefulWidget {
  const PelaporanKhususTernakScreen({super.key});

  @override
  State<PelaporanKhususTernakScreen> createState() =>
      _PelaporanKhususTernakScreenState();
}

class _PelaporanKhususTernakScreenState
    extends State<PelaporanKhususTernakScreen> {
  final _step = 1;
  String? selectedReport;

  void navigateBasedOnSelection() {
    switch (selectedReport) {
      case 'Pelaporan Panen Ternak':
        context.push('/pilih-komoditas',
            extra: PilihKomoditasScreen(
              step: _step + 1,
              tipe: 'panen',
              greeting: 'Pelaporan Panen Ternak',
            ));
        break;
      case 'Pelaporan Ternak Sakit':
        context.push('/pilih-kandang',
            extra: PilihKandangScreen(
              step: _step + 1,
              tipe: 'sakit',
              greeting: 'Pelaporan Ternak Sakit',
            ));
        break;
      case 'Pelaporan Kematian Ternak':
        context.push('/pilih-kandang',
            extra: PilihKandangScreen(
              step: _step + 1,
              tipe: 'kematian',
              greeting: 'Pelaporan Kematian Ternak',
            ));
        break;
      case 'Pelaporan Pemberian Nutrisi':
        context.push('/pilih-kandang',
            extra: PilihKandangScreen(
              step: _step + 1,
              tipe: 'vitamin',
              greeting: 'Pelaporan Pemberian Nutrisi',
            ));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> reports = [
      {
        'title': 'Pelaporan Panen Ternak',
        'description':
            'Catat hasil panen ternak untuk evaluasi dan perencanaan produksi yang lebih baik.',
      },
      {
        'title': 'Pelaporan Ternak Sakit',
        'description':
            'Catat gejala dan kondisi ternak yang mengalami gangguan kesehatan.',
      },
      {
        'title': 'Pelaporan Kematian Ternak',
        'description':
            'Dokumentasikan ternak yang tidak bertahan sebagai bagian dari evaluasi perawatan.',
      },
      {
        'title': 'Pelaporan Pemberian Nutrisi',
        'description':
            'Laporkan aktivitas pemberian vitamin untuk memastikan kesehatan ternak.',
      },
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
              title: 'Menu Pelaporan',
              greeting: 'Pelaporan Khusus'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            BannerWidget(
              title: 'Step $_step - Apa yang ingin kamu laporkan?',
              subtitle: 'Pilih jenis pelaporan yang akan dilakukan!',
              showDate: true,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Jenis Pelaporan Khusus',
                style: bold18.copyWith(color: dark1),
              ),
            ),
            const SizedBox(height: 12),
            for (var item in reports)
              MenuButton(
                title: item['title'],
                subtext: item['description'],
                icon: Icons.shopping_bag_outlined,
                backgroundColor: Colors.grey.shade200,
                iconColor: green1,
                isSelected: selectedReport == item['title'],
                onTap: () {
                  setState(() {
                    selectedReport = item['title'];
                  });
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {
            navigateBasedOnSelection();
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
