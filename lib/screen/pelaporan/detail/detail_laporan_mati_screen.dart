import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailLaporanMatiScreen extends StatefulWidget {
  final String? idLaporanMati;

  const DetailLaporanMatiScreen({super.key, this.idLaporanMati});

  @override
  State<DetailLaporanMatiScreen> createState() =>
      _DetailLaporanMatiScreenState();
}

class _DetailLaporanMatiScreenState extends State<DetailLaporanMatiScreen> {
  final LaporanService _laporanService = LaporanService();

  bool _isLoading = true;
  Map<String, dynamic>? _laporanMati;

  Future<void> _fetchData() async {
    try {
      final response =
          await _laporanService.getLaporanKematianById(widget.idLaporanMati!);

      if (response['status']) {
        setState(() {
          _laporanMati = response['data'];
        });
      } else {
        showAppToast(context,
            response['message'] ?? 'Gagal memuat data laporan kematian.');
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
          title: Header(
            headerType: HeaderType.back,
            title: _getJudulLaporan(),
            greeting: _getGreetingLaporan(),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _laporanMati == null
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
                                    url: _laporanMati?['gambar'],
                                    fit: BoxFit.cover,
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Informasi ${_laporanMati?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''} mati",
                                    style: bold18.copyWith(color: dark1)),
                                const SizedBox(height: 12),
                                if (_laporanMati?['ObjekBudidaya'] != null)
                                  infoItem(
                                      "Kode ${_laporanMati?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                      _laporanMati?["ObjekBudidaya"]
                                              ['namaId'] ??
                                          "-"),
                                infoItem(
                                    "Nama jenis ${_laporanMati?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                    _laporanMati?["UnitBudidaya"]
                                            ['JenisBudidaya']['nama'] ??
                                        "-"),
                                infoItem(
                                    "Lokasi ${_laporanMati?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                    _laporanMati?["UnitBudidaya"]['nama'] ??
                                        "-"),
                                infoItem(
                                    "Penyebab kematian",
                                    _laporanMati?['Kematian']['penyebab'] ??
                                        "-"),
                                infoItem(
                                    "Tanggal & waktu kematian",
                                    _laporanMati?["Kematian"]['tanggal'] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm',
                                                "id_ID")
                                            .format(DateTime.parse(
                                                _laporanMati!["Kematian"]
                                                    ['tanggal']))
                                        : "-"),
                                infoItem("Pelaporan oleh",
                                    _laporanMati?["user"]['name'] ?? "-"),
                                infoItem(
                                    "Tanggal & waktu pelaporan",
                                    _laporanMati?["createdAt"] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm',
                                                'id_ID')
                                            .format(DateTime.parse(
                                                    _laporanMati!["createdAt"])
                                                .toLocal())
                                        : "-"),
                                const SizedBox(height: 8),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  _laporanMati?["catatan"] ?? "-",
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
    final tipe = _laporanMati?['UnitBudidaya']?['JenisBudidaya']?['tipe'];
    if (tipe == 'hewan') return 'Laporan Peternakan';
    if (tipe == 'tumbuhan') return 'Laporan Perkebunan';
    return 'Laporan';
  }

  String _getGreetingLaporan() {
    final tipe = _laporanMati?['UnitBudidaya']?['JenisBudidaya']?['tipe'];
    if (tipe == null) return '';
    return 'Detail Laporan ${tipe[0].toUpperCase()}${tipe.substring(1)} Mati';
  }
}
