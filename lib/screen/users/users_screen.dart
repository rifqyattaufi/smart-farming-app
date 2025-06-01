import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/users/add_user_screen.dart';
import 'package:smart_farming_app/screen/users/detail_user_screen.dart';
import 'package:smart_farming_app/service/user_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/newest.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserService _userService = UserService();
  final List<Map<String, dynamic>> pjawab = [];
  final List<Map<String, dynamic>> petugas = [];
  final List<Map<String, dynamic>> inventor = [];

  Future<void> _fetchData() async {
    try {
      final response = await _userService.getUserGroupByRole();
      if (response['status']) {
        setState(() {
          pjawab.clear();
          petugas.clear();
          inventor.clear();

          pjawab.addAll(List<Map<String, dynamic>>.from(
              response['data']['pjawab'] ?? []));
          petugas.addAll(List<Map<String, dynamic>>.from(
              response['data']['petugas'] ?? []));
          inventor.addAll(List<Map<String, dynamic>>.from(
              response['data']['inventor'] ?? []));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching user data: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching user data: $e'),
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
              title: 'Pengaturan Lainnya',
              greeting: 'Manajemen Pengguna',
            ),
          ),
        ),
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () {
              context
                  .push('/tambah-pengguna', extra: const AddUserScreen())
                  .then((_) {
                _fetchData();
              });
            },
            backgroundColor: green1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            color: green1,
            backgroundColor: white,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
                NewestReports(
                  title: 'Penanggung Jawab RFC',
                  reports: pjawab
                      .map((user) => {
                            'text': user['name'] ?? '-',
                            'subtext': user['email'] ?? '-',
                            'icon':
                                user['avatarUrl'] ?? 'assets/icons/goclub.svg',
                            'isActive': user['isActive'] ?? false,
                            'id': user['id'],
                          })
                      .toList(),
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context
                        .push('/detail-pengguna',
                            extra: DetailUserScreen(
                              id: id,
                            ))
                        .then((_) {
                      _fetchData();
                    });
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
                const SizedBox(height: 12),
                NewestReports(
                  title: 'Petugas Pelaporan',
                  reports: petugas
                      .map((user) => {
                            'text': user['name'] ?? '-',
                            'subtext': user['email'] ?? '-',
                            'icon':
                                user['avatarUrl'] ?? 'assets/icons/goclub.svg',
                            'isActive': user['isActive'] ?? false,
                            'id': user['id'],
                          })
                      .toList(),
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context
                        .push('/detail-pengguna',
                            extra: DetailUserScreen(
                              id: id,
                            ))
                        .then((_) {
                      _fetchData();
                    });
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
                const SizedBox(height: 12),
                NewestReports(
                  title: 'Inventor RFC',
                  reports: inventor
                      .map((user) => {
                            'text': user['name'] ?? '-',
                            'subtext': user['email'] ?? '-',
                            'icon':
                                user['avatarUrl'] ?? 'assets/icons/goclub.svg',
                            'isActive': user['isActive'] ?? false,
                            'id': user['id'],
                          })
                      .toList(),
                  onItemTap: (context, item) {
                    final id = item['id'] ?? '';
                    context
                        .push('/detail-pengguna',
                            extra: DetailUserScreen(
                              id: id,
                            ))
                        .then((_) {
                      _fetchData();
                    });
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
              ],
            ),
          ),
        ));
  }
}
