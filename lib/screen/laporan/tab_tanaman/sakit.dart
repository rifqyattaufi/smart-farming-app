import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';

class SakitTab extends StatelessWidget {
  final ChartDataState laporanSakitState;
  final ChartDataState statistikPenyakitState;
  final RiwayatDataState riwayatSakitState;

  final Future<void> Function() onDateIconPressed;
  final ChartFilterType selectedChartFilterType;
  final String formattedDisplayedDateRange;
  final void Function(ChartFilterType?) onChartFilterTypeChanged;

  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;
  final DateTimeRange? selectedChartDateRange;

  const SakitTab({
    super.key,
    required this.laporanSakitState,
    required this.statistikPenyakitState,
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
    if (laporanSakitState.isLoading || statistikPenyakitState.isLoading) {
      return "Memuat data laporan sakit...";
    }
    if (laporanSakitState.error != null) {
      return "Tidak dapat memuat rangkuman laporan sakit.";
    }
    if (laporanSakitState.dataPoints.isEmpty) {
      return "Tidak ada laporan tanaman sakit pada periode ini.";
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

    num totalSakit = laporanSakitState.dataPoints.fold(0, (prev, curr) {
      final value = curr['jumlahSakit'];
      if (value is num) {
        return prev + value;
      } else if (value is String) {
        return prev + (num.tryParse(value) ?? 0);
      }
      return prev;
    });

    // Handle empty state when no sick plants occurred
    if (totalSakit == 0) {
      return "Berdasarkan statistik $periodeText, tidak ditemukan kasus tanaman sakit. Kondisi ini menunjukkan bahwa tanaman dalam keadaan sehat dan terawat dengan baik.";
    }

    final summary = StringBuffer(
        "Berdasarkan statistik $periodeText, ditemukan total $totalSakit kasus tanaman sakit. ");

    final penyakitData = statistikPenyakitState.rawData
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    if (penyakitData.isNotEmpty) {
      summary.write("Rincian penyakit yang ditemukan yaitu ");

      final List<String> penyakitParts = penyakitData.map<String>((item) {
        final nama = item['penyakit'] ?? 'N/A';
        final value = item['jumlahKasus'];
        int total = 0;
        if (value is num) {
          total = value.toInt();
        } else if (value is String) {
          total = int.tryParse(value) ?? 0;
        }
        return "$total kasus $nama";
      }).toList();

      if (penyakitParts.length == 1) {
        summary.write(penyakitParts.first);
      } else if (penyakitParts.length == 2) {
        summary.write("${penyakitParts.first} dan ${penyakitParts.last}");
      } else {
        final lastItem = penyakitParts.removeLast();
        summary.write("${penyakitParts.join(', ')}, dan $lastItem");
      }
      summary.write(". ");
    }

    if (totalSakit > 0) {
      summary.write(
          "Perlu dilakukan pengecekan lebih lanjut untuk identifikasi dan penanganan.");
    }

    return summary.toString();
  }

  Widget _buildCounterCard(BuildContext context) {
    Widget cardContent;

    if (laporanSakitState.isLoading) {
      cardContent =
          const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (laporanSakitState.error != null) {
      cardContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            key: const Key('error_total_sakit'),
            "Gagal memuat total",
            style: regular12.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      final totalSakit = laporanSakitState.dataPoints.fold<num>(0, (sum, item) {
        final value = item['jumlahSakit'];
        if (value is num) {
          return sum + value;
        } else if (value is String) {
          return sum + (num.tryParse(value) ?? 0);
        }
        return sum;
      });

      cardContent = Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              totalSakit.toInt().toString(),
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
              'Tanaman Sakit',
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
                  'Total Tanaman Sakit',
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

          // Statistik Laporan Tanaman Sakit
          ChartSection(
            title: 'Statistik Laporan Tanaman Sakit',
            chartState: laporanSakitState,
            valueKeyForMapping: 'jumlahSakit',
            showFilterControls: true,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
          ),

          const SizedBox(height: 12),
          // Rangkuman Statistik Tanaman Sakit
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik Tanaman Sakit",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  _generateRangkumanSakit(),
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
                  style: regular12.copyWith(color: Colors.red),
                  key: const Key('error_riwayat_sakit')),
            )
          else if (riwayatSakitState.items.isNotEmpty)
            NewestReports(
              key: const Key('riwayat_pelaporan_sakit'),
              title: 'Riwayat Pelaporan Tanaman Sakit',
              reports: riwayatSakitState.items.map((item) {
                return {
                  'id': item['laporanId'] as String? ??
                      item['id'] as String? ??
                      '',
                  'text':
                      item['text'] as String? ?? 'Laporan Sakit Tidak Bernama',
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
                      jenisLaporan: 'sakit',
                      jenisBudidaya: 'tumbuhan');
                } else {
                  showAppToast(context,
                      'Tidak dapat membuka detail laporan. ID laporan tidak ditemukan.');
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
                        'Belum ada riwayat pelaporan tanaman sakit',
                        style: medium14.copyWith(color: dark2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lakukan pelaporan tanaman sakit untuk melihat riwayatnya di sini',
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
