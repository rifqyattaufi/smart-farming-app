import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_screen.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihKomoditasTanamanScreen extends StatefulWidget {
  final int step;
  final String tipe;
  final String greeting;
  final Map<String, dynamic> data;

  const PilihKomoditasTanamanScreen(
      {super.key,
      this.step = 1,
      this.data = const {},
      required this.tipe,
      required this.greeting});

  @override
  State<PilihKomoditasTanamanScreen> createState() =>
      _PilihKomoditasTanamanScreenState();
}

class _PilihKomoditasTanamanScreenState
    extends State<PilihKomoditasTanamanScreen> {
  final KomoditasService _komoditasService = KomoditasService();
  Map<String, dynamic>? selectedKomoditas;

  List<dynamic> _listKomoditas = [];

  Future<void> _fetchData() async {
    try {
      final response = await _komoditasService.getKomoditasByTipe(tipe: 'tumbuhan');
      if (response['status']) {
        setState(() {
          _listKomoditas = response['data'];
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _submitForm() async {
    if (selectedKomoditas == null) {
      showAppToast(context, 'Silakan pilih komoditas terlebih dahulu');
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.data);
    updatedData['komoditas'] = selectedKomoditas;

    context.push('/pilih-kebun',
        extra: PilihKebunScreen(
            greeting: widget.greeting,
            tipe: widget.tipe,
            step: widget.step + 1,
            data: updatedData));
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            title: 'Pelaporan Khusus',
            greeting: widget.greeting,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Pilih Komoditas',
              subtitle: 'Pilih komoditas yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            _listKomoditas.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            key: const Key('no_data_available'),
                            'Tidak ada data yang tersedia. Harap tambahkan data komoditas terlebih dahulu.',
                            style: medium14.copyWith(color: dark2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListItemSelectable(
                    key: const Key('list_komoditas'),
                    title: 'Daftar Komoditas',
                    type: ListItemType.simple,
                    items: _listKomoditas
                        .map((item) => {
                              'name': item['nama'],
                              'category': item['JenisBudidaya']['nama'],
                              'icon': item['gambar'],
                              'id': item['id'],
                              'jenisBudidayaId': item['JenisBudidaya']['id'],
                              'jenisBudidayaLatin': item['JenisBudidaya']
                                  ['latin'],
                              'satuan': item['SatuanId']
                            })
                        .toList(),
                    onItemTap: (context, item) {
                      setState(() {
                        selectedKomoditas = item;
                      });
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            onPressed: () {
              _submitForm();
            },
            buttonText: 'Selanjutnya',
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            key: const Key('next_button')
          ),
        ),
      ),
    );
  }
}
