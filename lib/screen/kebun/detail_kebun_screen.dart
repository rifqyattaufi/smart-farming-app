import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailKebunScreen extends StatefulWidget {
  const DetailKebunScreen({super.key});

  @override
  State<DetailKebunScreen> createState() => _DetailKebunScreenState();
}

class _DetailKebunScreenState extends State<DetailKebunScreen> {
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
            title: 'Daftar Kebun',
            greeting: 'Detail Kebun',
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
                      Text("Informasi Kebun",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama kebun", "Kebun A"),
                      infoItem("Lokasi kebun", "Rooftop"),
                      infoItem("Luas kebun", "10 m2"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status kebun",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: green2.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                'Aktif',
                                style: regular12.copyWith(color: green2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem(
                          "Tanggal didaftarkan",
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(DateTime.now())),
                      infoItem("Waktu didaftarkan",
                          DateFormat('HH:mm').format(DateTime.now())),
                      const SizedBox(height: 8),
                      Text("Deskripsi kebun",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        "Kebun ini digunakan untuk budidaya tanaman A.",
                        style: regular14.copyWith(color: dark2),
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Tanaman',
                  type: 'basic',
                  items: const [
                    {
                      'name': 'Melon #1',
                      'category': 'Kebun A',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'name': 'Melon #2',
                      'category': 'Kebun A',
                      'icon': 'assets/icons/goclub.svg',
                    },
                  ],
                  onItemTap: (context, item) {
                    final name = item['name'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
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
