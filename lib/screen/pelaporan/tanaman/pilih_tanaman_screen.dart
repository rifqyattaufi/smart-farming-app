import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_nutrisi_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tindakan_massal_screen.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihTanamanScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihTanamanScreen(
      {super.key,
      this.data = const {},
      required this.greeting,
      required this.tipe,
      this.step = 1});

  @override
  State<PilihTanamanScreen> createState() => _PilihTanamanScreenState();
}

class _PilihTanamanScreenState extends State<PilihTanamanScreen> {
  final ObjekBudidayaService _objekBudidayaService = ObjekBudidayaService();

  List<dynamic> _listTanaman = [];
  List<Map<String, dynamic>> _selectedTanaman = [];

  Future<void> _fetchData() async {
    try {
      Map<String, dynamic> response = {};

      response = await _objekBudidayaService
          .getObjekBudidayaByUnitBudidaya(widget.data!['unitBudidaya']['id']);

      if (response['status']) {
        setState(() {
          _listTanaman = response['data'];
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _submitForm() async {
    if (_selectedTanaman.isEmpty) {
      showAppToast(
        context,
        'Harap pilih minimal satu tanaman untuk pelaporan.',
      );
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.data ?? {});
    updatedData['objekBudidaya'] = _selectedTanaman;

    // Jika sudah ada tindakan massal (mode edit), langsung kembali dengan data
    if (widget.data?['tindakanMassal'] != null) {
      Navigator.pop(context, updatedData);
      return;
    }

    // Flow normal untuk pertama kali
    if (widget.tipe == "panen") {
      context.push('/pelaporan-panen-tanaman',
          extra: PelaporanTanamanPanenScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    } else if (widget.tipe == "sakit") {
      context.push('/pelaporan-tanaman-sakit',
          extra: PelaporanTanamanSakitScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    } else if (widget.tipe == "kematian") {
      context.push('/pelaporan-tanaman-mati',
          extra: PelaporanTanamanMatiScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    } else if (widget.tipe == "vitamin") {
      context.push('/pelaporan-nutrisi-tanaman',
          extra: PelaporanNutrisiTanamanScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    } else if (widget.tipe == "harian") {
      context.push('/pelaporan-tindakan-massal',
          extra: PelaporanTindakanMassalScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    }
  }

  @override
  void initState() {
    super.initState();
    // Set pre-selected tanaman jika ada (untuk mode edit)
    if (widget.data?['objekBudidaya'] != null) {
      _selectedTanaman =
          List<Map<String, dynamic>>.from(widget.data!['objekBudidaya']);
    }
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
            title: 'Menu Pelaporan',
            greeting: widget.greeting,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Pilih Tanaman',
              subtitle: 'Pilih tanaman yang akan dilakukan pelaporan!',
              showDate: true,
            ),

            // Banner informasi jika dalam mode edit
            if (widget.data?['objekBudidaya'] != null &&
                widget.data!['objekBudidaya'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mode Edit',
                              style: semibold14.copyWith(
                                  color: Colors.orange.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Anda dapat menambah atau menghapus tanaman yang dipilih. Tanaman yang sudah dipilih sebelumnya akan tetap terseleksi.',
                              style: regular12.copyWith(
                                  color: Colors.orange.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            _listTanaman.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            key: const Key('no_data_available'),
                            'Tidak ada data yang tersedia. Harap tambahkan data tanaman terlebih dahulu.',
                            style: medium14.copyWith(color: dark2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListItemSelectable(
                    key: const Key('list_tanaman'),
                    title: 'Daftar Tanaman', // or 'Pelaporan Per Tanaman'
                    type: ListItemType.basic,
                    items: _listTanaman
                        .map((item) => {
                              'name': item['namaId'],
                              'category': item['UnitBudidaya']['JenisBudidaya']
                                  ['nama'],
                              'icon': item['UnitBudidaya']['JenisBudidaya']
                                  ['gambar'],
                              'id': item['id'],
                              'createdAt': item['createdAt'],
                            })
                        .toList(),
                    onSelectionChanged: (selectedItems) {
                      setState(() {
                        _selectedTanaman = selectedItems;
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
              onPressed: _submitForm,
              buttonText: 'Selanjutnya',
              backgroundColor: green1,
              textStyle: semibold16.copyWith(color: white),
              key: const Key('next_button')),
        ),
      ),
    );
  }
}
