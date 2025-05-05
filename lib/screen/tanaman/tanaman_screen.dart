import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class TanamanScreen extends StatefulWidget {
  const TanamanScreen({super.key});

  @override
  State<TanamanScreen> createState() => _TanamanScreenState();
}

class _TanamanScreenState extends State<TanamanScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();

  List<dynamic> _tanamanList = [];
  List<dynamic> _filteredTanamanList = [];

  TextEditingController searchController = TextEditingController();

  Future<void> _fetchData() async {
    try {
      final response =
          await _jenisBudidayaService.getJenisBudidayaByTipe('tumbuhan');
      setState(() {
        _tanamanList = response['data'];
        _filteredTanamanList = _tanamanList;
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

  void _searchTanaman(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredTanamanList = _tanamanList;
      });
    } else {
      final response =
          await _jenisBudidayaService.getJenisBudidayaSearch(query, 'tumbuhan');

      if (response['status']) {
        setState(() {
          _filteredTanamanList = response['data'];
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
            title: 'Manajemen Jenis Tanaman',
            greeting: 'Daftar Jenis Tanaman',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-tanaman',
                extra: AddTanamanScreen(
                  isEdit: false,
                  onTanamanAdded: () => _fetchData(),
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
                        onChanged: _searchTanaman,
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Jenis Tanaman',
                  items: _filteredTanamanList.map((item) {
                    return {
                      'name': item['nama'],
                      'icon': item['gambar'],
                      'id': item['id'],
                      'isActive': item['status'],
                    };
                  }).toList(),
                  type: 'basic',
                  onItemTap: (context, item) {
                    final name = item['name'] ?? '';
                    context.push('/detail-laporan/$name');
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
