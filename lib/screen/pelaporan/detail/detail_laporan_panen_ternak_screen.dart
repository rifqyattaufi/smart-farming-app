import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailLaporanPanenTernakScreen extends StatefulWidget {
  final String? idLaporanPanenTernak;

  const DetailLaporanPanenTernakScreen({super.key, this.idLaporanPanenTernak});

  @override
  State<DetailLaporanPanenTernakScreen> createState() =>
      _DetailLaporanPanenTernakScreenState();
}

class _DetailLaporanPanenTernakScreenState
    extends State<DetailLaporanPanenTernakScreen> {
  final LaporanService _laporanService = LaporanService();

  bool _isLoading = true;
  Map<String, dynamic>? _laporanPanenTernak;

  Future<void> _fetchData() async {
    try {
      final response = await _laporanService
          .getLaporanPanenById(widget.idLaporanPanenTernak!);

      if (response['status']) {
        setState(() {
          _laporanPanenTernak = response['data'];
        });
      } else {
        showAppToast(context,
            response['message'] ?? 'Gagal memuat data laporan panen ternak.');
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
          title: const Header(
            headerType: HeaderType.back,
            title: 'Laporan Peternakan',
            greeting: 'Detail Laporan Hasil Panen',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _laporanPanenTernak == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          key: const Key('no_data_found'),
                          'Data laporan tidak ditemukan.',
                          style: medium14.copyWith(color: dark2),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          key: const Key('reload_button'),
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
                                      url: _laporanPanenTernak?['gambar'],
                                      fit: BoxFit.cover)),
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
                                if (_laporanPanenTernak?['ObjekBudidaya'] !=
                                    null)
                                  infoItem(
                                      "Kode hewan",
                                      _laporanPanenTernak?["ObjekBudidaya"]
                                              ['namaId'] ??
                                          "-"),
                                infoItem(
                                    "Nama jenis ternak",
                                    _laporanPanenTernak?['UnitBudidaya']
                                            ['JenisBudidaya']['nama'] ??
                                        "-"),
                                infoItem(
                                    "Nama komoditas",
                                    _laporanPanenTernak?['Panen']?['komoditas']
                                            ?['nama'] ??
                                        "-"),
                                infoItem(
                                    "Lokasi ternak",
                                    _laporanPanenTernak?['UnitBudidaya']
                                            ['nama'] ??
                                        "-"),
                                infoItem(
                                    "Jumlah panen",
                                    _laporanPanenTernak?['Panen']['jumlah']
                                            ?.toString() ??
                                        "-"),
                                infoItem("Satuan panen",
                                    "${_laporanPanenTernak?['Panen']['komoditas']['Satuan']['nama'] ?? '-'} - ${_laporanPanenTernak?['Panen']['komoditas']['Satuan']['lambang'] ?? '-'}"),
                                infoItem(
                                    "Pelaporan oleh",
                                    _laporanPanenTernak?['user']['name'] ??
                                        "-"),
                                infoItem(
                                    "Tanggal & waktu pelaporan",
                                    _laporanPanenTernak?["createdAt"] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm',
                                                'id_ID')
                                            .format(DateTime.parse(
                                                    _laporanPanenTernak![
                                                        "createdAt"])
                                                .toLocal())
                                        : "-"),
                                const SizedBox(height: 8),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  _laporanPanenTernak?['catatan'] ?? '-',
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
}
