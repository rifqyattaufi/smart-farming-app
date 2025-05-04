import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class KandangScreen extends StatefulWidget {
  const KandangScreen({super.key});

  @override
  State<KandangScreen> createState() => _KandangScreenState();
}

class _KandangScreenState extends State<KandangScreen> {
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();

  List<dynamic> _kandangList = [];
  List<dynamic> _filteredKandangList = [];

  TextEditingController searchController = TextEditingController();

  Future<void> _fetchData() async {
    try {
      final response =
          await _unitBudidayaService.getUnitBudidayaByTipe('hewan');
      setState(() {
        _kandangList = response['data'];
        _filteredKandangList = _kandangList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _searchKandang(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredKandangList = _kandangList;
      });
    } else {
      final response =
          await _unitBudidayaService.getUnitBudidayaSearch(query, 'hewan');

      if (response['status']) {
        setState(() {
          _filteredKandangList = response['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching data: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            title: 'Manajemen Kandang',
            greeting: 'Daftar Kandang',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-kandang',
                extra: AddKandangScreen(
                  isEdit: false,
                  onKandangAdded: () => _fetchData(),
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
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchField(
                        controller: searchController,
                        onChanged: _searchKandang,
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Kandang',
                  items: _filteredKandangList
                      .map((kandang) => {
                            'name': kandang['nama'],
                            'category': kandang['JenisBudidaya']['nama'],
                            'icon': kandang['gambar'],
                            'id': kandang['id'],
                          })
                      .toList(),
                  type: 'basic',
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context.push('/detail-laporan/$id');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
