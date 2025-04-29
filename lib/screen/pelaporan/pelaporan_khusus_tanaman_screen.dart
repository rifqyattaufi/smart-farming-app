import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/menu_btn.dart';

class PelaporanKhususTanamanScreen extends StatelessWidget {
  const PelaporanKhususTanamanScreen({super.key});

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
              title: 'Menu Pelaporan',
              greeting: 'Pelaporan Khusus'),
        ),
      ),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.only(bottom: 100), children: [
          const BannerWidget(
            title: 'Apa yang ingin kamu laporkan?',
            subtitle: 'Pilih jenis pelaporan yang akan dilakukan!',
            showDate: true,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Jenis Pelaporan Khusus',
                  style: bold18.copyWith(color: dark1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          MenuButton(
            title: 'Pelaporan Hasil Panen',
            subtext:
                'Catat jumlah dan kondisi hasil panen untuk evaluasi dan perencanaan produksi yang lebih baik.',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.green,
          ),
          MenuButton(
            title: 'Pelaporan Tanaman Sakit',
            subtext:
                'Catat gejala dan kondisi tanaman yang mengalami gangguan kesehatan.',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.green,
          ),
          MenuButton(
            title: 'Pelaporan Tanaman Mati',
            subtext:
                'Dokumentasikan tanaman yang tidak bertahan sebagai bagian dari evaluasi perawatan.',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.green,
          ),
          MenuButton(
            title: 'Pelaporan Pemberian Nutrisi',
            subtext:
                'Laporkan aktivitas pemberian pupuk atau vitamin untuk memastikan tanaman tumbuh optimal dan sehat.',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.green,
          ),
          MenuButton(
            title: 'Pelaporan Hama Tanaman',
            subtext:
                'Laporkan temuan hama untuk tindakan pencegahan dan penanggulangan cepat.',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: Colors.grey.shade200,
            iconColor: Colors.green,
          ),
        ]),
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
