import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_nutrisi_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_tanaman_screen.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_item_selectable.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';

class PilihKebunScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PilihKebunScreen(
      {super.key,
      this.data = const {},
      required this.greeting,
      required this.tipe,
      this.step = 1});

  @override
  State<PilihKebunScreen> createState() => _PilihKebunScreenState();
}

class _PilihKebunScreenState extends State<PilihKebunScreen> {
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  List<dynamic> _listKebun = [];
  Map<String, dynamic>? _selectedUnitBudidaya;
  String _selectedListType = 'tanaman'; // 'tanaman' atau 'kebun'
  String? _selectedFromList; // Track which list the selection came from
  Key _listTanamanKey = UniqueKey(); // Key untuk force rebuild list tanaman
  Key _listKebunKey = UniqueKey(); // Key untuk force rebuild list kebun

  Future<void> _fetchData() async {
    try {
      Map<String, dynamic> response = {};

      if (widget.tipe == "panen") {
        response = await _unitBudidayaService.getUnitBudidayaByJenisBudidaya(
            widget.data!['komoditas']['jenisBudidayaId']);
      } else {
        response = await _unitBudidayaService.getUnitBudidayaByTipe('tumbuhan');
      }

      if (response['status']) {
        setState(() {
          _listKebun = response['data'];
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _submitForm() async {
    if (_selectedUnitBudidaya != null) {
      final updatedData = Map<String, dynamic>.from(widget.data ?? {});
      updatedData['unitBudidaya'] = _selectedUnitBudidaya;

      if (widget.tipe == "panen") {
        context.push('/pelaporan-panen-tanaman',
            extra: PelaporanTanamanPanenScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else if (widget.tipe == 'vitamin' && _selectedListType == 'kebun') {
        context.push('/pelaporan-nutrisi-kebun',
            extra: PelaporanNutrisiKebunScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      } else {
        context.push('/pilih-tanaman',
            extra: PilihTanamanScreen(
                greeting: widget.greeting,
                data: updatedData,
                tipe: widget.tipe,
                step: widget.step + 1));
      }
    } else {
      showAppToast(
        context,
        'Silakan pilih kebun terlebih dahulu',
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
              title: 'Step ${widget.step} - Pilih Kebun',
              subtitle: 'Pilih kebun yang akan dilakukan pelaporan!',
              showDate: true,
            ),
            _listKebun.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            key: const Key('no_data_available'),
                            'Tidak ada data yang tersedia. Harap tambahkan data kebun terlebih dahulu.',
                            style: medium14.copyWith(color: dark2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      ListItemSelectable(
                        key: _listTanamanKey,
                        title: widget.tipe == 'vitamin'
                            ? 'Daftar Kebun (Pelaporan Per Tanaman)'
                            : 'Daftar Kebun',
                        type: ListItemType.simple,
                        items: _listKebun
                            .map((item) => {
                                  'name': item['nama'],
                                  'id': item['id'],
                                  'icon': item['gambar'],
                                  'category': item['JenisBudidaya']['nama'],
                                  'tipe': item['tipe'],
                                  'latin': item['JenisBudidaya']['latin'],
                                  'createdAt': item['createdAt'],
                                })
                            .toList(),
                        onItemTap: (context, item) {
                          setState(() {
                            // Reset selection dari list kebun jika sebelumnya dipilih dari sana
                            if (_selectedFromList == 'kebun') {
                              _listKebunKey =
                                  UniqueKey(); // Force rebuild list kebun untuk reset selection
                            }
                            _selectedUnitBudidaya = item; // Update local state
                            _selectedListType =
                                'tanaman'; // Tandai sebagai selection untuk pelaporan per tanaman
                            _selectedFromList =
                                'tanaman'; // Track dari list mana
                          });
                        },
                      ),

                      // Tambahkan info banner jika tipe vitamin
                      if (widget.tipe == 'vitamin')
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Pilih opsi pelaporan di atas untuk per tanaman, atau di bawah untuk per kebun',
                                    style: regular12.copyWith(
                                        color: Colors.blue.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

            // List kebun kedua khusus untuk tipe vitamin
            if (widget.tipe == 'vitamin' && _listKebun.isNotEmpty)
              ListItemSelectable(
                key: _listKebunKey,
                title: 'Daftar Kebun (Pelaporan Per Kebun)',
                type: ListItemType.simple,
                items: _listKebun
                    .map((item) => {
                          'name': item['nama'],
                          'id': item['id'],
                          'icon': item['gambar'],
                          'category': item['JenisBudidaya']['nama'],
                          'tipe': item['tipe'],
                          'latin': item['JenisBudidaya']['latin'],
                          'createdAt': item['createdAt'],
                        })
                    .toList(),
                onItemTap: (context, item) {
                  setState(() {
                    // Reset selection dari list tanaman jika sebelumnya dipilih dari sana
                    if (_selectedFromList == 'tanaman') {
                      _listTanamanKey =
                          UniqueKey(); // Force rebuild list tanaman untuk reset selection
                    }
                    _selectedUnitBudidaya = item; // Update local state
                    _selectedListType =
                        'kebun'; // Tandai sebagai selection untuk pelaporan per kebun
                    _selectedFromList = 'kebun'; // Track dari list mana
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
