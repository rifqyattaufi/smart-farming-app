import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart'; // Untuk navigasi
import 'package:smart_farming_app/theme.dart'; // Pastikan path ini benar
// import 'package:smart_farming_app/widget/chart.dart'; // Jika Anda ingin mengaktifkan chart
import 'package:smart_farming_app/widget/newest.dart'; // Pastikan path ini benar

class PanenTab extends StatelessWidget {
  // Jika ChartWidget diaktifkan, Anda mungkin perlu parameter seperti:
  // final bool isLoadingChart;
  // final String? chartError;
  // final List<double> chartData;
  // final List<String> chartXLabels;
  // final Future<void> Function()? onDateIconPressed;
  // final ChartFilterType selectedChartFilterType;
  // final String formattedDisplayedDateRange;
  // final void Function(ChartFilterType?)? onChartFilterTypeChanged;

  // Jika NewestReports menjadi dinamis:
  // final List<Map<String, String>> newestReportsItems;
  // final Function(BuildContext, Map<String, String>) onItemTapCallback;
  // final Function() onViewAllCallback;

  const PanenTab({
    super.key,
    // Inisialisasi parameter di atas jika Anda menambahkannya
  });

  @override
  Widget build(BuildContext context) {
    // Contoh data statis untuk ChartWidget jika ingin diaktifkan nanti
    // final DateTime firstDate = DateTime(2024, 1, 1);
    // final DateTime lastDate = DateTime(2024, 12, 31);
    // final List<double> data = [10, 15, 8, 20, 12, 17]; // Contoh data

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jika Anda memiliki data untuk ChartWidget Panen, Anda bisa menampilkannya di sini
          // Contoh jika ChartWidget diaktifkan:
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: ChartWidget(
          //     titleStats: 'Statistik Hasil Panen Tanaman',
          //     data: chartData, // atau data statis contoh
          //     xLabels: chartXLabels, // atau label statis contoh
          //     onDateIconPressed: onDateIconPressed, // callback dari parent
          //     showFilterControls: true, // atau false sesuai kebutuhan
          //     selectedChartFilterType: selectedChartFilterType, // dari parent
          //     displayedDateRangeText: formattedDisplayedDateRange, // dari parent
          //     onChartFilterTypeChanged: onChartFilterTypeChanged, // callback dari parent
          //     // title: 'Total Hasil Panen', // jika menggunakan title counter
          //     // showCounter: true,
          //     // counter: 120, // contoh counter
          //   ),
          // ),
          const SizedBox(
              height: 12), // Tetap berikan jarak meskipun chart dikomentari
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan panen tiap 2 bulan sekali, didapatkan hasil panen sangat optimal, dengan rata-rata di atas 18 buah yang dihasilkan per waktu panen.\n\nTerdapat 2 kondisi terbaik saat panen, yaitu pada bulan Agustus 2024 dan Februari 2025 dengan total panen, yaitu 20 buah.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan Panen', // Judul disesuaikan
            reports: const [
              // Data ini masih statis, bisa diganti dengan prop dinamis
              {
                'id':
                    'panen_report_1', // Tambahkan ID jika perlu untuk navigasi
                'text':
                    'Pak Adi telah melaporkan hasil panen Melon periode Mei',
                'icon':
                    'assets/icons/set/carbohydrates.png', // Ganti dengan ikon yang relevan
                'time': '28 Mei 2025', // Contoh waktu
              },
              {
                'id': 'panen_report_2',
                'text': 'Bu Susi melaporkan panen Cabai sebanyak 5 Kg',
                'icon':
                    'assets/icons/set/carbohydrates.png', // Ganti dengan ikon yang relevan
                'time': '15 Apr 2025', // Contoh waktu
              },
            ],
            onItemTap: (itemContext, item) {
              final reportId = item['id'] as String?;
              final reportName = item['text'] ?? 'Laporan Tidak Dikenal';
              if (reportId != null) {
                // Jika Anda punya halaman detail laporan panen spesifik
                // itemContext.push('/detail-laporan-panen/$reportId');
                print(
                    'Navigasi ke detail laporan panen: $reportName (ID: $reportId)');
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
              // Jika ada halaman untuk melihat semua laporan panen
              // context.push('/semua-laporan-panen');
              print('Navigasi ke semua laporan panen');
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lihat Semua Laporan Panen')));
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
