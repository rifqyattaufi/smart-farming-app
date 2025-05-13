import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_ternak_screen.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';

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
  String? _selectedUnitBudidaya; // Local state to store the selected kandang

  Future<void> _fetchData() async {
    try {
      final response =
          await _unitBudidayaService.getUnitBudidayaByTipe('hewan');
      if (response['status']) {
        setState(() {
          _listKandang = response['data'];
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
                      })
                  .toList(),
              onItemTap: (context, item) {
                setState(() {
                  _selectedUnitBudidaya = item['id']; // Update local state
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
              } else if (widget.tipe == "khusus") {
                context.push('/pilih-ternak',
                    extra: PilihTernakScreen(
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
