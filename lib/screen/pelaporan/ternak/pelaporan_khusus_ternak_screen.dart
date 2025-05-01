import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';
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
  String? selectedReport;

  void navigateBasedOnSelection() {
    switch (selectedReport) {
      case 'Pelaporan Panen Ternak':
        context.push('/pelaporan-panen-ternak');
        break;
      case 'Pelaporan Ternak Sakit':
        context.push('/pelaporan-ternak-sakit');
        break;
      case 'Pelaporan Kematian Ternak':
        context.push('/pelaporan-kematian-ternak');
        break;
      case 'Pelaporan Pemberian Nutrisi':
        context.push('/pelaporan-nutrisi-ternak');
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
        'route': '/pelaporan-panen-ternak',
      },
      {
        'title': 'Pelaporan Ternak Sakit',
        'description':
            'Catat gejala dan kondisi ternak yang mengalami gangguan kesehatan.',
        'route': '/pelaporan-ternak-sakit',
      },
      {
        'title': 'Pelaporan Kematian Ternak',
        'description':
            'Dokumentasikan ternak yang tidak bertahan sebagai bagian dari evaluasi perawatan.',
        'route': '/pelaporan-kematian-ternak',
      },
      {
        'title': 'Pelaporan Pemberian Nutrisi',
        'description':
            'Laporkan aktivitas pemberian vitamin untuk memastikan kesehatan ternak.',
        'route': '/pelaporan-nutrisi-ternak',
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
            const BannerWidget(
              title: 'Apa yang ingin kamu laporkan?',
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
