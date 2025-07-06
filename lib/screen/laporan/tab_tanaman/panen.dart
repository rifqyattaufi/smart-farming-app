import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class PanenTab extends StatelessWidget {
  final ChartDataState laporanPanenState;
  final ChartDataState panenKomoditasState;
  final ChartDataState panenGradeState;
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
    required this.panenKomoditasState,
    required this.panenGradeState,
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
    if (laporanPanenState.isLoading && panenKomoditasState.isLoading) {
      return "Memuat data laporan panen...";
    }
    if (laporanPanenState.error != null) {
      return "Tidak dapat memuat rangkuman: ${laporanPanenState.error ?? panenKomoditasState.error}";
    }
    if (laporanPanenState.dataPoints.isEmpty) {
      return "Tidak ada laporan panen tanaman pada periode ini.";
    }

    String periodeText;
    if (selectedChartDateRange != null) {
      final formatter = DateFormat('d MMMM yyyy');
      String start = formatter.format(selectedChartDateRange!.start);
      String end = formatter.format(selectedChartDateRange!.end);
      periodeText = (start == end)
          ? "pada tanggal $start"
          : "pada periode $start hingga $end";
    } else {
      periodeText = "pada periode terpilih";
    }

    int totalLaporan = laporanPanenState.dataPoints.fold(
        0,
        (sum, point) =>
            sum + ((point['jumlahLaporanPanenTanaman'] as num?) ?? 0).toInt());

    // Handle empty state when no harvest reports occurred
    if (totalLaporan == 0) {
      return "Berdasarkan statistik $periodeText, belum ada pelaporan panen yang dilakukan. Lakukan pelaporan panen secara rutin untuk memantau produktivitas tanaman.";
    }

    final summary = StringBuffer(
        "Berdasarkan statistik $periodeText, telah dilakukan $totalLaporan kali pelaporan panen. ");

    final komoditasData = panenKomoditasState.rawData
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];
    if (komoditasData.isNotEmpty) {
      summary.write("Total hasil panen terdiri dari ");
      final List<String> komoditasParts = komoditasData.map<String>((item) {
        final nama = item['namaKomoditas'] ?? 'N/A';
        final total = (item['totalPanen'] as num?)?.toDouble() ?? 0.0;
        final satuan = item['lambangSatuan'] as String? ?? '';

        final formattedTotal =
            total.truncateToDouble() == total ? total.toInt() : total;
        return "$formattedTotal $satuan $nama".trim();
      }).toList();

      if (komoditasParts.length == 1) {
        summary.write(komoditasParts.first);
      } else if (komoditasParts.length == 2) {
        summary.write("${komoditasParts.first} dan ${komoditasParts.last}");
      } else {
        final lastItem = komoditasParts.removeLast();
        summary.write("${komoditasParts.join(', ')}, dan $lastItem");
      }
      summary.write(".");
    } else if (!panenKomoditasState.isLoading) {
      summary.write("Belum ada hasil panen yang tercatat untuk periode ini.");
    }

    // Add grade information if available
    if (panenGradeState.dataPoints.isNotEmpty && !panenGradeState.isLoading) {
      final gradeData = panenGradeState.dataPoints;
      final totalGrades = gradeData.length;

      if (totalGrades > 0) {
        // Calculate total harvest for grade
        final totalGradeHarvest = gradeData.fold<double>(0.0, (sum, grade) {
          final value = grade['value'];
          if (value is num) return sum + value.toDouble();
          return sum;
        });

        summary.write(
            " Hasil panen terbagi dalam $totalGrades jenis grade dengan total ${totalGradeHarvest.toStringAsFixed(totalGradeHarvest.truncateToDouble() == totalGradeHarvest ? 0 : 1)} ");

        // Get unit from first grade data
        final firstGradeUnit = gradeData.isNotEmpty
            ? (gradeData.first['unit']?.toString() ?? '')
            : '';
        if (firstGradeUnit.isNotEmpty) {
          summary.write(firstGradeUnit);
        }
        summary.write(": ");

        final gradeList = gradeData.map((grade) {
          final label = grade['label']?.toString() ?? '';
          final value =
              grade['value'] is num ? (grade['value'] as num).toDouble() : 0.0;
          final unit = grade['unit']?.toString() ?? '';

          // Calculate percentage
          final percentage =
              totalGradeHarvest > 0 ? (value / totalGradeHarvest * 100) : 0.0;

          return "grade $label ${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} $unit (${percentage.toStringAsFixed(1)}%)";
        }).toList();

        if (gradeList.length <= 3) {
          summary.write(gradeList.join(', '));
        } else {
          summary.write(
              "${gradeList.take(2).join(', ')}, dan ${gradeList.length - 2} grade lainnya");
        }
        summary.write(".");
      }
    } else if (!panenGradeState.isLoading && panenGradeState.error == null) {
      summary.write(" Belum ada data distribusi grade untuk periode ini.");
    }

    return summary.toString();
  }

  Widget _buildCommodityCounters(BuildContext context) {
    if (panenKomoditasState.isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (panenKomoditasState.error != null) {
      return Center(
        child: Text(
          key: const Key('error_panen_komoditas'),
          "Gagal memuat total panen: ${panenKomoditasState.error}",
          style: regular12.copyWith(color: Colors.red),
        ),
      );
    }

    final komoditasData = panenKomoditasState.rawData
            ?.whereType<Map<String, dynamic>>()
            .toList() ??
        [];

    if (komoditasData.isEmpty) {
      // Jika tidak ada data panen komoditas, tampilkan pesan
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            key: const Key('no_panen_komoditas'),
            style: regular12.copyWith(color: dark2),
            'Belum ada hasil panen yang tercatat untuk periode ini.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: komoditasData.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = komoditasData[index];
          final nama = item['namaKomoditas'] as String? ?? 'N/A';
          final total = (item['totalPanen'] as num?)?.toDouble() ?? 0.0;
          final satuan = item['lambangSatuan'] as String? ?? '';

          final formattedTotal = total.truncateToDouble() == total
              ? total.toInt().toString()
              : total.toString();

          return SizedBox(
            width: 180,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: dark1.withValues(alpha: 0.5), width: 1),
              ),
              color: index % 2 == 0 ? green4 : yellow1.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                nama,
                                style: bold16.copyWith(color: dark1),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedTotal,
                              style:
                                  bold20.copyWith(color: dark1, fontSize: 36),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              satuan,
                              style: medium14.copyWith(color: dark2),
                            ),
                          ],
                        )
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: index % 2 == 0
                            ? green1
                            : yellow.withValues(alpha: 0.5),
                        child: ClipOval(
                          child: SvgPicture.asset(
                            'assets/icons/other.svg',
                            colorFilter:
                                ColorFilter.mode(white, BlendMode.srcIn),
                            width: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradeDetailSection() {
    if (panenGradeState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (panenGradeState.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            'Error memuat detail grade: ${panenGradeState.error}',
            style: regular12.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final gradeData = panenGradeState.dataPoints;

    if (gradeData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.category_outlined,
                    size: 48, color: dark2.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada data grade',
                  style: medium14.copyWith(color: dark2),
                ),
                Text(
                  'Belum ada laporan panen dengan grade untuk periode ini',
                  style: regular12.copyWith(color: dark2),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Calculate total harvest for percentage calculation
    final totalHarvest = gradeData.fold<double>(0.0, (sum, grade) {
      final value = grade['value'];
      if (value is num) return sum + value.toDouble();
      return sum;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child:
              Text('Detail Grade Panen', style: bold18.copyWith(color: dark1)),
        ),
        ...gradeData.asMap().entries.map((entry) {
          final index = entry.key;
          final grade = entry.value;
          final isLast = index == gradeData.length - 1;

          final label = grade['label']?.toString() ?? 'N/A';
          final value =
              grade['value'] is num ? (grade['value'] as num).toDouble() : 0.0;
          final unit = grade['unit']?.toString() ?? '';
          final commodity = grade['commodity']?.toString() ?? '';

          // Calculate percentage
          final percentage =
              totalHarvest > 0 ? (value / totalHarvest * 100) : 0.0;

          // Define colors for grade indicators
          final gradeColors = [green1, green2, yellow, yellow2, blue1, red];
          final gradeColor = gradeColors[index % gradeColors.length];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                          color: dark4.withValues(alpha: 0.3), width: 0.5),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: gradeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: bold14.copyWith(color: dark1),
                      ),
                      if (commodity.isNotEmpty)
                        Text(
                          commodity,
                          style: regular12.copyWith(color: dark2),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} $unit',
                      style: bold14.copyWith(color: green1),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}% dari total',
                      style: regular12.copyWith(color: dark2),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
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
                  'Total Hasil Panen per Komoditas',
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
          _buildCommodityCounters(context),
          const SizedBox(height: 12),

          // Chart Section
          ChartSection(
            title: 'Statistik Frekuensi Laporan Panen',
            chartState: laporanPanenState,
            valueKeyForMapping: 'jumlahLaporanPanenTanaman',
            showFilterControls: true,
            onDateIconPressed: onDateIconPressed,
            selectedChartFilterType: selectedChartFilterType,
            displayedDateRangeText: formattedDisplayedDateRange,
            onChartFilterTypeChanged: onChartFilterTypeChanged,
          ),

          const SizedBox(height: 12),
          ChartSection(
            title: 'Statistik Jumlah Hasil Panen',
            chartState: panenKomoditasState,
            valueKeyForMapping: 'totalPanen',
            labelKeyForMapping: 'namaKomoditas',
            showFilterControls: false,
          ),

          const SizedBox(height: 12),
          ChartSection(
            title: 'Distribusi Grade Panen',
            chartState: panenGradeState,
            valueKeyForMapping: 'value',
            labelKeyForMapping: 'label',
            showFilterControls: false,
          ),

          const SizedBox(height: 12),
          _buildGradeDetailSection(),

          // Rangkuman Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rangkuman Statistik Panen',
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  _generateRangkumanPanen(),
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),

          // Riwayat Section
          if (riwayatPanenState.isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (riwayatPanenState.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                  'Error memuat riwayat laporan panen: ${riwayatPanenState.error}',
                  style: regular12.copyWith(color: Colors.red),
                  key: const Key('error_riwayat_panen')),
            )
          else if (riwayatPanenState.items.isNotEmpty)
            NewestReports(
              key: const Key('riwayat_panen'),
              title: 'Riwayat Pelaporan Panen',
              reports: riwayatPanenState.items.map((item) {
                return {
                  'id': item['laporanId'] ?? item['id'] ?? '',
                  'text': item['text'] ?? 'Laporan Panen',
                  'subtext': 'Oleh: ${item['person'] ?? 'N/A'}',
                  'icon': item['gambar'],
                  'time': item['time'],
                };
              }).toList(),
              onItemTap: (itemContext, tappedItem) {
                final idLaporan = tappedItem['id'] as String?;
                if (idLaporan != null) {
                  navigateToDetailLaporan(itemContext,
                      idLaporan: idLaporan,
                      jenisLaporan: 'panen',
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
                        'Belum ada riwayat pelaporan panen',
                        style: medium14.copyWith(color: dark2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lakukan pelaporan panen untuk melihat riwayatnya di sini',
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
