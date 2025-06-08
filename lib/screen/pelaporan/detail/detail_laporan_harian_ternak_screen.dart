import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailLaporanHarianTernakScreen extends StatefulWidget {
  final String? idLaporanHarianTernak;

  const DetailLaporanHarianTernakScreen(
      {super.key, this.idLaporanHarianTernak});

  @override
  State<DetailLaporanHarianTernakScreen> createState() =>
      _DetailLaporanHarianTernakScreenState();
}

class _DetailLaporanHarianTernakScreenState
    extends State<DetailLaporanHarianTernakScreen> {
  final LaporanService _laporanService = LaporanService();

  bool _isLoading = true;
  Map<String, dynamic>? _laporanHarian;

  Future<void> _fetchData() async {
    try {
      final response = await _laporanService
          .getLaporanHarianTernakById(widget.idLaporanHarianTernak!);

      if (response['status']) {
        setState(() {
          _laporanHarian = response['data'];
        });
      } else {
        showAppToast(context,
            response['message'] ?? 'Gagal memuat data laporan harian.');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _fetchData();
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
            title: 'Laporan Peternakan',
            greeting: 'Detail Laporan Harian',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _laporanHarian == null
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
                          onPressed: _fetchData,
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
                                      url: _laporanHarian?['gambar'],
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Informasi Laporan Harian",
                                    style: bold18.copyWith(color: dark1)),
                                const SizedBox(height: 12),
                                infoItem(
                                    "Nama jenis ternak",
                                    _laporanHarian?['UnitBudidaya']
                                        ['JenisBudidaya']['nama']),
                                infoItem("Lokasi ternak",
                                    _laporanHarian?['UnitBudidaya']['nama']),
                                statusItem("Pemberian Pakan",
                                    _laporanHarian?['HarianTernak']['pakan']),
                                statusItem(
                                    "Pengecekan Kandang",
                                    _laporanHarian?['HarianTernak']
                                        ['cekKandang']),
                                infoItem("Pelaporan oleh",
                                    _laporanHarian?['User']['name']),
                                infoItem(
                                    "Tanggal & waktu pelaporan",
                                    _laporanHarian?["createdAt"] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm')
                                            .format(DateTime.parse(
                                                _laporanHarian!["createdAt"]))
                                        : "-"),
                                const SizedBox(height: 8),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  _laporanHarian?['catatan'],
                                  style: regular14.copyWith(color: dark2),
                                ),
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

  Widget statusItem(String title, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: medium14.copyWith(color: dark1)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status
                    ? green2.withValues(alpha: 0.1)
                    : red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: status
                  ? Text(
                      'Ya',
                      style: regular12.copyWith(color: green2),
                    )
                  : Text(
                      'Tidak',
                      style: regular12.copyWith(color: red),
                    )),
        ],
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
