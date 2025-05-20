import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_kematian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_nutrisi_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_ternak_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_ternak_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_ternak_screen.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';
import 'package:flutter/scheduler.dart';

class PilihKandangScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihKandangScreen(
      {super.key,
      this.data = const {},
      required this.greeting,
      required this.tipe,
      this.step = 1});

  @override
  State<PilihKandangScreen> createState() => _PilihKandangScreenState();
}

class _PilihKandangScreenState extends State<PilihKandangScreen> {
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  List<dynamic> _listKandang = [];
  Map<String, dynamic>? _selectedUnitBudidaya;

  Future<void> _fetchData() async {
    try {
      Map<String, dynamic> response = {};

      if (widget.tipe == "panen") {
        response = await _unitBudidayaService.getUnitBudidayaByJenisBudidaya(
            widget.data!['komoditas']['jenisBudidayaId']);
      } else {
        response = await _unitBudidayaService.getUnitBudidayaByTipe('hewan');
      }

      if (response['status']) {
        setState(() {
          _listKandang = response['data'];
        });
      }
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _submitForm() async {
    if (_selectedUnitBudidaya != null) {
      final updatedData = Map<String, dynamic>.from(widget.data ?? {});
      updatedData['unitBudidaya'] = _selectedUnitBudidaya;

      if (widget.tipe == "harian") {
        context.push('/pelaporan-harian-ternak',
            extra: PelaporanHarianTernakScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else if (_selectedUnitBudidaya!['tipe'] == "individu") {
        context.push('/pilih-ternak',
            extra: PilihTernakScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else if (widget.tipe == "panen") {
        context.push('/pelaporan-panen-ternak',
            extra: PelaporanTernakPanenScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else if (widget.tipe == "sakit") {
        context.push('/pelaporan-ternak-sakit',
            extra: PelaporanTernakSakitScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else if (widget.tipe == "kematian") {
        context.push('/pelaporan-kematian-ternak',
            extra: PelaporanKematianTernakScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else if (widget.tipe == "vitamin") {
        context.push('/pelaporan-nutrisi-ternak',
            extra: PelaporanNutrisiTernakScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kandang terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
              title: 'Step ${widget.step} - Pilih Kandang',
              subtitle: 'Pilih kandang yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            ListItemSelectable(
              title: 'Daftar Kandang',
              type: ListItemType.simple,
              items: _listKandang
                  .map((item) => {
                        'name': item['nama'],
                        'id': item['id'],
                        'icon': item['gambar'],
                        'category': item['JenisBudidaya']['nama'],
                        'tipe': item['tipe'],
                        'latin': item['JenisBudidaya']['latin']
                      })
                  .toList(),
              onItemTap: (context, item) {
                setState(() {
                  _selectedUnitBudidaya = item; // Update local state
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
