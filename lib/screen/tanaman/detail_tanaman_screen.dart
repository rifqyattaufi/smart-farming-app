import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailTanamanScreen extends StatefulWidget {
  final String? idTanaman;

  const DetailTanamanScreen({super.key, this.idTanaman});

  @override
  State<DetailTanamanScreen> createState() => _DetailTanamanScreenState();
}

class _DetailTanamanScreenState extends State<DetailTanamanScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();

  Map<String, dynamic> _tanaman = {};
  List<dynamic> _kebunList = [];
  int _jumlahTanaman = 0;

  Future<void> _fetchData() async {
    try {
      final response = await _jenisBudidayaService
          .getJenisBudidayaById(widget.idTanaman ?? '');
      setState(() {
        _tanaman = response['data']['jenisBudidaya'];
        _kebunList = response['data']['unitBudidaya'];
        _jumlahTanaman = response['data']['jumlahBudidaya'] ?? 0;
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
    final response =
        await _jenisBudidayaService.deleteJenisBudidaya(widget.idTanaman ?? '');
    if (response['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: ${response['message']}'),
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
            title: 'Daftar Jenis Tanaman',
            greeting: 'Detail Jenis Tanaman',
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
                        url: _tanaman['gambar'] ?? '',
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
                      Text("Informasi Jenis Tanaman",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama jenis tanaman", _tanaman['nama'] ?? ''),
                      infoItem("Nama latin", _tanaman['latin'] ?? ''),
                      infoItem("Jumlah tanaman", '$_jumlahTanaman tanaman'),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status tanaman",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _tanaman['status'] == true
                                    ? green2.withValues(alpha: .1)
                                    : red.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _tanaman['status'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: _tanaman['status'] == true
                                    ? regular12.copyWith(color: green2)
                                    : regular12.copyWith(color: red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem(
                          "Tanggal didaftarkan",
                          _tanaman['createdAt'] != null
                              ? DateFormat('EEEE, dd MMMM yyyy').format(
                                  DateTime.tryParse(_tanaman['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      infoItem(
                          "Waktu didaftarkan",
                          _tanaman['createdAt'] != null
                              ? DateFormat('HH:mm').format(
                                  DateTime.tryParse(_tanaman['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      const SizedBox(height: 8),
                      Text("Deskripsi tanaman",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _tanaman['detail'] ?? 'Tidak ada deskripsi',
                        style: regular14.copyWith(color: dark2),
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Tanaman',
                  type: 'basic',
                  items: _kebunList.map((item) {
                    return {
                      'name': item['nama'],
                      'icon': item['gambar'],
                      'id': item['id'],
                      'isActive': item['status'],
                    };
                  }).toList(),
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context.push('/detail-kebun/$id').then((_) {
                      _fetchData();
                    });
                  },
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
                context.push('/tambah-tanaman',
                    extra: AddTanamanScreen(
                      onTanamanAdded: () => _fetchData(),
                      isEdit: true,
                      idTanaman: widget.idTanaman,
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
}
