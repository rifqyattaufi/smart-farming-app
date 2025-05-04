import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/custom_tab.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class KomoditasScreen extends StatefulWidget {
  const KomoditasScreen({super.key});

  @override
  State<KomoditasScreen> createState() => _KomoditasScreenState();
}

class _KomoditasScreenState extends State<KomoditasScreen> {
  final KomoditasService _komoditasService = KomoditasService();

  List<dynamic> komoditasTernakList = [];
  List<dynamic> komoditasTernakListFiltered = [];
  List<dynamic> komoditasKebunList = [];
  List<dynamic> komoditasKebunListFiltered = [];

  Future<void> _fetchData() async {
    final komoditasTernakResponse =
        await _komoditasService.getKomoditasByTipe('hewan');
    final komoditasKebunResponse =
        await _komoditasService.getKomoditasByTipe('tumbuhan');
    setState(() {
      komoditasTernakList = komoditasTernakResponse['data'];
      komoditasKebunList = komoditasKebunResponse['data'];
      komoditasTernakListFiltered = komoditasTernakList;
      komoditasKebunListFiltered = komoditasKebunList;
    });
  }

  void _searchKomoditas(String query) async {
    if (query.isEmpty) {
      setState(() {
        komoditasTernakListFiltered = komoditasTernakList;
        komoditasKebunListFiltered = komoditasKebunList;
      });
    } else {
      final komoditasTernakResponse =
          await _komoditasService.getKomoditasSearch(query, 'hewan');
      final komoditasKebunResponse =
          await _komoditasService.getKomoditasSearch(query, 'tumbuhan');

      if (komoditasTernakResponse['status']) {
        setState(() {
          komoditasTernakListFiltered = komoditasTernakResponse['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error searching data: ${komoditasTernakResponse['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (komoditasKebunResponse['status']) {
        setState(() {
          komoditasKebunListFiltered = komoditasKebunResponse['data'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error searching data: ${komoditasKebunResponse['message']}'),
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

  int selectedTab = 0;
  TextEditingController searchController = TextEditingController();

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
            title: 'Manajemen Komoditas',
            greeting: 'Daftar Komoditas',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            if (selectedTab == 0) {
              context.push('/tambah-komoditas-tanaman');
            } else {
              context.push('/tambah-komoditas-ternak');
            }
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                      controller: searchController,
                      onChanged: _searchKomoditas),
                ),
                const SizedBox(height: 20),
                CustomTabBar(
                  tabs: const ['Perkebunan', 'Peternakan'],
                  activeColor: green1,
                  underlineWidth: 120,
                  spacing: 100,
                  onTabSelected: (index) {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return selectedTab == 0
        ? _buildPerkebunanContent()
        : _buildPeternakanContent();
  }

  Widget _buildPerkebunanContent() {
    return Column(
      children: [
        ListItem(
          title: 'Daftar Komoditas',
          items: komoditasKebunListFiltered
              .map((komoditas) => {
                    'name': komoditas['nama'],
                    'category': komoditas['JenisBudidaya']['nama'],
                    'icon': komoditas['gambar'],
                    'id': komoditas['id'],
                  })
              .toList(),
          type: 'basic',
          onItemTap: (context, item) {
            final name = item['name'] ?? '';
            context.push('/detail-laporan/$name');
          },
        ),
      ],
    );
  }

  Widget _buildPeternakanContent() {
    return Column(
      children: [
        ListItem(
          title: 'Daftar Komoditas',
          items: komoditasTernakListFiltered
              .map((komoditas) => {
                    'name': komoditas['nama'],
                    'category': komoditas['JenisBudidaya']['nama'],
                    'icon': komoditas['gambar'],
                    'id': komoditas['id'],
                  })
              .toList(),
          type: 'basic',
          onItemTap: (context, item) {
            final name = item['name'] ?? '';
            context.push('/detail-laporan/$name');
          },
        ),
      ],
    );
  }
}
