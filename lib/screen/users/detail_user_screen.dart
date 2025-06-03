import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/users/add_user_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/user_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class DetailUserScreen extends StatefulWidget {
  final String? id;

  const DetailUserScreen({super.key, this.id});

  @override
  State<DetailUserScreen> createState() => _DetailUserScreenState();
}

class _DetailUserScreenState extends State<DetailUserScreen> {
  Map<String, dynamic>? userData;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = true;

  final roleUser = {
    "pjawab": "Penanggung Jawab",
    "petugas": "Petugas",
    "inventor": "Inventor"
  };

  Future<void> _fetchData() async {
    if (widget.id != null) {
      try {
        final response = await _userService.getUserById(widget.id!);
        if (response['status']) {
          setState(() {
            userData = response['data'];
          });

          final loggedInUser = await _authService.getUser();
          if (loggedInUser?['id'] == userData!['id']) {
            context.replace('/detail-pengguna',
                extra: const DetailUserScreen());
          }
        } else {
          showAppToast(context, response['message'] ?? 'Gagal memuat data');
        }
      } catch (e) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      try {
        final response = await _authService.getUser();
        if (response!.isNotEmpty) {
          final responseUser = await _userService.getUserById(response['id']);
          if (responseUser['status']) {
            setState(() {
              userData = responseUser['data'];
            });
          } else {
            showAppToast(context, response['message'] ?? 'Gagal memuat data');
          }
        }
      } catch (e) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> deactivateUser() async {
    try {
      final response = await _userService.deactivateUser(userData!['id']);
      if (response['status']) {
        showAppToast(context, 'Pengguna berhasil dinonaktifkan',
            isError: false);
        Navigator.pop(context);
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal menonaktifkan pengguna');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _activateUser() async {
    try {
      final response = await _userService.activateUser(userData!['id']);
      if (response['status']) {
        showAppToast(context, 'Pengguna berhasil diaktifkan', isError: false);
        Navigator.pop(context);
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal mengaktifkan pengguna');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  @override
  void initState() {
    _fetchData();
    super.initState();
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
            title: 'Manajemen Pengguna',
            greeting: 'Detail Pengguna',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  child: ClipOval(
                                    child: ImageBuilder(
                                      url: userData?['avatarUrl'] ??
                                          'https://via.placeholder.com/100',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            infoItem("Nama pengguna", userData?['name'] ?? "-"),
                            infoItem("Nama role",
                                roleUser[userData?['role']] ?? "-"),
                            infoItem(
                                "Email pengguna", userData?['email'] ?? "-"),
                            infoItem(
                                "Nomor telepon", userData?['phone'] ?? "-"),
                            infoItem(
                                "Tanggal didaftarkan",
                                DateFormat('EEEE, dd MMMM yyyy HH:mm').format(
                                    userData?['createdAt'] != null
                                        ? DateTime.parse(userData!['createdAt'])
                                        : DateTime.now())),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.id != null) ...[
                    if (userData?['isActive'])
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: deactivateUser,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          label: Text(
                            'Deaktivasi Pengguna',
                            style: semibold16.copyWith(color: red),
                          ),
                        ),
                      ),
                    if (!userData!['isActive'])
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _activateUser,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: green1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          label: Text(
                            'Aktifkan Pengguna',
                            style: semibold16.copyWith(color: green1),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: () {
                      context
                          .push('/tambah-pengguna',
                              extra: AddUserScreen(
                                id: widget.id,
                                isEdit: true,
                              ))
                          .then((_) {
                        _fetchData();
                      });
                    },
                    buttonText: 'Ubah Data',
                    backgroundColor: yellow2,
                    textStyle: semibold16,
                    textColor: white,
                  ),
                ],
              ),
            ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }
}
