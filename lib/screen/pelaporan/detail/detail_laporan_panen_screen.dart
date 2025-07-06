import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailLaporanPanenScreen extends StatefulWidget {
  final String idLaporanPanen;

  const DetailLaporanPanenScreen({super.key, required this.idLaporanPanen});

  @override
  State<DetailLaporanPanenScreen> createState() =>
      _DetailLaporanPanenScreenState();
}

class _DetailLaporanPanenScreenState extends State<DetailLaporanPanenScreen> {
  final LaporanService _laporanService = LaporanService();

  bool _isLoading = true;
  Map<String, dynamic>? _laporanPanen;

  Future<void> _fetchLaporanPanen() async {
    try {
      final response =
          await _laporanService.getLaporanPanenKebunById(widget.idLaporanPanen);
      if (response['status']) {
        setState(() {
          _laporanPanen = response['data'];
        });
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal memuat data laporan panen.');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _fetchLaporanPanen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Laporan Perkebunan',
            greeting: 'Detail Laporan Hasil Panen',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _laporanPanen == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          key: const Key('no_data_text'),
                          'Data laporan tidak ditemukan.',
                          style: medium14.copyWith(color: dark2),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          key: const Key('reload_button'),
                          onPressed: _fetchLaporanPanen,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Muat Ulang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green1,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DottedBorder(
                              color: green1,
                              strokeWidth: 1.5,
                              dashPattern: const [6, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ImageBuilder(
                                    url: _laporanPanen?['gambar'],
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Informasi Hasil Panen",
                                    style: bold18.copyWith(color: dark1)),
                                const SizedBox(height: 12),
                                infoItem(
                                    "Tanggal panen",
                                    _laporanPanen?['PanenKebun']
                                                ['tanggalPanen'] !=
                                            null
                                        ? DateFormat(
                                                'EEEE, dd MMMM yyyy', 'id_ID')
                                            .format(DateTime.parse(
                                                _laporanPanen!['PanenKebun']
                                                    ['tanggalPanen']))
                                        : '-'),
                                infoItem(
                                    "Nama jenis tanaman",
                                    _laporanPanen?['UnitBudidaya']
                                            ['JenisBudidaya']['nama'] ??
                                        '-'),
                                infoItem(
                                    "Lokasi tanaman",
                                    _laporanPanen?['UnitBudidaya']['nama'] ??
                                        '-'),
                                infoItem(
                                    "Nama komoditas panen",
                                    _laporanPanen?['PanenKebun']['komoditas']
                                            ['nama'] ??
                                        '-'),
                                infoItem("Estimasi panen",
                                    "${_laporanPanen?['PanenKebun']['estimasiPanen']?.toString() ?? '-'} ${_laporanPanen?['PanenKebun']['komoditas']['Satuan']['lambang'] ?? ''}"),
                                infoItem("Realisasi Panen",
                                    "${_laporanPanen?['PanenKebun']['realisasiPanen']?.toString() ?? '-'} ${_laporanPanen?['PanenKebun']['komoditas']['Satuan']['lambang'] ?? ''}"),
                                infoItem("Umur tanaman saat panen",
                                    "${_laporanPanen?['PanenKebun']['umurTanamanPanen']?.toString() ?? '-'} Hari"),
                                infoItem("Satuan panen",
                                    "${_laporanPanen?['PanenKebun']['komoditas']['Satuan']['nama'] ?? '-'} - ${_laporanPanen?['PanenKebun']['komoditas']['Satuan']['lambang'] ?? '-'}"),
                                infoItem("Pelaporan oleh",
                                    _laporanPanen?['user']['name'] ?? '-'),
                                infoItem(
                                    "Tanggal & waktu pelaporan",
                                    _laporanPanen?["createdAt"] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm',
                                                'id_ID')
                                            .format(DateTime.parse(
                                                    _laporanPanen!["createdAt"])
                                                .toLocal())
                                        : "-"),
                                const SizedBox(height: 8),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  _laporanPanen?['catatan'],
                                  style: regular14.copyWith(color: dark2),
                                ),
                                const SizedBox(height: 8),
                                Text("Detail Grade Hasil Panen",
                                    style: bold18.copyWith(color: dark1)),
                                ...((_laporanPanen?['PanenKebun']
                                                ?['PanenRincianGrades']
                                            as List<dynamic>? ??
                                        [])
                                    .map((grade) {
                                  return infoItem(
                                      '${grade['Grade']['nama'] ?? '-'}',
                                      '${grade['jumlah'] ?? '-'} ${_laporanPanen?['PanenKebun']['komoditas']['Satuan']['lambang'] ?? ''}');
                                }).toList()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }
}
