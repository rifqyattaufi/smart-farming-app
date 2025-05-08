import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailTernakScreen extends StatefulWidget {
  final String? idTernak;

  const DetailTernakScreen({super.key, this.idTernak});

  @override
  State<DetailTernakScreen> createState() => _DetailTernakScreenState();
}

class _DetailTernakScreenState extends State<DetailTernakScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();

  Map<String, dynamic>? _ternak;
  List<dynamic>? _kandangList;
  int _jumlahTernak = 0;

  Future<void> _fetchData() async {
    try {
      final response = await _jenisBudidayaService
          .getJenisBudidayaById(widget.idTernak ?? '');
      setState(() {
        _ternak = response['data']['jenisBudidaya'];
        _kandangList = response['data']['unitBudidaya'];
        _jumlahTernak = response['data']['jumlahTernak'] ?? 0;
      });
    } catch (e) {
      setState(() {});
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
        await _jenisBudidayaService.deleteJenisBudidaya(widget.idTernak ?? '');
    if (response['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menghapus data ternak'),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
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
            title: 'Daftar Jenis Ternak',
            greeting: 'Detail Jenis Ternak',
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
                          url: _ternak?['gambar'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informasi Jenis Ternak",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama jenis ternak", _ternak?['nama'] ?? ''),
                      infoItem("Nama latin", _ternak?['latin'] ?? ''),
                      infoItem("Jumlah ternak", "$_jumlahTernak ekor"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status ternak",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _ternak?['status'] == true
                                    ? green2.withOpacity(0.1)
                                    : red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _ternak?['status'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: _ternak?['status'] == true
                                    ? regular12.copyWith(color: green2)
                                    : regular12.copyWith(color: red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem(
                          "Tanggal didaftarkan",
                          _ternak?['createdAt'] != null
                              ? DateFormat('EEEE, dd MMMM yyyy').format(
                                  DateTime.tryParse(_ternak?['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      infoItem(
                          "Waktu didaftarkan",
                          _ternak?['createdAt'] != null
                              ? DateFormat('HH:mm').format(
                                  DateTime.tryParse(_ternak?['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      const SizedBox(height: 8),
                      Text("Deskripsi ternak",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _ternak?['detail'] ?? 'Tidak ada deskripsi',
                        style: regular14.copyWith(color: dark2),
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Kandang',
                  type: 'basic',
                  items: _kandangList
                          ?.map((kandang) => {
                                'name': kandang['nama'],
                                'isActive': kandang['status'],
                                'icon': kandang['gambar'],
                                'id': kandang['id'],
                              })
                          .toList() ??
                      [],
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context.push('/detail-kandang/$id').then((_) {
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
                context.push('/tambah-ternak',
                    extra: AddTernakScreen(
                      isEdit: true,
                      idTernak: widget.idTernak,
                      onTernakAdded: () => _fetchData(),
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
                        'Apakah Anda yakin ingin menghapus Ternak ini?'),
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
