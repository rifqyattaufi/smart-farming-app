import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/satuan/add_satuan_screen.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

class SatuanScreen extends StatefulWidget {
  const SatuanScreen({super.key});

  @override
  State<SatuanScreen> createState() => _SatuanScreenState();
}

class _SatuanScreenState extends State<SatuanScreen> {
  final SatuanService _satuanService = SatuanService();
  List<dynamic> satuanList = [];
  List<dynamic> filteredSatuanList = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSatuan();
  }

  void _searchSatuan(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredSatuanList = satuanList;
      });
    } else {
      final response = await _satuanService.getSatuanSearch(query);

      if (response['status'] == true) {
        setState(() {
          filteredSatuanList = response['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  Future<void> _fetchSatuan() async {
    final response = await _satuanService.getSatuan();

    if (response['status'] == true) {
      setState(() {
        satuanList = response['data'];
        filteredSatuanList = satuanList;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
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
          surfaceTintColor: white,
          scrolledUnderElevation: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Pengaturan Lainnya',
              greeting: 'Manajemen Satuan'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-satuan',
                extra: AddSatuanScreen(
                  isUpdate: false,
                  id: '',
                  nama: '',
                  lambang: '',
                  onSatuanAdded: _fetchSatuan,
                ));
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchField(
                controller: searchController,
                onChanged: _searchSatuan,
              ),
              const SizedBox(height: 12),
              Text('Daftar Satuan', style: bold18.copyWith(color: dark1)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSatuanList.length,
                  itemBuilder: (context, index) {
                    final satuan = filteredSatuanList[index];
                    return UnitItem(
                      unitName: satuan['nama']!,
                      unitSymbol: satuan['lambang']!,
                      onEdit: () {
                        context.push('/tambah-satuan',
                            extra: AddSatuanScreen(
                              isUpdate: true,
                              id: satuan['id']!,
                              nama: satuan['nama']!,
                              lambang: satuan['lambang']!,
                              onSatuanAdded: _fetchSatuan,
                            ));
                      },
                      onDelete: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: const Text(
                                    'Apakah Anda yakin ingin menghapus satuan ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final response = await _satuanService
                                          .deleteSatuan(satuan['id']!);
                                      if (response['status'] == true) {
                                        _fetchSatuan();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(response['message']),
                                        ));
                                      }
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              );
                            });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
