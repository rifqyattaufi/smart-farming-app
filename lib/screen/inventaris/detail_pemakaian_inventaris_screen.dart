import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';

class DetailPemakaianInventarisScreen extends StatelessWidget {
  const DetailPemakaianInventarisScreen({super.key});

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
            title: 'Riwayat Pemakaian Inventaris',
            greeting: 'Detail Pemakaian Inventaris',
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
                        'assets/images/pupuk.jpg',
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
                      Text("Informasi Penggunaan Inventaris",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Kategori inventaris", "Nutrisi Tanaman"),
                      infoItem("Nama inventaris", "Pupuk A"),
                      infoItem("Pemakaian oleh", "Adi Santoso"),
                      infoItem("Jumlah digunakan", "4"),
                      infoItem("Satuan", "Kg"),
                      infoItem(
                          "Tanggal digunakan",
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now())),
                      infoItem("Waktu digunakan",
                          DateFormat('HH:mm').format(DateTime.now())),
                      const SizedBox(height: 8),
                      Text("Keperluan penggunaan inventaris",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        "Pemakaian pupuk A untuk tanaman di kebun A",
                        style: regular14.copyWith(color: dark2),
                      ),
                      const SizedBox(height: 16),
                      Text("Bukti penggunaan inventaris",
                          style: medium14.copyWith(color: dark1)),
                    ],
                  ),
                ),
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
                        'assets/images/pupuk.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {},
          buttonText: 'Ubah Data',
          backgroundColor: yellow2,
          textStyle: semibold16,
          textColor: white,
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
