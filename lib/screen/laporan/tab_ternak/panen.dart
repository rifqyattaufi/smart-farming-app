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
  final RiwayatDataState riwayatPanenState;

  final String? objektBelumPanenErrorMessage;
  final Map<String, dynamic>? objektBelumPanenData;
  final Map<String, dynamic>? ternakReport;

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
    required this.riwayatPanenState,
    this.objektBelumPanenErrorMessage,
    this.objektBelumPanenData,
    this.ternakReport,
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
      return "Tidak ada laporan panen ternak pada periode ini.";
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
            sum + ((point['jumlahLaporanPanenTernak'] as num?) ?? 0).toInt());

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
          key: const Key('error_loading_panen_komoditas'),
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
            key: const Key('no_panen_data'),
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

  Widget _buildHewanBelumPanenContent() {
    if (objektBelumPanenData == null) {
      return Center(
        child: Text(
          'Tidak ada data hewan yang perlu dipanen',
          style: regular14.copyWith(color: dark2),
        ),
      );
    }

    final data = objektBelumPanenData!['data'] as Map<String, dynamic>?;
    if (data == null) {
      return Center(
        child: Text(
          'Data tidak tersedia',
          style: regular14.copyWith(color: dark2),
        ),
      );
    }

    final totalObjects = data['totalObjects'] as int? ?? 0;
    final objects = data['objects'] as List<dynamic>? ?? [];
    final cutoffDate = data['cutoffDate'] as String?;

    if (totalObjects == 0 || objects.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: green1,
          ),
          const SizedBox(height: 12),
          Text(
            'Semua hewan sudah dipanen atau belum saatnya panen',
            style: regular14.copyWith(color: dark2),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: yellow1.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: yellow),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: yellow,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getHewanSummaryText(totalObjects),
                      style: medium14.copyWith(color: dark1),
                    ),
                    if (cutoffDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Berdasarkan batas waktu: ${formatDisplayDate(cutoffDate)}',
                        style: regular12.copyWith(color: dark2),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: objects.length > 3 ? 200 : null,
          child: ListView.builder(
            shrinkWrap: true,
            physics: objects.length > 3
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: objects.length,
            itemBuilder: (context, index) => _buildHewanItem(objects[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildHewanItem(dynamic obj) {
    final objMap = obj as Map<String, dynamic>? ?? {};
    final namaId = objMap['namaId'] as String? ?? 'N/A';
    final unitBudidaya = objMap['unitBudidaya'] as Map<String, dynamic>?;
    final unitNama = unitBudidaya?['nama'] as String? ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaId,
                  style: medium12.copyWith(color: dark1),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lokasi: $unitNama',
                  style: regular10.copyWith(color: dark2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHewanPanenTitle() {
    if (ternakReport == null) {
      return 'Hewan yang Perlu Dipanen';
    }

    final namaHewan = ternakReport!['nama'] as String? ?? 'Hewan';
    final periodePanen = ternakReport!['periodePanen'] as int?;

    if (periodePanen == null) {
      return '$namaHewan yang Perlu Dipanen';
    }

    return '$namaHewan tidak produktif selama $periodePanen hari terakhir';
  }

  String _getHewanSummaryText(int totalObjects) {
    if (ternakReport == null) {
      return 'Total: $totalObjects hewan perlu dipanen';
    }

    final namaHewan = ternakReport!['nama'] as String? ?? 'Hewan';
    return '$namaHewan tidak produktif: $totalObjects ekor';
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
            valueKeyForMapping: 'jumlahLaporanPanenTernak',
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

          // Hewan Belum Dipanen Section - only show if periodePanen is not null
          if (ternakReport != null &&
              ternakReport!['periodePanen'] != null) ...[
            if (objektBelumPanenData == null &&
                objektBelumPanenErrorMessage == null)
              // Loading state
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHewanPanenTitle(),
                          style: bold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12.0),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (objektBelumPanenErrorMessage != null)
              // Error state
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHewanPanenTitle(),
                          style: bold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12.0),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              objektBelumPanenErrorMessage!,
                              style: regular14.copyWith(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (objektBelumPanenData != null)
              // Data loaded state
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getHewanPanenTitle(),
                          style: bold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12.0),
                        _buildHewanBelumPanenContent(),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

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
                    key: const Key('error_riwayat_panen'),
                    'Error memuat riwayat laporan panen: ${riwayatPanenState.error}',
                    style: regular12.copyWith(color: red)))
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
                  navigateToDetailLaporan(
                    itemContext,
                    idLaporan: idLaporan,
                    jenisLaporan: 'panen',
                    jenisBudidaya: 'hewan',
                  );
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  key: const Key('no_riwayat_panen'),
                  style: regular12.copyWith(color: dark2),
                  'Tidak ada riwayat pelaporan panen ternak untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
