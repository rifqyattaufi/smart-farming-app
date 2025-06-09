import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

class MatiTab extends StatelessWidget {
  final ChartDataState laporanMatiState;
  final ChartDataState statistikPenyebabState;
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
    required this.statistikPenyebabState,
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
    if (laporanMatiState.isLoading || statistikPenyebabState.isLoading) {
      return "Memuat data laporan kematian...";
    }
    if (laporanMatiState.error != null) {
      return "Tidak dapat memuat rangkuman laporan kematian.";
    }
    if (laporanMatiState.dataPoints.isEmpty) {
      return "Tidak ada laporan kematian tanaman pada periode ini.";
    }

    final DateFormat rangeFormatter = DateFormat('d MMMM yyyy');
    String periodeText = "pada periode terpilih";
    if (selectedChartDateRange != null) {
      final String start = rangeFormatter.format(selectedChartDateRange!.start);
      final String end = rangeFormatter.format(selectedChartDateRange!.end);
      periodeText = (start == end)
          ? "pada tanggal $start"
          : "pada periode $start hingga $end";
    }

    num totalKematian = laporanMatiState.dataPoints.fold(
        0, (prev, curr) => prev + ((curr['jumlahKematian'] as num?) ?? 0));

    final summary = StringBuffer(
        "Berdasarkan statistik $periodeText, ditemukan total $totalKematian kasus kematian tanaman. ");

    final penyakitData = statistikPenyebabState.rawData
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    if (penyakitData.isNotEmpty) {
      summary.write("Rincian penyebab yang ditemukan yaitu ");

      final List<String> penyebabParts = penyakitData.map<String>((item) {
        final nama = item['penyebab'] ?? 'N/A';
        final total = (item['jumlahKematian'] as num?)?.toInt() ?? 0;
        return "$total kasus $nama";
      }).toList();

      if (penyebabParts.length == 1) {
        summary.write(penyebabParts.first);
      } else if (penyebabParts.length == 2) {
        summary.write("${penyebabParts.first} dan ${penyebabParts.last}");
      } else {
        final lastItem = penyebabParts.removeLast();
        summary.write("${penyebabParts.join(', ')}, dan $lastItem");
      }
      summary.write(". ");
    }

    if (totalKematian > 0) {
      summary.write(
          "Perlu dilakukan pengecekan lebih lanjut untuk identifikasi dan penanganan.");
    }

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
            title: 'Statistik Kematian Tanaman',
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
              title: 'Riwayat Pelaporan Kematian Tanaman',
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
                  'Tidak ada riwayat pelaporan kematian tanaman untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
