import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';

class DetailLaporanSakitScreen extends StatelessWidget {
  final String? idLaporanSakit;

  const DetailLaporanSakitScreen({super.key, this.idLaporanSakit});

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
            title: 'Laporan Perkebunan',
            greeting: 'Detail Laporan Tanaman Sakit',
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
                      Text("Informasi Tanaman Sakit",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Kode tanaman", "Melon #2"),
                      infoItem("Nama jenis tanaman", "Melon"),
                      infoItem("Lokasi tanaman", "Kebun A"),
                      infoItem("Nama penyakit", "Embun tepung"),
                      infoItem("Jumlah terkena penyakit", "1 tanaman"),
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
                        "Terdapat lapisan putih seperti bedak/tepung \n- Biasanya muncul di permukaan daun bagian atas. \n- Bisa meluas ke batang dan buah jika tidak segera ditangani.",
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
