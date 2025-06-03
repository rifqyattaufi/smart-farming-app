import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal di rangkuman
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
// Impor ChartDataState dan RiwayatDataState (sesuaikan path jika perlu)
import 'package:smart_farming_app/screen/laporan/statistik_tanaman_report.dart'
    show ChartDataState, RiwayatDataState;
// Impor ChartSection jika diletakkan di file terpisah
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart'; // NewestReports untuk laporan terbaru (jika ada)

// Jika ChartSection tidak diimpor, Anda bisa paste definisinya di atas kelas NutrisiTab

class NutrisiTab extends StatelessWidget {
  final ChartDataState nutrisiState; // Menggunakan struktur state baru
  // Jika ada NewestReports yang dinamis untuk nutrisi:
  // final RiwayatDataState newestNutrisiReportsState;
  final RiwayatDataState riwayatPupukState; // Untuk ListItem riwayat lengkap

  final Future<void> Function()? onDateIconPressed;
  final ChartFilterType? selectedChartFilterType;
  final String? formattedDisplayedDateRange;
  final void Function(ChartFilterType?)? onChartFilterTypeChanged;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange; // Untuk rangkuman dinamis

  const NutrisiTab({
    super.key,
    required this.nutrisiState,
    // required this.newestNutrisiReportsState, // Jika dinamis
    required this.riwayatPupukState,
    this.onDateIconPressed,
    this.selectedChartFilterType,
    this.formattedDisplayedDateRange,
    this.onChartFilterTypeChanged,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    this.selectedChartDateRange,
  });

  String _generateRangkumanNutrisi() {
    if (nutrisiState.isLoading) {
      return "Memuat data pemberian nutrisi...";
    }
    if (nutrisiState.error != null) {
      return "Tidak dapat memuat rangkuman pemberian nutrisi.";
    }
    if (nutrisiState.dataPoints.isEmpty) {
      return "Tidak ada data pemberian nutrisi pada periode ini.";
    }

    final DateFormat rangeFormatter = DateFormat('d MMM yyyy');
    String periodeText = "pada periode terpilih";
    if (selectedChartDateRange != null) {
      final String startDateFormatted =
          rangeFormatter.format(selectedChartDateRange!.start);
      final String endDateFormatted =
          rangeFormatter.format(selectedChartDateRange!.end);
      periodeText = selectedChartDateRange!.start
              .isAtSameMomentAs(selectedChartDateRange!.end)
          ? "pada tanggal $startDateFormatted"
          : "pada periode $startDateFormatted hingga $endDateFormatted";
    }

    num totalKejadian = nutrisiState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + ((curr['jumlahKejadianPemberianPupuk'] as num?) ?? 0));
    String rataRataText = "";
    if ((selectedChartFilterType == ChartFilterType.weekly ||
            selectedChartFilterType == ChartFilterType.custom) &&
        nutrisiState.dataPoints.isNotEmpty) {
      double rataRata = totalKejadian / nutrisiState.dataPoints.length;
      rataRataText =
          "dengan rata-rata ${rataRata.toStringAsFixed(1)} kali per hari";
    }

    return "Berdasarkan statistik pelaporan $periodeText, terdapat total $totalKejadian laporan pemberian nutrisi $rataRataText.";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart untuk Pemberian Nutrisi menggunakan ChartSection
          ChartSection(
            title: 'Statistik Pemberian Nutrisi Tanaman',
            chartState: nutrisiState,
            valueKeyForMapping: 'jumlahKejadianPemberianPupuk',
            showFilterControls: onDateIconPressed != null,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
            lineColor: green1, // Warna untuk nutrisi
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik Nutrisi",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  _generateRangkumanNutrisi(), // Rangkuman dinamis
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contoh NewestReports (jika Anda ingin membuatnya dinamis, gunakan newestNutrisiReportsState)
          // Untuk saat ini, saya biarkan statis seperti kode asli Anda, tapi idealnya ini juga dinamis
          NewestReports(
            title: 'Laporan Pemberian Nutrisi Terbaru',
            reports: const [
              // Data statis ini bisa diganti dari newestNutrisiReportsState.items
              {
                'id': 'nutrisi_report_static_1',
                'text':
                    'Pemberian pupuk NPK terjadwal telah dilakukan oleh Pak Budi.',
                'icon':
                    'assets/icons/set/carbohydrates.png', // Ikon yang lebih relevan
                'time': 'Baru saja',
              }
            ],
            onItemTap: (itemContext, item) {
              ScaffoldMessenger.of(itemContext).showSnackBar(
                  SnackBar(content: Text('Tap pada: ${item['text']}')));
            },
            onViewAll: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Lihat Semua Laporan Nutrisi Terbaru')));
            },
            mode: NewestReportsMode
                .simple, // Mungkin mode simple lebih cocok di sini
          ),
          const SizedBox(height: 16),

          // Riwayat Pemberian Nutrisi (ListItem)
          if (riwayatPupukState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (riwayatPupukState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error Riwayat Nutrisi: ${riwayatPupukState.error}',
                  style: const TextStyle(color: Colors.red)),
            )
          else if (riwayatPupukState.items.isNotEmpty)
            ListItem(
              title: 'Riwayat Pemberian Nutrisi Lengkap',
              type: 'history',
              items: riwayatPupukState.items.map((item) {
                return {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'name': "${item['name'] ?? 'Nutrisi Tidak Bernama'}",
                  'category': (item['category'] as String?) ?? 'Nutrisi',
                  'image': item['gambar'] as String? ??
                      'assets/icons/set/fertilizer_bag.png', // Ikon yang lebih relevan
                  'person': item['petugasNama'] as String? ??
                      item['person'] as String? ??
                      'N/A',
                  'date': formatDisplayDate(item['tanggal'] as String? ??
                      item['date'] as String? ??
                      item['createdAt'] as String?),
                  'time': formatDisplayTime(item['waktu'] as String? ??
                      item['time'] as String? ??
                      item['createdAt'] as String?),
                  // 'description': 'Dosis: ${item['dosis'] ?? '-'} | Metode: ${item['metode'] ?? '-'}', // Contoh deskripsi
                };
              }).toList(),
              onItemTap: (itemContext, tappedItem) {
                final laporanId = tappedItem['id'] as String?;
                final laporanJudul = tappedItem['name'] as String?;
                if (laporanId != null && laporanId.isNotEmpty) {
                  ScaffoldMessenger.of(itemContext).showSnackBar(
                      SnackBar(content: Text('Membuka detail: $laporanJudul')));
                } else {
                  ScaffoldMessenger.of(itemContext).showSnackBar(const SnackBar(
                      content: Text('Detail laporan tidak tersedia.')));
                }
              },
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  'Tidak ada riwayat pemberian nutrisi untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
