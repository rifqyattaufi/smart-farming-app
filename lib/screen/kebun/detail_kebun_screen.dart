import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailKebunScreen extends StatefulWidget {
  final String? idKebun;

  const DetailKebunScreen({super.key, this.idKebun});

  @override
  State<DetailKebunScreen> createState() => _DetailKebunScreenState();
}

class _DetailKebunScreenState extends State<DetailKebunScreen> {
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();

  Map<String, dynamic>? _kebun;
  List<dynamic>? _tanamanList;

  Future<void> _fetchData() async {
    try {
      final response =
          await _unitBudidayaService.getUnitBudidayaById(widget.idKebun!);
      setState(() {
        _kebun = response['data']['unitBudidaya'];
        _tanamanList = response['data']['objekBudidaya'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteData() async {
    try {
      final response =
          await _unitBudidayaService.deleteUnitBudidaya(widget.idKebun ?? '');
      if (response['status']) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: $e'),
          backgroundColor: Colors.red,
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
            title: 'Daftar Kebun',
            greeting: 'Detail Kebun',
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
                        url: _kebun?['gambar'] ?? '',
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
                      Text("Informasi Kebun",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama kebun", _kebun?['nama'] ?? ''),
                      infoItem("Lokasi kebun", _kebun?['lokasi'] ?? ''),
                      infoItem("Luas kebun", "${_kebun?['luas'] ?? ''} m2"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status kebun",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kebun?['status'] == true
                                    ? green2.withValues(alpha: .1)
                                    : red.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _kebun?['status'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: _kebun?['status'] == true
                                    ? regular12.copyWith(color: green2)
                                    : regular12.copyWith(color: red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem("Jumlah Tanaman",
                          _kebun?['jumlah']?.toString() ?? ''),
                      infoItem(
                          "Tanggal didaftarkan",
                          _kebun?['createdAt'] != null
                              ? DateFormat('EEEE, dd MMMM yyyy').format(
                                  DateTime.tryParse(_kebun?['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      infoItem(
                          "Waktu didaftarkan",
                          _kebun?['createdAt'] != null
                              ? DateFormat('HH:mm').format(
                                  DateTime.tryParse(_kebun?['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      const SizedBox(height: 8),
                      Text("Deskripsi kebun",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _kebun?['deskripsi'] ?? 'Tidak ada deskripsi',
                        style: regular14.copyWith(color: dark2),
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Tanaman',
                  type: 'basic',
                  items: (_tanamanList ?? [])
                      .map((tanaman) => {
                            'name': tanaman['namaId'],
                            'icon': tanaman['UnitBudidaya']['JenisBudidaya']
                                ['gambar'],
                            'category': tanaman['UnitBudidaya']['JenisBudidaya']
                                ['nama'],
                            'id': tanaman['id'],
                          })
                      .toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
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
                context.push('/tambah-kebun',
                    extra: AddKebunScreen(
                      isEdit: true,
                      idKebun: widget.idKebun,
                      onKebunAdded: () => _fetchData(),
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
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus kebun ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
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
}
