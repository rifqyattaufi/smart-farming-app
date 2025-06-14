import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

class HarianTab extends StatelessWidget {
  final ChartDataState laporanHarianState;
  final ChartDataState pakanState;
  final ChartDataState cekKandangState;

  final String? statistikHarianErrorMessage;
  final Map<String, dynamic>? statistikHarianData;

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  final String generatedStatistikRangkumanText;

  final RiwayatDataState riwayatUmumState;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;

  const HarianTab({
    super.key,
    required this.laporanHarianState,
    required this.pakanState,
    required this.cekKandangState,
    this.statistikHarianErrorMessage,
    this.statistikHarianData,
    required this.onDateIconPressed,
    required this.selectedChartFilterType,
    required this.formattedDisplayedDateRange,
    required this.onChartFilterTypeChanged,
    required this.generatedStatistikRangkumanText,
    required this.riwayatUmumState,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
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

    // Chart Laporan Harian
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

    // Chart Pemberian Pakan Ternak
    listChildren.add(ChartSection(
      title: 'Statistik Pemberian Pakan Ternak',
      chartState: pakanState,
      valueKeyForMapping: 'jumlahPakan',
    ));

    // Chart Pengecekan Kandang Ternak
    listChildren.add(ChartSection(
      title: 'Statistik Pengecekan Kandang Ternak',
      chartState: cekKandangState,
      valueKeyForMapping: 'jumlahCekKandang',
    ));

    listChildren.add(const SizedBox(height: 4));

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
                        pakanState.isLoading ||
                        cekKandangState.isLoading) &&
                    (laporanHarianState.dataPoints.isEmpty &&
                        pakanState.dataPoints.isEmpty &&
                        cekKandangState.dataPoints.isEmpty)
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

    // Riwayat Pelaporan Harian
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
                      '',
                  'text': item['text'] as String? ?? 'Laporan',
                  'subtext': 'Oleh: ${item['person'] as String? ?? 'N/A'}',
                  'icon':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'time': item['time'],
                })
            .toList(),
        onItemTap: (itemContext, tappedItem) {
          final idLaporan = tappedItem['id'] as String?;
          if (idLaporan != null) {
            navigateToDetailLaporan(itemContext,
                idLaporan: idLaporan,
                jenisLaporan: 'harian',
                jenisBudidaya: 'hewan');
          } else {
            showAppToast(context,
                'Tidak dapat membuka detail laporan. ID laporan tidak ditemukan.');
          }
        },
        mode: NewestReportsMode.full,
        titleTextStyle: bold18.copyWith(color: dark1),
        reportTextStyle: medium12.copyWith(color: dark1),
        timeTextStyle: regular12.copyWith(color: dark2),
      ));
    } else {
      listChildren.add(_paddedItem(
          const Text('Tidak ada riwayat pelaporan harian untuk ditampilkan.')));
    }
    listChildren.add(const SizedBox(height: 12));

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: listChildren.length,
      itemBuilder: (BuildContext context, int index) => listChildren[index],
    );
  }
}
