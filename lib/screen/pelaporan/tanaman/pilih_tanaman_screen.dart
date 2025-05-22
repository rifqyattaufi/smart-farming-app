import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_harian_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_nutrisi_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_sakit_screen.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_selectedTanaman.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanaman terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.data ?? {});
    updatedData['objekBudidaya'] = _selectedTanaman;

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
      context.push('/pelaporan-harian-tanaman',
          extra: PelaporanHarianTanamanScreen(
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
            _listTanaman.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Tidak ada data yang tersedia. Harap tambahkan data tanaman terlebih dahulu.',
                            style: medium14.copyWith(color: dark2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListItemSelectable(
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: _submitForm,
          buttonText: 'Selanjutnya',
          backgroundColor: green1,
          textStyle: semibold16,
          textColor: white,
        ),
      ),
    );
  }
}
