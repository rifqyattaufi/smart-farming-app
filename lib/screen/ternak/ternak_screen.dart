import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class TernakScreen extends StatefulWidget {
  const TernakScreen({super.key});

  @override
  State<TernakScreen> createState() => _TernakScreenState();
}

class _TernakScreenState extends State<TernakScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();

  List<dynamic> _ternakList = [];
  List<dynamic> _filteredTernakList = [];

  TextEditingController searchController = TextEditingController();

  Future<void> _fetchData() async {
    try {
      final response =
          await _jenisBudidayaService.getJenisBudidayaByTipe('hewan');
      setState(() {
        _ternakList = response['data'];
        _filteredTernakList = _ternakList;
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

  void _searchTernak(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredTernakList = _ternakList;
      });
    } else {
      final response =
          await _jenisBudidayaService.getJenisBudidayaSearch(query, 'hewan');

      if (response['status']) {
        setState(() {
          _filteredTernakList = response['data'];
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
            title: 'Manajemen Ternak',
            greeting: 'Daftar Ternak',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-ternak',
                extra: AddTernakScreen(
                    isEdit: false, onTernakAdded: () => _fetchData()));
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
                        onChanged: _searchTernak,
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Jenis Ternak',
                  items: _filteredTernakList
                      .map((ternak) => {
                            'name': ternak['nama'],
                            'icon': ternak['gambar'],
                            'id': ternak['id'],
                            'isActive': ternak['status'],
                          })
                      .toList(),
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
