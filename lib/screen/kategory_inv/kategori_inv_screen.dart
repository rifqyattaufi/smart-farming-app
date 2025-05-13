import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/kategory_inv/add_kategori_inv_screen.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

class KategoriInvScreen extends StatefulWidget {
  const KategoriInvScreen({super.key});

  @override
  State<KategoriInvScreen> createState() => _KategoriInvScreenState();
}

class _KategoriInvScreenState extends State<KategoriInvScreen> {
  final KategoriInvService _kategoriInvService = KategoriInvService();
  List<dynamic> kategoriInvList = [];
  List<dynamic> filteredKategoriInvList = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKategoriInv();
  }

  void _searchKategoriInv(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredKategoriInvList = kategoriInvList;
      });
    } else {
      final response =
          await _kategoriInvService.getKategoriInventarisSearch(query);

      if (response['status'] == true) {
        setState(() {
          filteredKategoriInvList = response['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  Future<void> _fetchKategoriInv() async {
    final response = await _kategoriInvService.getKategoriInventaris();

    if (response['status'] == true) {
      setState(() {
        kategoriInvList = response['data'];
        filteredKategoriInvList = kategoriInvList;
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
              title: 'Manajemen Inventaris',
              greeting: 'Daftar Kategori Inventaris'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push(
              '/tambah-kategori-inventaris',
              extra: AddKategoriInvScreen(
                isUpdate: false,
                id: '',
                nama: '',
                onKategoriInvAdded: _fetchKategoriInv,
              )
            );
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
                onChanged: _searchKategoriInv,
              ),
              const SizedBox(height: 12),
              Text('Daftar Kategori', style: bold18.copyWith(color: dark1)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredKategoriInvList.length,
                  itemBuilder: (context, index) {
                    final kategoriInv = filteredKategoriInvList[index];
                    return UnitItem(
                      unitName: kategoriInv['nama']!,
                      onEdit: () {
                        context.push(
                          '/tambah-kategori-inventaris',
                          extra: AddKategoriInvScreen(
                            isUpdate: true,
                            id: kategoriInv['id']!,
                            nama: kategoriInv['nama']!,
                            onKategoriInvAdded: _fetchKategoriInv,
                          )
                        );
                      },
                      onDelete: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Konfirmasi Hapus'),
                                content: const Text(
                                    'Apakah Anda yakin ingin menghapus kategori ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final response = await _kategoriInvService
                                          .deleteKategoriInventaris(
                                              kategoriInv['id']!);
                                      if (response['status'] == true) {
                                        _fetchKategoriInv();
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
