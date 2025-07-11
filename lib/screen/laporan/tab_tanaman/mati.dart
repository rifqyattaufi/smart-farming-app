import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
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

  // Helper function to safely extract numeric values from dynamic data
  num _safeNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

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

    num totalKematian = laporanMatiState.dataPoints.fold(0, (prev, curr) {
      return prev + _safeNumericValue(curr['jumlahKematian']);
    });

    // Handle empty state when no deaths occurred
    if (totalKematian == 0) {
      return "Berdasarkan statistik $periodeText, tidak ditemukan kasus kematian tanaman. Kondisi ini menunjukkan bahwa tanaman dalam keadaan baik dan terawat dengan optimal.";
    }

    final summary = StringBuffer(
        "Berdasarkan statistik $periodeText, ditemukan total $totalKematian kasus kematian tanaman. ");

    final penyebabData = statistikPenyebabState.rawData
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    if (penyebabData.isNotEmpty) {
      summary.write("Rincian penyebab yang ditemukan yaitu ");

      final List<String> penyebabParts = penyebabData.map<String>((item) {
        final nama = item['penyebab'] ?? 'N/A';
        final total = _safeNumericValue(item['jumlahKematian']).toInt();
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

  Widget _buildCounterCard(BuildContext context) {
    Widget cardContent;

    if (laporanMatiState.isLoading) {
      cardContent =
          const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (laporanMatiState.error != null) {
      cardContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Gagal memuat total",
            key: const Key('error_total_tanaman_mati'),
            style: regular12.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      final totalMati = laporanMatiState.dataPoints.fold<num>(0, (sum, item) {
        return sum + _safeNumericValue(item['jumlahKematian']);
      });

      cardContent = Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              totalMati.toInt().toString(),
              style: bold20.copyWith(color: dark1, fontSize: 60),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: green1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  'assets/icons/other.svg',
                  colorFilter: ColorFilter.mode(white, BlendMode.srcIn),
                  width: 24,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              'Tanaman Mati',
              style: semibold18.copyWith(color: dark1, fontSize: 18),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: dark1.withValues(alpha: 0.5), width: 1),
        ),
        color: green4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: cardContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Counter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Tanaman Mati',
                  style: bold18.copyWith(color: dark1),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDisplayedDateRange,
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCounterCard(context),
          ),
          const SizedBox(height: 12),

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
                  style: regular12.copyWith(color: Colors.red),
                  key: const Key('error_riwayat_laporan_mati')),
            )
          else if (riwayatMatiState.items.isNotEmpty)
            NewestReports(
              key: const Key('riwayat_pelaporan_mati'),
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
                final idLaporan = tappedItem['id'] as String?;
                if (idLaporan != null) {
                  navigateToDetailLaporan(itemContext,
                      idLaporan: idLaporan,
                      jenisLaporan: 'kematian',
                      jenisBudidaya: 'tumbuhan');
                } else {
                  showAppToast(context,
                      'ID laporan tidak ditemukan. Tidak dapat membuka detail laporan.');
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
                        'Belum ada riwayat pelaporan kematian tanaman',
                        style: medium14.copyWith(color: dark2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lakukan pelaporan kematian tanaman untuk melihat riwayatnya di sini',
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
