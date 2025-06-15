import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class DetailHamaScreen extends StatefulWidget {
  final String? idLaporanHama;

  const DetailHamaScreen({super.key, this.idLaporanHama});

  @override
  State<DetailHamaScreen> createState() => _DetailHamaScreenState();
}

class _DetailHamaScreenState extends State<DetailHamaScreen> {
  final HamaService _hamaService = HamaService();

  Map<String, dynamic>? _laporanHama;
  int _jumlahHama = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.idLaporanHama == null || widget.idLaporanHama!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(context, 'ID laporan hama tidak valid');
          context.pop();
        }
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await _hamaService.getLaporanHamaById(widget.idLaporanHama!);

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _laporanHama = response['data'];
            final hamaData = _laporanHama?['Hama'] as Map<String, dynamic>?;
            final String? jumlahHamaString = hamaData?['jumlah']?.toString();
            _jumlahHama = int.tryParse(jumlahHamaString ?? '0') ?? 0;

            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _laporanHama = null;
          });
          showAppToast(context, response['message'] ?? 'Gagal memuat data');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _laporanHama = null;
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    }
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
            title: 'Laporan Hama',
            greeting: 'Detail Pelaporan Hama',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _laporanHama == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         Text('Gagal memuat detail laporan hama.', style: regular12.copyWith(color: dark2), key: const Key('error_message')),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              key: const Key('retry_button'),
                              onPressed: _fetchData,
                              child: const Text('Coba Lagi'))
                        ],
                      ),
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
                                  url: _laporanHama?['gambar'] as String? ?? '',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Informasi Hama",
                                    style: bold18.copyWith(color: dark1)),
                                const SizedBox(height: 12),
                                infoItem("Nama hama",
                                    "${_laporanHama?['Hama']?['JenisHama']?['nama'] ?? 'Tidak diketahui'}"),
                                infoItem("Terlihat di",
                                    "${_laporanHama?['UnitBudidaya']?['nama'] ?? 'Tidak diketahui'}"),
                                infoItem(
                                    "Jumlah hama teramati",
                                    _jumlahHama > 0
                                        ? "$_jumlahHama ekor"
                                        : 'Tidak diketahui'),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Status hama",
                                          style:
                                              medium14.copyWith(color: dark1)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (_laporanHama?['Hama']
                                                          ?['status'] ==
                                                      true ||
                                                  _laporanHama?['Hama']
                                                          ?['status'] ==
                                                      1)
                                              ? green2.withValues(alpha: 0.1)
                                              : red.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          (_laporanHama?['Hama']?['status'] ==
                                                      true ||
                                                  _laporanHama?['Hama']
                                                          ?['status'] ==
                                                      1)
                                              ? 'Ada'
                                              : 'Tidak Ada',
                                          style: (_laporanHama?['Hama']
                                                          ?['status'] ==
                                                      true ||
                                                  _laporanHama?['Hama']
                                                          ?['status'] ==
                                                      1)
                                              ? regular12.copyWith(
                                                  color: green2)
                                              : regular12.copyWith(color: red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                infoItem(
                                    "Tanggal pelaporan",
                                    formatDisplayDate(
                                        _laporanHama?['createdAt'] as String?)),
                                infoItem(
                                    "Waktu pelaporan",
                                    formatDisplayTime(
                                        _laporanHama?['createdAt'] as String?)),
                                const SizedBox(height: 8),
                                infoItem("Dilaporkan oleh",
                                    "${_laporanHama?['user']?['name'] ?? 'Tidak diketahui'}"),
                                const SizedBox(height: 8),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  _laporanHama?['catatan'] as String? ??
                                      'Tidak ada catatan',
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
}
