import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailLaporanSakitScreen extends StatefulWidget {
  final String? idLaporanSakit;

  const DetailLaporanSakitScreen({super.key, this.idLaporanSakit});

  @override
  State<DetailLaporanSakitScreen> createState() =>
      _DetailLaporanSakitScreenState();
}

class _DetailLaporanSakitScreenState extends State<DetailLaporanSakitScreen> {
  final LaporanService _laporanService = LaporanService();

  bool isLoading = true;
  Map<String, dynamic>? laporanSakit;

  Future<void> fetchData() async {
    try {
      final response =
          await _laporanService.getLaporanSakitById(widget.idLaporanSakit!);

      if (response['status']) {
        setState(() {
          laporanSakit = response['data'];
        });
      } else {
        showAppToast(context, response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
          title: Header(
            headerType: HeaderType.back,
            title: _getJudulLaporan(),
            greeting: _getGreetingLaporan(),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : laporanSakit == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Data laporan tidak ditemukan.',
                          style: medium14.copyWith(color: dark2),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: fetchData,
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
                                      url: laporanSakit?['gambar'],
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Informasi ${laporanSakit?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''} Sakit",
                                    style: bold18.copyWith(color: dark1)),
                                const SizedBox(height: 12),
                                if (laporanSakit?['ObjekBudidaya'] != null)
                                  infoItem(
                                      "Kode ${laporanSakit?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                      laporanSakit?["ObjekBudidaya"]
                                              ['namaId'] ??
                                          "-"),
                                infoItem(
                                    "Nama jenis ${laporanSakit?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                    laporanSakit?["UnitBudidaya"]
                                            ['JenisBudidaya']['nama'] ??
                                        "-"),
                                infoItem(
                                    "Lokasi ${laporanSakit?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                    laporanSakit?["UnitBudidaya"]['nama'] ??
                                        "-"),
                                infoItem("Nama penyakit",
                                    laporanSakit?['Sakit']['penyakit']),
                                infoItem("Pelaporan oleh",
                                    laporanSakit?['user']['name']),
                                infoItem(
                                    "Tanggal & waktu pelaporan",
                                    laporanSakit?["createdAt"] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm',
                                                'id_ID')
                                            .format(DateTime.parse(
                                                    laporanSakit!["createdAt"])
                                                .toLocal())
                                        : "-"),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  laporanSakit?['catatan'] ?? '-',
                                  style: regular14.copyWith(color: dark2),
                                ),
                              ],
                            ),
                          ),
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

  String _getJudulLaporan() {
    final tipe = laporanSakit?['UnitBudidaya']?['JenisBudidaya']?['tipe'];
    if (tipe == 'hewan') return 'Laporan Peternakan';
    if (tipe == 'tumbuhan') return 'Laporan Perkebunan';
    return 'Laporan';
  }

  String _getGreetingLaporan() {
    final tipe = laporanSakit?['UnitBudidaya']?['JenisBudidaya']?['tipe'];
    if (tipe == null) return '';
    return 'Detail Laporan ${tipe[0].toUpperCase()}${tipe.substring(1)} Mati';
  }
}
