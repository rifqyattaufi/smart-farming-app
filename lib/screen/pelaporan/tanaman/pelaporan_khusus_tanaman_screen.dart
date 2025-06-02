import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class PelaporanKhususTanamanScreen extends StatefulWidget {
  const PelaporanKhususTanamanScreen({super.key});

  @override
  State<PelaporanKhususTanamanScreen> createState() =>
      _PelaporanKhususTanamanScreenState();
}

class _PelaporanKhususTanamanScreenState
    extends State<PelaporanKhususTanamanScreen> {
  final _step = 1;
  String? selectedReport;

  void navigateBasedOnSelection() {
    switch (selectedReport) {
      case 'Pelaporan Hasil Panen':
        context.push('/pilih-komoditas-tanaman',
            extra: PilihKomoditasTanamanScreen(
              step: _step + 1,
              tipe: 'panen',
              greeting: 'Pelaporan Hasil Panen',
            ));
        break;
      case 'Pelaporan Tanaman Sakit':
        context.push('/pilih-kebun',
            extra: PilihKebunScreen(
              step: _step + 1,
              tipe: 'sakit',
              greeting: 'Pelaporan Tanaman Sakit',
            ));
        break;
      case 'Pelaporan Tanaman Mati':
        context.push('/pilih-kebun',
            extra: PilihKebunScreen(
              step: _step + 1,
              tipe: 'kematian',
              greeting: 'Pelaporan Tanaman Mati',
            ));
        break;
      case 'Pelaporan Pemberian Nutrisi':
        context.push('/pilih-kebun',
            extra: PilihKebunScreen(
              step: _step + 1,
              tipe: 'vitamin',
              greeting: 'Pelaporan Pemberian Nutrisi',
            ));
        break;
      case 'Pelaporan Hama Tanaman':
        context.push('/pelaporan-hama');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> reports = [
      {
        'title': 'Pelaporan Hasil Panen',
        'description':
            'Catat jumlah dan kondisi hasil panen untuk evaluasi dan perencanaan produksi yang lebih baik.',
        'route': '/pelaporan-panen-tanaman',
      },
      {
        'title': 'Pelaporan Tanaman Sakit',
        'description':
            'Catat gejala dan kondisi tanaman yang mengalami gangguan kesehatan.',
        'route': '/pelaporan-tanaman-sakit',
      },
      {
        'title': 'Pelaporan Tanaman Mati',
        'description':
            'Dokumentasikan tanaman yang tidak bertahan sebagai bagian dari evaluasi perawatan.',
        'route': '/pelaporan-tanaman-mati',
      },
      {
        'title': 'Pelaporan Pemberian Nutrisi',
        'description':
            'Laporkan aktivitas pemberian pupuk atau vitamin untuk memastikan tanaman tumbuh optimal dan sehat.',
        'route': '/pelaporan-nutrisi-tanaman',
      },
      {
        'title': 'Pelaporan Hama Tanaman',
        'description':
            'Laporkan temuan hama untuk tindakan pencegahan dan penanggulangan cepat.',
        'route': '/pelaporan-hama',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
