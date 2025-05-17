import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_ternak_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_ternak_sakit_screen.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

class PilihTernakScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihTernakScreen(
      {super.key,
      this.data = const {},
      required this.greeting,
      required this.tipe,
      this.step = 1});

  @override
  State<PilihTernakScreen> createState() => _PilihTernakScreenState();
}

class _PilihTernakScreenState extends State<PilihTernakScreen> {
  final ObjekBudidayaService _objekBudidayaService = ObjekBudidayaService();

  List<dynamic> _listTernak = [];
  List<Map<String, dynamic>> _selectedTernak = []; // Simpan data yang dipilih

  Future<void> _fetchData() async {
    try {
      Map<String, dynamic> response = {};

      response = await _objekBudidayaService
          .getObjekBudidayaByUnitBudidaya(widget.data!['unitBudidaya']['id']);

      if (response['status']) {
        setState(() {
          _listTernak = response['data'];
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
    if (_selectedTernak.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih ternak terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.data ?? {});
    updatedData['objekBudidaya'] = _selectedTernak;

    if (widget.tipe == "panen") {
      context.push('/pelaporan-panen-ternak',
          extra: PelaporanTernakPanenScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step + 1,
          ));
    } else if (widget.tipe == "sakit") {
      context.push('/pelaporan-ternak-sakit',
          extra: PelaporanTernakSakitScreen(
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
              title: 'Step ${widget.step} - Pilih Ternak',
              subtitle: 'Pilih ternak yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItemSelectable(
              title: 'Daftar Ternak',
              type: ListItemType.basic,
              items: _listTernak
                  .map((item) => {
                        'name': item['namaId'],
                        'category': item['UnitBudidaya']['JenisBudidaya']
                            ['nama'],
                        'icon': item['UnitBudidaya']['JenisBudidaya']['gambar'],
                        'id': item['id'],
                      })
                  .toList(),
              onSelectionChanged: (selectedItems) {
                setState(() {
                  _selectedTernak = selectedItems;
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
          onPressed: () {
            _submitForm();
          },
          buttonText: 'Selanjutnya',
          backgroundColor: green1,
          textStyle: semibold16,
          textColor: white,
        ),
      ),
    );
  }
}
