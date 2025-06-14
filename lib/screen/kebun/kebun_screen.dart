import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class KebunScreen extends StatefulWidget {
  const KebunScreen({super.key});

  @override
  State<KebunScreen> createState() => _KebunScreenState();
}

class _KebunScreenState extends State<KebunScreen> {
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final AuthService _authService = AuthService();

  List<dynamic> _kebunList = [];
  List<dynamic> _filteredKebunList = [];
  String? _userRole;

  TextEditingController searchController = TextEditingController();
  Future<void> _fetchData() async {
    try {
      final role = await _authService.getUserRole();
      final response =
          await _unitBudidayaService.getUnitBudidayaByTipe('tumbuhan');
      setState(() {
        _userRole = role;
        _kebunList = response['data'] ?? [];
        _filteredKebunList = _kebunList;
      });
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  void _searchKebun(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredKebunList = _kebunList;
      });
    } else {
      final response =
          await _unitBudidayaService.getUnitBudidayaSearch(query, 'tumbuhan');

      if (response['status']) {
        setState(() {
          _filteredKebunList = response['data'] ?? [];
        });
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
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
            title: 'Manajemen Kebun',
            greeting: 'Daftar Kebun',
          ),
        ),
      ),
      floatingActionButton: _userRole == 'pjawab'
          ? SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () {
                  context.push('/tambah-kebun',
                      extra: AddKebunScreen(
                        isEdit: false,
                        onKebunAdded: () => _fetchData(),
                      ));
                },
                backgroundColor: green1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            )
          : null,
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
                        onChanged: _searchKebun,
                      ),
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Kebun',
                  items: _filteredKebunList
                      .map((kebun) => {
                            'id': kebun['id'],
                            'name': kebun['nama'],
                            'category': kebun['JenisBudidaya']['nama'],
                            'icon': kebun['gambar'],
                          })
                      .toList(),
                  type: 'basic',
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context.push('/detail-kebun/$id').then((_) {
                      _fetchData();
                    });
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
