import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

class NutrisiTab extends StatelessWidget {
  final ChartDataState nutrisiState;
  final ChartDataState vitaminState;
  final ChartDataState disinfektanState;

  final RiwayatDataState riwayatNutrisiState;

  final Future<void> Function()? onDateIconPressed;
  final ChartFilterType? selectedChartFilterType;
  final String? formattedDisplayedDateRange;
  final void Function(ChartFilterType?)? onChartFilterTypeChanged;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange;

  const NutrisiTab({
    super.key,
    required this.nutrisiState,
    required this.vitaminState,
    required this.disinfektanState,
    required this.riwayatNutrisiState,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    this.selectedChartDateRange,
  });

  String _generateRangkumanNutrisi() {
    if (nutrisiState.isLoading ||
        vitaminState.isLoading ||
        disinfektanState.isLoading) {
      return "Memuat data pemberian nutrisi...";
    }
    if (nutrisiState.error != null ||
        vitaminState.error != null ||
        disinfektanState.error != null) {
      return "Tidak dapat memuat rangkuman pemberian nutrisi.";
    }
    if (nutrisiState.dataPoints.isEmpty &&
        vitaminState.dataPoints.isEmpty &&
        disinfektanState.dataPoints.isEmpty) {
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

    num totalNutrisi = nutrisiState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + ((curr['jumlahKejadianPemberianPupuk'] as num?) ?? 0));
    num totalVitamin = vitaminState.dataPoints.fold(0,
        (prev, curr) => prev + ((curr['jumlahPemberianVitamin'] as num?) ?? 0));
    num totalDisinfektan = disinfektanState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + ((curr['jumlahPemberianDisinfektan'] as num?) ?? 0));

    // Handle empty state when no nutrition activities occurred
    if (totalNutrisi == 0 && totalVitamin == 0 && totalDisinfektan == 0) {
      return "Berdasarkan statistik pelaporan $periodeText, tidak ditemukan aktivitas pemberian nutrisi. Pastikan untuk memberikan nutrisi yang cukup untuk pertumbuhan tanaman yang optimal.";
    }

    final List<String> summaryParts = [];
    if (totalVitamin > 0) {
      summaryParts.add("total $totalVitamin kasus pemberian vitamin");
    }
    if (totalNutrisi > 0) {
      summaryParts.add("$totalNutrisi kasus pemberian nutrisi tanaman");
    }
    if (totalDisinfektan > 0) {
      summaryParts.add("$totalDisinfektan kasus pemberian disinfektan");
    }

    return "Berdasarkan statistik pelaporan $periodeText, ditemukan ${summaryParts.join(' dan ')}.";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart untuk Pemberian Nutrisi
          ChartSection(
            title: 'Statistik Pemberian Nutrisi Tanaman',
            chartState: nutrisiState,
            valueKeyForMapping: 'jumlahKejadianPemberianPupuk',
            showFilterControls: onDateIconPressed != null,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
          ),
          const SizedBox(height: 12),
          ChartSection(
            title: 'Statistik Laporan Pemberian Disinfektan',
            chartState: disinfektanState,
            valueKeyForMapping: 'jumlahPemberianDisinfektan',
            showFilterControls: false,
          ),
          const SizedBox(height: 12),
          ChartSection(
            title: 'Statistik Laporan Pemberian Vitamin',
            chartState: vitaminState,
            valueKeyForMapping: 'jumlahPemberianVitamin',
            showFilterControls: false,
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik Pemberian Nutrisi",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  _generateRangkumanNutrisi(),
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Riwayat Pelaporan Pemberian Nutrisi
          if (riwayatNutrisiState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (riwayatNutrisiState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Error memuat riwayat laporan pemberian nutrisi: ${riwayatNutrisiState.error}',
                  style: regular12.copyWith(color: dark2),
                  key: const Key('error_riwayat_pemberian_nutrisi')),
            )
          else if (riwayatNutrisiState.items.isNotEmpty)
            NewestReports(
              key: const Key('riwayat_pemberian_nutrisi'),
              title: 'Riwayat Pemberian Nutrisi',
              reports: riwayatNutrisiState.items.map((item) {
                return {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'text':
                      'Pemberian ${item['name'] as String? ?? 'Laporan Pemberian Nutrisi'}',
                  'subtext': 'Oleh: ${item['person'] as String? ?? 'N/A'}',
                  'icon':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'time': item['time'],
                };
              }).toList(),
              onItemTap: (itemContext, tappedItem) {
                final idLaporan = tappedItem['id'] as String?;
                if (idLaporan != null) {
                  navigateToDetailLaporan(itemContext,
                      idLaporan: idLaporan,
                      jenisLaporan: 'vitamin',
                      jenisBudidaya: 'tumbuhan');
                } else {
                  showAppToast(
                    context,
                    'Tidak dapat membuka laporan. ID laporan tidak ditemukan.',
                  );
                }
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48,
                        color: dark2.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada riwayat pemberian nutrisi',
                        style: medium14.copyWith(color: dark2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lakukan pemberian nutrisi untuk melihat riwayatnya di sini',
                        style: regular12.copyWith(
                            color: dark2.withValues(alpha: 0.7)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
