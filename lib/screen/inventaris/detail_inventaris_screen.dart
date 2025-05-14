import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailInventarisScreen extends StatefulWidget {
  final String? idInventaris;

  const DetailInventarisScreen({super.key, this.idInventaris});

  @override
  State<DetailInventarisScreen> createState() => _DetailInventarisScreenState();
}

class _DetailInventarisScreenState extends State<DetailInventarisScreen> {
  final InventarisService _inventarisService = InventarisService();

  Map<String, dynamic>? _inventaris = {};
  List<dynamic> _riwayatPemakaianList = [];

  Future<void> _fetchData() async {
    try {
      final response =
          await _inventarisService.getInventarisById(widget.idInventaris ?? '');

      if (response['status']) {
        setState(() {
          _inventaris = response['data']['data'] ?? {};
          _riwayatPemakaianList = response['data']['daftarPemakaian'] ?? [];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['message']}'),
            // backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          // backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteData() async {
    final response =
        await _inventarisService.deleteInventaris(widget.idInventaris ?? '');
    if (response['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menghapus data inventaris'),
          // backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: ${response['message']}'),
          // backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? kategori = _inventaris?['kategoriInventaris'];
    final Map<String, dynamic>? satuan = _inventaris?['Satuan'];
    final String ketersediaan = _inventaris?['ketersediaan'] ?? 'Unknown';
    final String kondisi = _inventaris?['kondisi'] ?? 'Unknown';
    final String satuanNama = satuan?['nama'] ?? '';
    final String satuanLambang = satuan?['lambang'] ?? '';
    final int jumlah = _inventaris?['jumlah'] ?? 0;

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
            title: 'Manajemen Inventaris',
            greeting: 'Detail Inventaris',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      url: _inventaris?['gambar'] ?? '',
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
                    Text("Informasi Inventaris",
                        style: bold18.copyWith(color: dark1)),
                    const SizedBox(height: 12),
                    infoItem(
                        "Nama inventaris", _inventaris?['nama'] ?? 'Unknown'),
                    infoItem(
                        "Kategori inventaris", kategori?['nama'] ?? 'Unknown'),
                    infoItem("Jumlah Stok",
                        '$jumlah ${satuanLambang.isNotEmpty ? satuanLambang : ""}'),
                    infoItem("Satuan", satuanNama.isNotEmpty ? satuanNama : ""),
                    _buildKetersediaan("Ketersediaan inventaris", ketersediaan),
                    _buildKondisi("Kondisi inventaris", kondisi),
                    infoItem(
                      "Tanggal kadaluwarsa",
                      _inventaris?['tanggalKadaluwarsa'] != null
                          ? DateFormat('EEEE, dd MMMM yyyy').format(
                              DateTime.tryParse(
                                      _inventaris!['tanggalKadaluwarsa']) ??
                                  DateTime(0))
                          : 'Unknown datetime',
                    ),
                    infoItem(
                      "Waktu kadaluwarsa",
                      _inventaris?['tanggalKadaluwarsa'] != null
                          ? DateFormat('HH:mm').format(DateTime.tryParse(
                                  _inventaris!['tanggalKadaluwarsa']) ??
                              DateTime(0))
                          : 'Unknown datetime',
                    ),
                    infoItem(
                      "Tanggal didaftarkan",
                      _inventaris?['createdAt'] != null
                          ? DateFormat('EEEE, dd MMMM yyyy').format(
                              DateTime.tryParse(_inventaris!['createdAt']) ??
                                  DateTime(0))
                          : 'Unknown date',
                    ),
                    infoItem(
                      "Waktu didaftarkan",
                      _inventaris?['createdAt'] != null
                          ? DateFormat('HH:mm').format(
                              DateTime.tryParse(_inventaris!['createdAt']) ??
                                  DateTime(0))
                          : 'Unknown time',
                    ),
                    const SizedBox(height: 8),
                    Text("Deskripsi inventaris",
                        style: medium14.copyWith(color: dark1)),
                    const SizedBox(height: 8),
                    Text(
                      _inventaris?['detail'] ?? 'Tidak ada deskripsi',
                      style: regular14.copyWith(color: dark2),
                    ),
                  ],
                ),
              ),
              ListItem(
                title: 'Riwayat Pemakaian Inventaris',
                type: 'history',
                items: _riwayatPemakaianList.isNotEmpty
                    ? _riwayatPemakaianList.map((item) {
                        return {
                          'name': _inventaris?['nama'] ?? 'Unknown',
                          'category': kategori?['nama'] ?? 'Unknown',
                          'image': item['laporanGambar'] ??
                              'assets/images/default.png',
                          'person': item['petugasNama'] ?? 'Unknown',
                          'date': item['laporanTanggal'] ?? 'Unknown date',
                          'time': item['laporanWaktu'] ?? 'Unknown time',
                        };
                      }).toList()
                    : [],
                onItemTap: (context, item) {
                  final laporanId = item['id'] ?? '';
                  context.push('/detail-laporan/$laporanId');
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: () {
                context.push('/tambah-inventaris',
                    extra: AddInventarisScreen(
                      onInventarisAdded: () => _fetchData(),
                      isEdit: true,
                      idInventaris: widget.idInventaris,
                    ));
              },
              buttonText: 'Ubah Data',
              backgroundColor: yellow2,
              textStyle: semibold16,
              textColor: white,
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus data ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldDelete == true) {
                  await _deleteData();
                }
              },
              buttonText: 'Hapus Data',
              backgroundColor: red,
              textStyle: semibold16,
              textColor: white,
            ),
          ],
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

  Widget _buildKetersediaan(String label, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'tersedia':
        backgroundColor = green2.withValues(alpha: .1);
        textColor = green2;
        displayText = 'Tersedia';
        break;
      case 'tidak tersedia':
        backgroundColor = red.withValues(alpha: .1);
        textColor = red;
        displayText = 'Tidak Tersedia';
        break;
      default:
        backgroundColor = yellow.withValues(alpha: .1);
        textColor = yellow;
        displayText = 'Kadaluwarsa';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                Text(displayText, style: regular12.copyWith(color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildKondisi(String label, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    if (status == 'baik') {
      backgroundColor = green2.withValues(alpha: .1);
      textColor = green2;
      displayText = 'Baik';
    } else {
      backgroundColor = yellow.withValues(alpha: .1);
      textColor = yellow;
      displayText = 'Rusak';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                Text(displayText, style: regular12.copyWith(color: textColor)),
          ),
        ],
      ),
    );
  }
}
