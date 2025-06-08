import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

class MatiTab extends StatelessWidget {
  final ChartDataState laporanMatiState;
  final RiwayatDataState riwayatMatiState;

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange;

  const MatiTab({
    super.key,
    required this.laporanMatiState,
    required this.riwayatMatiState,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    this.selectedChartDateRange,
  });

  String _generateRangkumanMati() {
    if (laporanMatiState.isLoading) {
      return "Memuat data laporan kematian...";
    }
    if (laporanMatiState.error != null) {
      return "Tidak dapat memuat rangkuman laporan kematian.";
    }
    if (laporanMatiState.dataPoints.isEmpty) {
      return "Tidak ada laporan kematian ternak pada periode ini.";
    }

    StringBuffer summary = StringBuffer();

    String periodeText;
    if (selectedChartDateRange != null) {
      String startDateFormatted =
          DateFormat('d MMMM yyyy').format(selectedChartDateRange!.start);
      String endDateFormatted =
          DateFormat('d MMMM yyyy').format(selectedChartDateRange!.end);
      periodeText = selectedChartDateRange!.start
              .isAtSameMomentAs(selectedChartDateRange!.end)
          ? "pada tanggal $startDateFormatted"
          : "pada periode $startDateFormatted hingga $endDateFormatted";
    } else {
      periodeText = "pada periode terpilih";
    } // Hitung total kematian
    int totalKematian = laporanMatiState.dataPoints.fold(0,
        (sum, point) => sum + ((point['jumlahKematian'] as num?) ?? 0).toInt());

    summary.write(
        "Berdasarkan statistik pelaporan $periodeText, ditemukan total $totalKematian kasus kematian ternak. ");

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
          // Chart section
          ChartSection(
            title: 'Statistik Kematian Ternak',
            chartState: laporanMatiState,
            valueKeyForMapping: 'jumlahKematian',
            showFilterControls: true,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
          ),

          // Rangkuman section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rangkuman Statistik Kematian',
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  _generateRangkumanMati(),
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),

          // Riwayat section
          if (riwayatMatiState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (riwayatMatiState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Error memuat riwayat laporan kematian: ${riwayatMatiState.error}',
                  style: const TextStyle(color: Colors.red)),
            )
          else if (riwayatMatiState.items.isNotEmpty)
            NewestReports(
              title: 'Riwayat Pelaporan Kematian Ternak',
              reports: riwayatMatiState.items.map((item) {
                return {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'text': item['text'] as String? ??
                      'Laporan Kematian Tidak Bernama',
                  'subtext': 'Oleh: ${item['person'] as String? ?? 'N/A'}',
                  'icon':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'time': item['time'],
                };
              }).toList(),
              onItemTap: (itemContext, tappedItem) {
                final laporanId = tappedItem['id'] as String?;
                final laporanJudul = tappedItem['text'] as String?;
                if (laporanId != null && laporanId.isNotEmpty) {
                  // Navigasi: itemContext.push('/detail-laporan-kematian/$laporanId');
                  ScaffoldMessenger.of(itemContext).showSnackBar(
                      SnackBar(content: Text('Membuka detail: $laporanJudul')));
                } else {
                  ScaffoldMessenger.of(itemContext).showSnackBar(const SnackBar(
                      content: Text('Detail laporan tidak tersedia.')));
                }
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  'Tidak ada riwayat pelaporan kematian ternak untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
