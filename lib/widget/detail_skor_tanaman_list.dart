import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DetailSkorTanamanListWidget extends StatelessWidget {
  final List<dynamic> detailTanamanList;
  final bool isLoading;
  // final Function(Map<String, dynamic> tanamanData)? onItemTap;

  const DetailSkorTanamanListWidget({
    super.key,
    required this.isLoading,
    required this.detailTanamanList,
    // this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (detailTanamanList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Tidak ada data tanaman individual untuk ditampilkan.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            'Rincian Status per Tanaman',
            style: bold16.copyWith(color: dark1),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: detailTanamanList.length,
          itemBuilder: (context, index) {
            final tanaman = detailTanamanList[index] as Map<String, dynamic>;
            final String nama = tanaman['namaId'] as String? ?? 'Tanpa Nama';
            final String status =
                tanaman['statusKlasifikasi'] as String? ?? 'N/A';
            final String alasan =
                tanaman['alasanStatusKlasifikasi'] as String? ??
                    'Tidak diketahui';

            Color statusColor = dark2;
            if (status.toLowerCase() == 'sehat') {
              statusColor = green1;
            } else if (status.toLowerCase() == 'perlu perhatian') {
              statusColor = Colors.orange;
            } else if (status.toLowerCase() == 'kritis') {
              statusColor = red;
            }

            String subtitleText = 'Status: $status';
            if (alasan.isNotEmpty && alasan != 'Tidak diketahui') {
              subtitleText += '\nAlasan: $alasan';
            }

            return Tooltip(
              message: alasan,
              padding: const EdgeInsets.all(8.0),
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: ListTile(
                    title: Text(nama, style: medium14.copyWith(color: dark1)),
                    subtitle: Text(
                      subtitleText,
                      style: regular12.copyWith(color: statusColor),
                    ),
                    onTap: () {
                      final String tanamanId =
                          tanaman['id'] as String? ?? 'ID Tidak Ada';
                      print(
                          "Tanaman $tanamanId - $nama di-tap. Status: $status. Alasan: $alasan");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Detail untuk $nama: $alasan'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
