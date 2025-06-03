import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart'; // Untuk navigasi
import 'package:smart_farming_app/theme.dart'; // Pastikan path ini benar
// import 'package:smart_farming_app/widget/chart.dart'; // Jika Anda ingin mengaktifkan chart
import 'package:smart_farming_app/widget/newest.dart'; // Pastikan path ini benar

class MatiTab extends StatelessWidget {
  // Jika ChartWidget diaktifkan, Anda mungkin perlu parameter seperti:
  // final bool isLoadingChartMati;
  // final String? chartMatiError;
  // final List<double> chartMatiData;
  // final List<String> chartMatiXLabels;
  // final Future<void> Function()? onDateIconPressed; // Callback dari parent untuk filter
  // final ChartFilterType selectedChartFilterType;    // dari parent
  // final String formattedDisplayedDateRange;         // dari parent
  // final void Function(ChartFilterType?)? onChartFilterTypeChanged; // callback dari parent

  // Jika NewestReports menjadi dinamis:
  // final List<Map<String, String>> riwayatLaporanMatiItems;
  // final Function(BuildContext, Map<String, String>) onItemTapCallback;
  // final Function() onViewAllCallback;

  const MatiTab({
    super.key,
    // Inisialisasi parameter di atas jika Anda menambahkannya
  });

  @override
  Widget build(BuildContext context) {
    // Contoh data statis untuk ChartWidget jika ingin diaktifkan nanti
    // final DateTime firstDate = DateTime(2024, 1, 1);
    // final DateTime lastDate = DateTime(2024, 12, 31);
    // final List<double> dataMati = [1, 0, 2, 1, 0, 0]; // Contoh data kematian

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jika Anda memiliki data untuk ChartWidget Tanaman Mati, tampilkan di sini
          // Contoh jika ChartWidget diaktifkan:
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: ChartWidget(
          //     titleStats: 'Statistik Tanaman Mati',
          //     data: chartMatiData, // atau data statis contoh
          //     xLabels: chartMatiXLabels, // atau label statis contoh
          //     onDateIconPressed: onDateIconPressed,
          //     showFilterControls: true, // atau false sesuai kebutuhan
          //     selectedChartFilterType: selectedChartFilterType,
          //     displayedDateRangeText: formattedDisplayedDateRange,
          //     onChartFilterTypeChanged: onChartFilterTypeChanged,
          //     lineColor: Colors.grey[700], // Warna untuk chart kematian
          //     // title: 'Total Tanaman Mati', // jika menggunakan title counter
          //     // showCounter: true,
          //     // textCounter: 'Tanaman Mati',
          //     // counter: 2, // contoh counter
          //   ),
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik Kematian", // Judul disesuaikan
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  // Teks ini statis dari kode asli Anda, sesuaikan untuk konteks tanaman mati
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, ditemukan 2 tanaman melon mati dengan deskripsi kekurangan nutrisi kritis dan serangan hama yang parah.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan Tanaman Mati', // Judul disesuaikan
            reports: const [
              // Data ini masih statis, bisa diganti dengan prop dinamis
              {
                'id': 'mati_report_1', // Tambahkan ID jika perlu untuk navigasi
                'text':
                    'Pak Budi melaporkan 1 tanaman Tomat mati karena layu fusarium',
                'icon':
                    'assets/icons/set/carbohydrates.png', // Ganti dengan ikon yang relevan
                'time': '20 Mei 2025', // Contoh waktu
              },
              {
                'id': 'mati_report_2',
                'text':
                    'Tanaman Melon #3 di Kebun A mati, diduga kekurangan air',
                'icon':
                    'assets/icons/set/carbohydrates.png', // Ganti dengan ikon yang relevan
                'time': '10 Apr 2025', // Contoh waktu
              },
            ],
            onItemTap: (itemContext, item) {
              final reportId = item['id'] as String?;
              final reportName = item['text'] ?? 'Laporan Tidak Dikenal';
              if (reportId != null) {
                // Jika Anda punya halaman detail laporan kematian spesifik
                // itemContext.push('/detail-laporan-kematian/$reportId');
                print(
                    'Navigasi ke detail laporan kematian: $reportName (ID: $reportId)');
                ScaffoldMessenger.of(itemContext).showSnackBar(
                    SnackBar(content: Text('Tap pada: $reportName')));
              } else {
                print('Tap pada: $reportName (ID tidak tersedia)');
                ScaffoldMessenger.of(itemContext).showSnackBar(SnackBar(
                    content:
                        Text('Tap pada: $reportName (ID tidak tersedia)')));
              }
            },
            onViewAll: () {
              // Jika ada halaman untuk melihat semua laporan kematian
              // context.push('/semua-laporan-kematian');
              print('Navigasi ke semua laporan kematian');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lihat Semua Laporan Kematian')));
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
          const SizedBox(height: 80), // Memberi ruang di bagian bawah
        ],
      ),
    );
  }
}
