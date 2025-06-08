import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class PanenTab extends StatelessWidget {
  final ChartDataState laporanPanenState;
  final RiwayatDataState riwayatPanenState;

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange;

  const PanenTab({
    super.key,
    required this.laporanPanenState,
    required this.riwayatPanenState,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    this.selectedChartDateRange,
  });

  String _generateRangkumanPanen() {

    if (laporanPanenState.isLoading) {
      return "Memuat data laporan panen...";
    }
    if (laporanPanenState.error != null) {

      return "Tidak dapat memuat rangkuman: ${laporanPanenState.error}";
    }
    if (laporanPanenState.dataPoints.isEmpty) {
      return "Tidak ada laporan panen ternak pada periode ini.";
    }

    // Tentukan periode teks
    String periodeText;
    if (selectedChartDateRange != null) {
      final formatter = DateFormat('d MMMM yyyy', 'id_ID');
      String start = formatter.format(selectedChartDateRange!.start);
      String end = formatter.format(selectedChartDateRange!.end);
      periodeText = (start == end)
          ? "pada tanggal $start"
          : "pada periode $start hingga $end";
    } else {
      periodeText = "pada periode terpilih";
    }

    // Hitung total laporan
    int totalLaporan = laporanPanenState.dataPoints.fold(
        0,
        (sum, point) =>
            sum + ((point['jumlahLaporanPanenTernak'] as num?) ?? 0).toInt());

    final summary = StringBuffer(
        "Berdasarkan statistik $periodeText, telah dilakukan $totalLaporan kali pelaporan panen. ");

    return summary.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Section
          ChartSection(
            title: 'Statistik Frekuensi Laporan Panen',
            chartState: laporanPanenState,
            valueKeyForMapping: 'jumlahLaporanPanenTernak',
            showFilterControls: true,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
          ),

          const SizedBox(height: 12),

          // Rangkuman Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rangkuman Panen', style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  _generateRangkumanPanen(), // Menggunakan fungsi baru
                  style: regular14.copyWith(color: dark2, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Riwayat Section
          if (riwayatPanenState.isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (riwayatPanenState.error != null)
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${riwayatPanenState.error}'))
          else if (riwayatPanenState.items.isNotEmpty)
            NewestReports(
              title: 'Riwayat Pelaporan Panen',
              reports: riwayatPanenState.items.map((item) {
                return {
                  'id': item['laporanId'] ?? item['id'] ?? '',
                  'text': item['judul'] ?? 'Laporan Panen',
                  'subtext': 'Oleh: ${item['person'] ?? 'N/A'}',
                  'icon': item['gambar'],
                  'time': item['time'],
                };
              }).toList(),
              onItemTap: (itemContext, tappedItem) {
                // Navigasi atau aksi lainnya
              },
              mode: NewestReportsMode.full,
            )
          else
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('Tidak ada riwayat panen.'))),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
