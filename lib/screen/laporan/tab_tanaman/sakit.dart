import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal di rangkuman
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
// Impor ChartDataState dan RiwayatDataState (sesuaikan path jika perlu)
import 'package:smart_farming_app/screen/laporan/statistik_tanaman_report.dart'
    show ChartDataState, RiwayatDataState;
// Impor ChartSection jika diletakkan di file terpisah
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

// Jika ChartSection tidak diimpor, Anda bisa paste definisinya di atas kelas SakitTab

class SakitTab extends StatelessWidget {
  final ChartDataState laporanSakitState; // Menggunakan struktur state baru
  final RiwayatDataState riwayatSakitState; // Menggunakan struktur state baru

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  // Fungsi formatter dari parent
  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange; // Untuk rangkuman dinamis

  const SakitTab({
    super.key,
    required this.laporanSakitState,
    required this.riwayatSakitState,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    this.selectedChartDateRange,
  });

  String _generateRangkumanSakit() {
    if (laporanSakitState.isLoading) {
      return "Memuat data laporan sakit...";
    }
    if (laporanSakitState.error != null) {
      return "Tidak dapat memuat rangkuman laporan sakit.";
    }
    if (laporanSakitState.dataPoints.isEmpty) {
      return "Tidak ada laporan tanaman sakit pada periode ini.";
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

    num totalSakit = laporanSakitState.dataPoints
        .fold(0, (prev, curr) => prev + ((curr['jumlahSakit'] as num?) ?? 0));

    String rangkuman =
        "Berdasarkan statistik pelaporan $periodeText, ditemukan total $totalSakit kasus tanaman sakit. ";

    // Contoh tambahan: mencari penyakit yang paling sering dilaporkan jika data detail ada
    // Ini memerlukan asumsi struktur data `laporanSakitState.rawData` atau modifikasi pada `_processBackendChartData`
    // Untuk saat ini, kita buat sederhana.
    if (totalSakit > 0) {
      rangkuman +=
          "Perlu dilakukan pengecekan lebih lanjut untuk identifikasi dan penanganan penyakit.";
    }

    return rangkuman;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart untuk Laporan Sakit menggunakan ChartSection
          ChartSection(
            title: 'Statistik Laporan Tanaman Sakit',
            chartState: laporanSakitState,
            valueKeyForMapping: 'jumlahSakit',
            showFilterControls: true,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
            lineColor: red, // Memberi warna merah untuk chart sakit
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik Tanaman Sakit",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  _generateRangkumanSakit(), // Rangkuman dinamis
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Riwayat Pelaporan Sakit
          if (riwayatSakitState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (riwayatSakitState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Error memuat riwayat laporan sakit: ${riwayatSakitState.error}',
                  style: const TextStyle(color: Colors.red)),
            )
          else if (riwayatSakitState.items.isNotEmpty)
            NewestReports(
              title: 'Riwayat Pelaporan Tanaman Sakit',
              reports: riwayatSakitState.items.map((item) {
                return {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'text':
                      item['judul'] as String? ?? 'Laporan Sakit Tidak Bernama',
                  'subtext': 'Oleh: ${item['petugasNama'] as String? ?? 'N/A'}',
                  'icon': item['gambar'] as String? ??
                      'assets/icons/set/symptom.png', // Ikon yang lebih relevan
                  // Gunakan formatter dari parent jika waktu dari backend adalah ISO string
                  'time': formatDisplayTime(
                      item['createdAt'] as String? ?? item['time'] as String?),
                  'date': formatDisplayDate(item['createdAt'] as String? ??
                      item['date']
                          as String?), // Tambahkan tanggal jika NewestReports mendukung
                };
              }).toList(),
              onItemTap: (itemContext, tappedItem) {
                final laporanId = tappedItem['id'] as String?;
                final laporanJudul = tappedItem['text'] as String?;
                if (laporanId != null && laporanId.isNotEmpty) {
                  // Navigasi: itemContext.push('/detail-laporan-sakit/$laporanId');
                  ScaffoldMessenger.of(itemContext).showSnackBar(
                      SnackBar(content: Text('Membuka detail: $laporanJudul')));
                } else {
                  ScaffoldMessenger.of(itemContext).showSnackBar(const SnackBar(
                      content: Text('Detail laporan tidak tersedia.')));
                }
              },
              onViewAll: () {
                // Navigasi: context.push('/semua-laporan-sakit');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Melihat Semua Laporan Sakit')));
              },
              mode: NewestReportsMode.full, // Atau .simple jika lebih ringkas
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  'Tidak ada riwayat pelaporan tanaman sakit untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
