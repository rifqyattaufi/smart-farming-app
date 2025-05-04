import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';

class DetailLaporanSakitTernakScreen extends StatelessWidget {
  const DetailLaporanSakitTernakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
            title: 'Laporan Peternakan',
            greeting: 'Detail Laporan Ternak Sakit',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DottedBorder(
                    color: green1,
                    strokeWidth: 1.5,
                    dashPattern: const [6, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/rooftop.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informasi Ternak Sakit",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Kode ternak", "Ayam #2"),
                      infoItem("Nama jenis ternak", "Ayam"),
                      infoItem("Lokasi ternak", "Kandang A"),
                      infoItem("Nama penyakit", "Cacingan"),
                      infoItem("Jumlah terkena penyakit", "1 ekor"),
                      infoItem("Pelaporan oleh", "Adi Santoso"),
                      infoItem(
                          "Tanggal pelaporan",
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now())),
                      infoItem("Waktu pelaporan",
                          DateFormat('HH:mm').format(DateTime.now())),
                      const SizedBox(height: 8),
                      Text("Catatan/jurnal pelaporan",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        "Ternak ini mengalami gejala cacingan, seperti tidak mau makan dan terlihat lesu. Segera lakukan pemeriksaan lebih lanjut.",
                        style: regular14.copyWith(color: dark2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }
}
