import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

class VitaminTab extends StatelessWidget {
  final ChartDataState laporanVitaminState;
  final ChartDataState laporanVaksinState;

  final RiwayatDataState riwayatVitaminState;

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange;

  const VitaminTab({
    super.key,
    required this.laporanVitaminState,
    required this.laporanVaksinState,
    required this.riwayatVitaminState,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    this.selectedChartDateRange,
  });

  String _generateRangkumanVaksin() {
    if (laporanVitaminState.isLoading || laporanVaksinState.isLoading) {
      return "Memuat data laporan pemberian vitamin atau vaksin...";
    }
    if (laporanVitaminState.error != null || laporanVaksinState.error != null) {
      return "Tidak dapat memuat rangkuman karena terjadi kesalahan.";
    }

    if (laporanVitaminState.dataPoints.isEmpty &&
        laporanVaksinState.dataPoints.isEmpty) {
      return "Tidak ada laporan pemberian vitamin atau vaksin pada periode ini.";
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

    num totalVitamin = laporanVitaminState.dataPoints.fold(0,
        (prev, curr) => prev + ((curr['jumlahPemberianVitamin'] as num?) ?? 0));
    num totalVaksin = laporanVaksinState.dataPoints.fold(0,
        (prev, curr) => prev + ((curr['jumlahPemberianVaksin'] as num?) ?? 0));

    final List<String> summaryParts = [];
    if (totalVitamin > 0) {
      summaryParts.add("total $totalVitamin kasus pemberian vitamin");
    }
    if (totalVaksin > 0) {
      summaryParts.add("$totalVaksin kasus pemberian vaksin");
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
          // Statistik Laporan Pemberian Vitamin
          ChartSection(
            title: 'Statistik Laporan Pemberian Vitamin',
            chartState: laporanVitaminState,
            valueKeyForMapping: 'jumlahPemberianVitamin',
            showFilterControls: true,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
          ),
          const SizedBox(height: 12),
          // Statistik Laporan Pemberian Vaksin
          ChartSection(
            title: 'Statistik Laporan Pemberian Vaksin',
            chartState: laporanVaksinState,
            valueKeyForMapping: 'jumlahPemberianVaksin',
            showFilterControls: false,
          ),

          const SizedBox(height: 12),
          // Rangkuman Statistik Pemberian Vitamin dan Vaksin
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik Pemberian Vitamin",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  _generateRangkumanVaksin(),
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Riwayat Pelaporan Pemberian Vitamin atau Vaksin
          if (riwayatVitaminState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (riwayatVitaminState.error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Error memuat riwayat laporan pemberian vitamin atau vaksin: ${riwayatVitaminState.error}',
                  style: const TextStyle(color: Colors.red)),
            )
          else if (riwayatVitaminState.items.isNotEmpty)
            NewestReports(
              title: 'Riwayat Pemberian Vitamin & Vaksin',
              reports: riwayatVitaminState.items.map((item) {
                return {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'text':
                      'Pemberian ${item['name'] as String? ?? 'Laporan Pemberian Vitamin/Vaksin'}',
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
                      jenisBudidaya: 'hewan');
                } else {
                  ScaffoldMessenger.of(itemContext).showSnackBar(
                    const SnackBar(
                      content: Text('ID laporan tidak ditemukan.'),
                    ),
                  );
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
                  'Tidak ada riwayat pelaporan pemberian vitamin atau vaksin untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
