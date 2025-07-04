import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/chart_section.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'dart:math' as math;

class HarianTab extends StatelessWidget {
  final ChartDataState laporanHarianState;
  final ChartDataState penyiramanState;
  final ChartDataState nutrisiState;
  final ChartDataState pruningState;
  final ChartDataState repottingState;

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

  const HarianTab({
    super.key,
    required this.laporanHarianState,
    required this.penyiramanState,
    required this.nutrisiState,
    required this.pruningState,
    required this.repottingState,
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

  Widget _buildLegendItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $count',
              style: regular12.copyWith(color: dark2),
            ),
          ),
        ],
      ),
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

    // Chart Penyiraman
    listChildren.add(
      ChartSection(
        title: 'Statistik Penyiraman Tanaman',
        chartState: penyiramanState,
        valueKeyForMapping: 'jumlahPenyiraman',
      ),
    );

    // Chart Pruning
    listChildren.add(
      ChartSection(
        title: 'Statistik Pruning Tanaman',
        chartState: pruningState,
        valueKeyForMapping: 'jumlahPruning',
      ),
    );

    // Chart Repotting
    listChildren.add(
      ChartSection(
        title: 'Statistik Repotting Tanaman',
        chartState: repottingState,
        valueKeyForMapping: 'jumlahRepotting',
      ),
    );

    // Chart Pemberian Nutrisi
    listChildren.add(
      ChartSection(
        title: 'Statistik Pemberian Nutrisi',
        chartState: nutrisiState,
        valueKeyForMapping: 'jumlahKejadianPemberianPupuk',
      ),
    );

    listChildren.add(const SizedBox(height: 4));

    // Rangkuman Statistik Teks
    listChildren.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rangkuman Statistik Laporan Harian",
                style: bold18.copyWith(color: dark1)),
            const SizedBox(height: 12),
            (laporanHarianState.isLoading ||
                        penyiramanState.isLoading ||
                        nutrisiState.isLoading) &&
                    (laporanHarianState.dataPoints.isEmpty &&
                        penyiramanState.dataPoints.isEmpty &&
                        nutrisiState.dataPoints.isEmpty)
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("Memuat rangkuman statistik...",
                            style: regular12.copyWith(color: dark2),
                            key: const Key('loading_rangkuman_statistik'))))
                : Text(generatedStatistikRangkumanText,
                    style: regular14.copyWith(color: dark2)),
          ],
        ),
      ),
    );

    // Ringkasan Kesehatan Tanaman
    if (statistikHarianData == null && statistikHarianErrorMessage == null) {
      // Loading state untuk health summary
      listChildren.add(
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
                    'Ringkasan Kesehatan Tanaman',
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
        ),
      );
    } else if (statistikHarianErrorMessage != null) {
      // Error state untuk health summary
      listChildren.add(
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
                    'Ringkasan Kesehatan Tanaman',
                    style: bold16.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12.0),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'Gagal memuat data kesehatan tanaman',
                            style: medium14.copyWith(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statistikHarianErrorMessage!,
                            style: regular12.copyWith(color: dark2),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (statistikHarianData != null) {
      final totalTanaman = statistikHarianData!['totalTanaman'] ?? 0;
      final tanamanSehat = statistikHarianData!['tanamanSehat'] ?? 0;
      final perluPerhatian = statistikHarianData!['perluPerhatian'] ?? 0;
      final kritis = statistikHarianData!['kritis'] ?? 0;

      final persentaseSehat =
          (statistikHarianData!['persentaseSehat'] ?? 0.0).toDouble();
      final persentasePerluPerhatian =
          (statistikHarianData!['persentasePerluPerhatian'] ?? 0.0).toDouble();
      final persentaseKritis =
          (statistikHarianData!['persentaseKritis'] ?? 0.0).toDouble();

      final rekomendasi = statistikHarianData!['rekomendasi'] as String? ??
          "Tanaman dalam kondisi baik.";
      final detailTanaman =
          statistikHarianData!['detailTanaman'] as List<dynamic>? ?? [];

      listChildren.add(
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
                    'Ringkasan Kesehatan Tanaman',
                    style: bold16.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12.0),

                  // Overview Statistics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Tanaman:',
                          style: medium14.copyWith(color: dark2)),
                      Text('$totalTanaman',
                          style: bold14.copyWith(color: dark1)),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tanaman Sehat:',
                          style: medium14.copyWith(color: green1)),
                      Text(
                          '$tanamanSehat (${persentaseSehat.toStringAsFixed(1)}%)',
                          style: bold14.copyWith(color: green1)),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Perlu Perhatian:',
                          style: medium14.copyWith(color: Colors.orange)),
                      Text(
                          '$perluPerhatian (${persentasePerluPerhatian.toStringAsFixed(1)}%)',
                          style: bold14.copyWith(color: Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kritis:', style: medium14.copyWith(color: red)),
                      Text('$kritis (${persentaseKritis.toStringAsFixed(1)}%)',
                          style: bold14.copyWith(color: red)),
                    ],
                  ),

                  // Visual Health Indicator
                  if (totalTanaman > 0) ...[
                    const SizedBox(height: 16.0),
                    Text(
                      'Distribusi Kesehatan:',
                      style: medium14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFF0F0F0),
                      ),
                      child: Row(
                        children: [
                          if (persentaseSehat > 0)
                            Expanded(
                              flex: persentaseSehat.round(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: green1,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          if (persentasePerluPerhatian > 0)
                            Expanded(
                              flex: persentasePerluPerhatian.round(),
                              child: Container(
                                color: Colors.orange,
                              ),
                            ),
                          if (persentaseKritis > 0)
                            Expanded(
                              flex: persentaseKritis.round(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: red,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        if (persentaseSehat > 0) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: green1,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('Sehat',
                              style: regular10.copyWith(color: green1)),
                          const SizedBox(width: 12),
                        ],
                        if (persentasePerluPerhatian > 0) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('Perlu Perhatian',
                              style: regular10.copyWith(color: Colors.orange)),
                          const SizedBox(width: 12),
                        ],
                        if (persentaseKritis > 0) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('Kritis', style: regular10.copyWith(color: red)),
                        ],
                      ],
                    ),
                  ],

                  // Optional: Pie Chart for Health Distribution (if significant data exists)
                  if (totalTanaman > 0 &&
                      (kritis > 0 || perluPerhatian > 0)) ...[
                    const SizedBox(height: 16.0),
                    Text(
                      'Distribusi Kesehatan (Grafik):',
                      style: medium14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12.0),
                    SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          // Pie Chart
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 120,
                              padding: const EdgeInsets.all(8),
                              child: CustomPaint(
                                painter: _SimplePieChartPainter(
                                  sehat: persentaseSehat,
                                  perluPerhatian: persentasePerluPerhatian,
                                  kritis: persentaseKritis,
                                ),
                                child: Container(),
                              ),
                            ),
                          ),
                          // Legend
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tanamanSehat > 0)
                                  _buildLegendItem(
                                      'Sehat', tanamanSehat, green1),
                                if (perluPerhatian > 0)
                                  _buildLegendItem('Perlu Perhatian',
                                      perluPerhatian, Colors.orange),
                                if (kritis > 0)
                                  _buildLegendItem('Kritis', kritis, red),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12.0),
                  const Divider(),
                  const SizedBox(height: 8.0),

                  // Recommendations
                  Text(
                    'Rekomendasi:',
                    style: medium14.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    rekomendasi,
                    style: regular14.copyWith(color: dark2),
                  ),

                  // Detailed Plant Information (if available and not too many)
                  if (detailTanaman.isNotEmpty &&
                      (kritis > 0 || perluPerhatian > 0)) ...[
                    const SizedBox(height: 12.0),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    Text(
                      'Detail Tanaman yang Memerlukan Perhatian:',
                      style: medium14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          children: detailTanaman
                              .where((tanaman) {
                                final status =
                                    tanaman['statusKlasifikasi'] as String? ??
                                        '';
                                return status == 'Kritis' ||
                                    status == 'Perlu Perhatian';
                              })
                              .take(
                                  10) // Limit to 10 items to avoid UI overflow
                              .map<Widget>((tanaman) {
                                final namaId =
                                    tanaman['namaId'] as String? ?? 'N/A';
                                final status =
                                    tanaman['statusKlasifikasi'] as String? ??
                                        'N/A';
                                final kondisiDaun =
                                    tanaman['kondisiDaun'] as String? ?? 'N/A';
                                final alasan =
                                    tanaman['alasanStatusKlasifikasi']
                                            as String? ??
                                        '';

                                Color statusColor = dark2;
                                if (status == 'Kritis') {
                                  statusColor = red;
                                } else if (status == 'Perlu Perhatian') {
                                  statusColor = Colors.orange;
                                }

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFE9ECEF)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              namaId,
                                              style: medium12.copyWith(
                                                  color: dark1),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(
                                                  alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              status,
                                              style: regular10.copyWith(
                                                  color: statusColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Kondisi Daun: $kondisiDaun',
                                        style: regular12.copyWith(color: dark2),
                                      ),
                                      if (alasan.isNotEmpty) ...[
                                        const SizedBox(height: 2.0),
                                        Text(
                                          alasan.length > 100
                                              ? '${alasan.substring(0, 100)}...'
                                              : alasan,
                                          style: regular10.copyWith(
                                              color:
                                                  dark2.withValues(alpha: 0.8)),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                    if (detailTanaman
                            .where((t) => ['Kritis', 'Perlu Perhatian']
                                .contains(t['statusKlasifikasi']))
                            .length >
                        10)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Dan ${detailTanaman.where((t) => [
                                'Kritis',
                                'Perlu Perhatian'
                              ].contains(t['statusKlasifikasi'])).length - 10} tanaman lainnya...',
                          style: regular12.copyWith(
                              color: dark2.withValues(alpha: 0.7)),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

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
        key: const Key('riwayat_pelaporan_harian'),
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
                jenisBudidaya: 'tumbuhan');
          } else {
            showAppToast(
                context, 'ID laporan tidak ditemukan. Silakan coba lagi.');
          }
        },
        mode: NewestReportsMode.full,
        titleTextStyle: bold18.copyWith(color: dark1),
        reportTextStyle: medium12.copyWith(color: dark1),
        timeTextStyle: regular12.copyWith(color: dark2),
      ));
    } else {
      listChildren.add(
        _paddedItem(
          Center(
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
                    'Belum ada riwayat pelaporan harian',
                    style: medium14.copyWith(color: dark2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lakukan pelaporan harian untuk melihat riwayatnya di sini',
                    style:
                        regular12.copyWith(color: dark2.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    listChildren.add(const SizedBox(height: 12));

    // Riwayat Pemberian Pupuk
    if (riwayatPupukState.isLoading) {
      listChildren.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (riwayatPupukState.error != null) {
      listChildren.add(
        _paddedError('Error Riwayat Nutrisi: ${riwayatPupukState.error}'),
      );
    } else if (riwayatPupukState.items.isNotEmpty) {
      listChildren.add(
        ListItem(
          key: const Key('riwayat_pemberian_pupuk'),
          title: 'Riwayat Pemberian Pupuk',
          type: 'history',
          items: riwayatPupukState.items
              .map(
                (item) => {
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
                    item['date'] as String? ?? item['createdAt'] as String?,
                  ),
                  'time': formatDisplayTime(
                    item['time'] as String? ?? item['createdAt'] as String?,
                  ),
                },
              )
              .toList(),
          onItemTap: (itemContext, tappedItem) {
            final idLaporan = tappedItem['id'] as String?;
            if (idLaporan != null) {
              navigateToDetailLaporan(
                itemContext,
                idLaporan: idLaporan,
                jenisLaporan: 'vitamin',
                jenisBudidaya: 'tumbuhan',
              );
            } else {
              showAppToast(
                  context, 'ID laporan tidak ditemukan. Silakan coba lagi.');
            }
          },
        ),
      );
    } else {
      listChildren.add(
        _paddedItem(
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.grass_outlined,
                    size: 48,
                    color: dark2.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat pemberian pupuk',
                    style: medium14.copyWith(color: dark2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lakukan pemberian nutrisi untuk melihat riwayatnya di sini',
                    style:
                        regular12.copyWith(color: dark2.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
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

class _SimplePieChartPainter extends CustomPainter {
  final double sehat;
  final double perluPerhatian;
  final double kritis;

  _SimplePieChartPainter({
    required this.sehat,
    required this.perluPerhatian,
    required this.kritis,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final total = sehat + perluPerhatian + kritis;

    if (total == 0) return;

    double startAngle = -math.pi / 2; // Start from top

    // Colors matching the theme
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw sehat segment
    if (sehat > 0) {
      final sweepAngle = (sehat / total) * 2 * math.pi;
      paint.color = green1;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw perlu perhatian segment
    if (perluPerhatian > 0) {
      final sweepAngle = (perluPerhatian / total) * 2 * math.pi;
      paint.color = Colors.orange;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw kritis segment
    if (kritis > 0) {
      final sweepAngle = (kritis / total) * 2 * math.pi;
      paint.color = red;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }

    // Draw center circle (donut effect)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
