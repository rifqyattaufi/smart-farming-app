import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailKandangScreen extends StatefulWidget {
  final String? idKandang;

  const DetailKandangScreen({super.key, this.idKandang});

  @override
  State<DetailKandangScreen> createState() => _DetailKandangScreenState();
}

class _DetailKandangScreenState extends State<DetailKandangScreen> {
  UnitBudidayaService _unitBudidayaService = UnitBudidayaService();

  Map<String, dynamic> _kandang = {};
  List<dynamic> _ternakList = [];

  Future<void> _fetchData() async {
    try {
      final response = await _unitBudidayaService
          .getUnitBudidayaById(widget.idKandang ?? '');
      setState(() {
        _kandang = response['data']['unitBudidaya'];
        _ternakList = response['data']['objekBudidaya'];
      });
    } catch (e) {
      setState(() {
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
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
            title: 'Daftar Kandang',
            greeting: 'Detail Kandang',
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
                          url: _kandang['gambar'] ?? '',
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informasi Kandang",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama kandang", _kandang['nama'] ?? ''),
                      infoItem("Lokasi kandang", _kandang['lokasi'] ?? ''),
                      infoItem("Luas kandang", "${_kandang['luas']} m2"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status kandang",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kandang['status'] == true
                                    ? green2.withOpacity(0.1)
                                    : red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _kandang['status'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: _kandang['status'] == true
                                    ? regular12.copyWith(color: green2)
                                    : regular12.copyWith(color: red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem("Tipe kandang", _kandang['tipe'] ?? ''),
                      infoItem(
                          "Jumlah Hewan", _kandang['jumlah']?.toString() ?? ''),
                      infoItem(
                          "Tanggal didaftarkan",
                          _kandang['createdAt'] != null
                              ? DateFormat('EEEE, dd MMMM yyyy').format(
                                  DateTime.tryParse(_kandang['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      infoItem(
                          "Waktu didaftarkan",
                          _kandang['createdAt'] != null
                              ? DateFormat('HH:mm').format(
                                  DateTime.tryParse(_kandang['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      const SizedBox(height: 8),
                      Text("Deskripsi kandang",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _kandang['deskripsi'] ?? 'Tidak ada deskripsi',
                        style: regular14.copyWith(color: dark2),
                      ),
                    ],
                  ),
                ),
                if (_kandang['tipe'] == "individu")
                  ListItem(
                    title: 'Daftar Ternak',
                    type: 'basic',
                    items: _ternakList
                        .map((ternak) => {
                              'name': ternak['namaId'],
                              'category': ternak['UnitBudidaya']
                                  ['JenisBudidaya']['nama'],
                              'icon': ternak['UnitBudidaya']['JenisBudidaya']
                                  ['gambar'],
                              'id': ternak['id'],
                            })
                        .toList(),
                    onItemTap: (context, item) {
                      final name = item['name'] ?? '';
                      context.push('/detail-laporan/$name');
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
        child: CustomButton(
          onPressed: () {
            context.push('/tambah-kandang',
                extra: AddKandangScreen(
                  isEdit: true,
                  idKandang: widget.idKandang,
                  onKandangAdded: () => _fetchData(),
                ));
          },
          buttonText: 'Ubah Data',
          backgroundColor: yellow2,
          textStyle: semibold16,
          textColor: white,
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
