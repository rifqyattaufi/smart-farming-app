import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/info_item.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
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
                Text("Informasi Jenis Ternak",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                const InfoItemWidget("Nama jenis ternak", value: "Ayam"),
                const InfoItemWidget("Nama latin",
                    value: "Gallus gallus domesticus"),
                const InfoItemWidget("Lokasi ternak", value: "Kandang A"),
                const InfoItemWidget("Jumlah ternak", value: "20 ekor"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status ternak",
                          style: medium14.copyWith(color: dark1)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: green2.withValues(alpha: .1),
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
                InfoItemWidget("Tanggal didaftarkan",
                    value: DateFormat('EEEE, dd MMMM yyyy')
                        .format(DateTime.now())),
                InfoItemWidget("Waktu didaftarkan",
                    value: DateFormat('HH:mm').format(DateTime.now())),
                const SizedBox(height: 8),
                Text("Deskripsi ternak",
                    style: medium14.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  "Ternak ini digunakan untuk budidaya komoditas A dan B.",
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),
          ListItem(
            title: 'Daftar Ternak',
            type: 'basic',
            items: const [
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
            ],
            onItemTap: (itemContext, item) {
              final name = item['name'] ?? '';
              itemContext.push('/detail-laporan/$name');
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
