import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailPemakaianInventarisScreen extends StatefulWidget {
  final String? idPemakaianInventaris;

  const DetailPemakaianInventarisScreen(
      {super.key, this.idPemakaianInventaris});

  @override
  State<DetailPemakaianInventarisScreen> createState() =>
      _DetailPemakaianInventarisScreenState();
}

class _DetailPemakaianInventarisScreenState
    extends State<DetailPemakaianInventarisScreen> {
  final InventarisService _inventarisService = InventarisService();

  Map<String, dynamic>? _inventarisDetails;
  int _jumlahPemakaian = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.idPemakaianInventaris == null ||
        widget.idPemakaianInventaris!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID Pemakaian Inventaris tidak valid.'),
              backgroundColor: Colors.red,
            ),
          );
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
      final response = await _inventarisService
          .getPemakaianInventarisById(widget.idPemakaianInventaris!);

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _inventarisDetails = response['data'];
            _jumlahPemakaian = response['data']['jumlah'] ?? 0;
            _isLoading = false;
          });
          print(
              'Data pemakaian inventaris berhasil dimuat: $_inventarisDetails');
        } else {
          setState(() {
            _isLoading = false;
            _inventarisDetails = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ??
                  'Gagal memuat data detail pemakaian inventaris.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _inventarisDetails = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTanggal(String? tanggalString) {
    if (tanggalString == null || tanggalString.isEmpty) {
      return 'Tidak diketahui';
    }
    try {
      final dateTime = DateTime.tryParse(tanggalString);
      if (dateTime == null) return 'Format tanggal tidak valid';
      return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'Error format tanggal';
    }
  }

  String _formatWaktu(String? tanggalString) {
    if (tanggalString == null || tanggalString.isEmpty) {
      return 'Tidak diketahui';
    }
    try {
      final dateTime = DateTime.tryParse(tanggalString);
      if (dateTime == null) return 'Format waktu tidak valid';
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'Error format waktu';
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
            title: 'Riwayat Pemakaian Inventaris',
            greeting: 'Detail Pemakaian Inventaris',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        url: _inventarisDetails?['inventaris']?['gambar'] ?? '',
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
                      Text("Informasi Penggunaan Inventaris",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem(
                          "Kategori inventaris",
                          _inventarisDetails?['inventaris']
                                  ?['kategoriInventaris']?['nama'] ??
                              'Tidak diketahui'),
                      infoItem(
                          "Nama inventaris",
                          _inventarisDetails?['inventaris']?['nama'] ??
                              'Tidak diketahui'),
                      infoItem(
                          "Pemakaian oleh",
                          _inventarisDetails?['laporan']?['user']?['name'] ??
                              'Tidak diketahui'),
                      infoItem("Jumlah digunakan", _jumlahPemakaian.toString()),
                      infoItem(
                        "Satuan",
                        _inventarisDetails?['inventaris']?['Satuan'] != null
                            ? "${_inventarisDetails?['inventaris']?['Satuan']?['nama'] ?? ''} - ${_inventarisDetails?['inventaris']?['Satuan']?['lambang'] ?? ''}"
                            : 'Tidak diketahui',
                      ),
                      infoItem("Tanggal digunakan",
                          _formatTanggal(_inventarisDetails?['createdAt'])),
                      infoItem("Waktu digunakan",
                          _formatWaktu(_inventarisDetails?['createdAt'])),
                      const SizedBox(height: 8),
                      Text("Keperluan penggunaan inventaris",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _inventarisDetails?['laporan']?['catatan'] ??
                            'Tidak diketahui',
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
                        url: _inventarisDetails?['laporan']?['gambar'] ?? '',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
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
