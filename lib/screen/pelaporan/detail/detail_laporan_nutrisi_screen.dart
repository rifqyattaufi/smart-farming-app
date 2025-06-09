import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailLaporanNutrisiScreen extends StatefulWidget {
  final String? idLaporanNutrisi;

  const DetailLaporanNutrisiScreen({super.key, this.idLaporanNutrisi});

  @override
  State<DetailLaporanNutrisiScreen> createState() =>
      _DetailLaporanNutrisiScreenState();
}

class _DetailLaporanNutrisiScreenState
    extends State<DetailLaporanNutrisiScreen> {
  final LaporanService _laporanService = LaporanService();

  bool isLoading = true;
  Map<String, dynamic>? laporanNutrisi;

  Future<void> fetchLaporanNutrisi() async {
    try {
      final response =
          await _laporanService.getLaporanNutrisiById(widget.idLaporanNutrisi!);
      if (response['status']) {
        setState(() {
          laporanNutrisi = response['data'];
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
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    fetchLaporanNutrisi();
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
            greeting: 'Detail Laporan Pemberian Nutrisi',
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : laporanNutrisi == null
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
                          onPressed: fetchLaporanNutrisi,
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
                                      url: laporanNutrisi?['Vitamin']
                                              ['inventaris']['gambar'] ??
                                          '',
                                      fit: BoxFit.cover)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Informasi Penggunaan Inventaris",
                                    style: bold18.copyWith(color: dark1)),
                                const SizedBox(height: 12),
                                infoItem(
                                    "Kategori inventaris",
                                    laporanNutrisi?['Vitamin']['inventaris']
                                        ['kategoriInventaris']['nama']),
                                infoItem(
                                    "Nama inventaris",
                                    laporanNutrisi?['Vitamin']['inventaris']
                                        ['nama']),
                                infoItem(
                                    "Jumlah digunakan",
                                    laporanNutrisi?['Vitamin']['jumlah']
                                            ?.toString() ??
                                        "-"),
                                infoItem("Satuan",
                                    "${laporanNutrisi?['Vitamin']['inventaris']['Satuan']['nama']} - ${laporanNutrisi?['Vitamin']['inventaris']['Satuan']['lambang']}"),
                                if (laporanNutrisi?['ObjekBudidaya'] != null)
                                  infoItem(
                                      "Kode ${laporanNutrisi?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                      laporanNutrisi?["ObjekBudidaya"]
                                              ['namaId'] ??
                                          "-"),
                                infoItem(
                                    "Nama jenis ${laporanNutrisi?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                    laporanNutrisi?["UnitBudidaya"]
                                            ['JenisBudidaya']['nama'] ??
                                        "-"),
                                infoItem(
                                    "Lokasi ${laporanNutrisi?['UnitBudidaya']['JenisBudidaya']['tipe'] ?? ''}",
                                    laporanNutrisi?["UnitBudidaya"]['nama'] ??
                                        "-"),
                                infoItem("Pelaporan oleh",
                                    laporanNutrisi?['user']?['name'] ?? "-"),
                                infoItem(
                                    "Tanggal & waktu pelaporan",
                                    laporanNutrisi?["createdAt"] != null
                                        ? DateFormat('EEEE, dd MMMM yyyy HH:mm',
                                                'id_ID')
                                            .format(DateTime.parse(
                                                    laporanNutrisi![
                                                        "createdAt"])
                                                .toLocal())
                                        : "-"),
                                const SizedBox(height: 8),
                                Text("Catatan/jurnal pelaporan",
                                    style: medium14.copyWith(color: dark1)),
                                const SizedBox(height: 8),
                                Text(
                                  laporanNutrisi?['catatan'] ?? '-',
                                  style: regular14.copyWith(color: dark2),
                                ),
                                const SizedBox(height: 16),
                                Text("Bukti penggunaan inventaris",
                                    style: medium14.copyWith(color: dark1)),
                              ],
                            ),
                          ),
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
                                    url: laporanNutrisi?['gambar'],
                                    fit: BoxFit.cover),
                              ),
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
        crossAxisAlignment: CrossAxisAlignment
            .start, // Agar label sejajar dengan baris pertama value jika value wrap
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          const SizedBox(
              width: 16), // Beri sedikit jarak antara label dan value
          Expanded(
            // Bungkus Text value dengan Expanded
            child: Text(
              value,
              style: regular14.copyWith(color: dark2),
              textAlign: TextAlign.end, // Agar teks value rata kanan
            ),
          ),
        ],
      ),
    );
  }
}
