import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/detail_skor_tanaman_list.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/statistik_harian_card.dart';

class HarianTab extends StatelessWidget {
  final ChartDataState laporanHarianState;
  final ChartDataState penyiramanState;
  final ChartDataState nutrisiState;
  final ChartDataState pruningState;
  final ChartDataState repottingState;

  final bool isLoadingStatistikHarian;
  final String? statistikHarianErrorMessage;
  final Map<String, dynamic>? statistikHarianData;

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  final String generatedStatistikRangkumanText;

  final RiwayatDataState riwayatUmumState;
  final RiwayatDataState riwayatPupukState;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final void Function(BuildContext, Map<String, dynamic>)
      onRiwayatPelaporanUmumItemTap;
  final void Function(BuildContext, Map<String, dynamic>)
      onRiwayatPemberianPupukItemTap;

  const HarianTab({
    super.key,
    required this.laporanHarianState,
    required this.penyiramanState,
    required this.nutrisiState,
    required this.pruningState,
    required this.repottingState,
    required this.isLoadingStatistikHarian,
    this.statistikHarianErrorMessage,
    this.statistikHarianData,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.generatedStatistikRangkumanText,
    required this.riwayatUmumState,
    required this.riwayatPupukState,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
    required this.onRiwayatPelaporanUmumItemTap,
    required this.onRiwayatPemberianPupukItemTap,
  });

  Widget _paddedError(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _paddedItem(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listChildren = [];

    // Chart Laporan Harian (dengan filter)
    listChildren.add(ChartSection(
      title: 'Statistik Laporan Harian',
      chartState: laporanHarianState,
      valueKeyForMapping: 'jumlahLaporan',
      showFilterControls: true,
      onDateIconPressed: onDateIconPressed,
      selectedChartFilterType: selectedChartFilterType,
      displayedDateRangeText: formattedDisplayedDateRange,
      onChartFilterTypeChanged: onChartFilterTypeChanged,
    ));

    // Chart Penyiraman
    listChildren.add(ChartSection(
      title: 'Statistik Penyiraman Tanaman',
      chartState: penyiramanState,
      valueKeyForMapping: 'jumlahPenyiraman',
    ));

    // Chart Pruning
    listChildren.add(ChartSection(
      title: 'Statistik Pruning Tanaman',
      chartState: pruningState,
      valueKeyForMapping: 'jumlahPruning',
    ));

    // Chart Repotting
    listChildren.add(ChartSection(
      title: 'Statistik Repotting Tanaman',
      chartState: repottingState,
      valueKeyForMapping: 'jumlahRepotting',
    ));

    // Chart Pemberian Nutrisi
    listChildren.add(ChartSection(
      title: 'Statistik Pemberian Nutrisi',
      chartState: nutrisiState,
      valueKeyForMapping: 'jumlahKejadianPemberianPupuk',
    ));

    listChildren.add(const SizedBox(height: 4));

    // Statistik Harian Card
    listChildren.add(StatistikHarianCard(
      isLoading: isLoadingStatistikHarian,
      errorMessage: statistikHarianErrorMessage,
      data: statistikHarianData,
    ));

    // Detail Skor Tanaman List
    if (statistikHarianData != null &&
        statistikHarianData!['detailTanaman'] != null) {
      listChildren.add(DetailSkorTanamanListWidget(
        isLoading: isLoadingStatistikHarian,
        detailTanamanList:
            statistikHarianData!['detailTanaman'] as List<dynamic>? ?? [],
      ));
    }
    listChildren.add(const SizedBox(height: 12));

    // Rangkuman Statistik Teks
    listChildren.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rangkuman Statistik", style: bold18.copyWith(color: dark1)),
            const SizedBox(height: 12),
            (laporanHarianState.isLoading ||
                        penyiramanState.isLoading ||
                        nutrisiState.isLoading) &&
                    (laporanHarianState.dataPoints.isEmpty &&
                        penyiramanState.dataPoints.isEmpty &&
                        nutrisiState.dataPoints.isEmpty)
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("Memuat rangkuman statistik...")))
                : Text(generatedStatistikRangkumanText,
                    style: regular14.copyWith(color: dark2)),
          ],
        ),
      ),
    );

    // Riwayat Pelaporan Umum
    if (riwayatUmumState.isLoading) {
      listChildren.add(const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2))));
    } else if (riwayatUmumState.error != null) {
      listChildren.add(
          _paddedError('Error Riwayat Pelaporan: ${riwayatUmumState.error}'));
    } else if (riwayatUmumState.items.isNotEmpty) {
      listChildren.add(NewestReports(
        title: 'Riwayat Pelaporan',
        reports: riwayatUmumState.items
            .map((item) => {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '', // accomodate different id keys
                  'text': item['judul'] as String? ??
                      item['text'] as String? ??
                      'Laporan',
                  'subtext': 'Oleh: ${item['petugasNama'] as String? ?? 'N/A'}',
                  'icon':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'time': item[
                      'time'], // Assume time is already formatted or handled by NewestReports
                })
            .toList(),
        onViewAll: () {
          /* Navigasi */ ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Melihat Semua Laporan Umum')));
        },
        onItemTap: onRiwayatPelaporanUmumItemTap,
        mode: NewestReportsMode.full,
        titleTextStyle: bold18.copyWith(color: dark1),
        reportTextStyle: medium12.copyWith(color: dark1),
        timeTextStyle: regular12.copyWith(color: dark2),
      ));
    } else {
      listChildren.add(_paddedItem(
          const Text('Tidak ada riwayat pelaporan umum untuk ditampilkan.')));
    }
    listChildren.add(const SizedBox(height: 12));

    // Riwayat Pemberian Pupuk
    if (riwayatPupukState.isLoading) {
      listChildren.add(const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2))));
    } else if (riwayatPupukState.error != null) {
      listChildren.add(
          _paddedError('Error Riwayat Nutrisi: ${riwayatPupukState.error}'));
    } else if (riwayatPupukState.items.isNotEmpty) {
      listChildren.add(ListItem(
        title: 'Riwayat Pemberian Pupuk',
        type: 'history',
        items: riwayatPupukState.items
            .map((item) => {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'name': "${item['name'] ?? 'Nutrisi'}",
                  'category': (item['category'] as String?) ?? 'Nutrisi',
                  'image':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'person': item['person'] as String? ??
                      item['petugasNama'] as String? ??
                      'N/A',
                  'date': formatDisplayDate(
                      item['date'] as String? ?? item['createdAt'] as String?),
                  'time': formatDisplayTime(
                      item['time'] as String? ?? item['createdAt'] as String?),
                })
            .toList(),
        onItemTap: onRiwayatPemberianPupukItemTap,
      ));
    } else {
      listChildren.add(_paddedItem(
          const Text('Tidak ada riwayat pemberian pupuk untuk ditampilkan.')));
    }

    listChildren.add(const SizedBox(height: 20));

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: listChildren.length,
      itemBuilder: (BuildContext context, int index) => listChildren[index],
    );
  }
}
