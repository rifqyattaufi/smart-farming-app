import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/users/detail_user_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/newest.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService _authService = AuthService();
  bool? _userOAuthStatus; // To store the fetched OAuth status

  @override
  void initState() {
    super.initState();
    _fetchUserOAuthStatus();
  }

  Future<void> _fetchUserOAuthStatus() async {
    try {
      final user = await _authService.getUser();
      if (mounted) {
        setState(() {
          _userOAuthStatus = user?['oAuthStatus'] ?? false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userOAuthStatus = false;
        });
      }
      print("Error fetching user OAuth status: $e");
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar Akun'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await _authService.logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> primarySettingsReports = [
      {
        'text': 'Data Akun',
        'onTap': () =>
            context.push('/detail-pengguna', extra: const DetailUserScreen()),
      },
      {
        'text': 'Ubah Password',
        'onTap': () => context.push('/lupa-password'),
      },
    ];

    if (_userOAuthStatus == false) {
      primarySettingsReports.add({
        'text': 'Link to Google',
        'onTap': () {
          print('Link to Google tapped');
        },
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 0,
              titleSpacing: 0,
              toolbarHeight: 80,
              title: const Header(headerType: HeaderType.basic)),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            NewestReports(
              title: 'Pengaturan Utama',
              reports: primarySettingsReports, // Use the dynamically built list
              onItemTap: (context, report) {
                // This general onItemTap might conflict if items have specific onTaps
                // that aren't handled by the NewestReports widget itself.
                // For now, assuming NewestReports handles item-specific onTaps.
                // If not, this line might need adjustment or removal.
                if (report['onTap'] == null) {
                  // Example: only navigate if item has no specific onTap
                  context.push('/detail', extra: report);
                }
              },
              mode: NewestReportsMode.simple,
              showIcon: false,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium14.copyWith(color: dark1),
            ),
            const SizedBox(height: 12),
            NewestReports(
              title: 'Pengaturan Lainnya',
              reports: [
                {
                  'text': 'Manajemen Notifikasi Global',
                  'onTap': () => context.push('/manajemen-notifikasi'),
                },
                {
                  'text': 'Manajemen Pengguna',
                  'onTap': () => context.push('/manajemen-pengguna'),
                },
                {
                  'text': 'Manajemen Satuan',
                  'onTap': () => context.push('/manajemen-satuan'),
                },
                {
                  'text': 'Manajemen Grade Hasil Panen',
                  'onTap': () => context.push('/manajemen-grade'),
                },
                {
                  'text': 'Log Aktivitas',
                  'onTap': () => context.push('/log-aktivitas'),
                },
                {
                  'text': 'Kebijakan Privasi',
                  'onTap': () => context.push('/kebijakan-privasi'),
                },
                {
                  'text': 'Bantuan',
                  'onTap': () => context.push('/detail'),
                }
              ],
              onItemTap: (context, item) {
                // This onItemTap seems to expect 'name' in the item,
                // ensure items passed to this NewestReports instance have it if needed.
                // Or, rely on individual 'onTap' handlers within each report item.
                // final name = item['name'] ?? '';
                // context.push('/detail-laporan/$name');
              },
              mode: NewestReportsMode.simple,
              showIcon: false,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium14.copyWith(color: dark1),
            ),
            const SizedBox(height: 12),
            NewestReports(
              title: 'Keluar',
              reports: [
                {'text': 'Keluar Akun', 'onTap': _showLogoutConfirmation},
              ],
              onItemTap: (context, item) {
                // Similar to above, ensure this logic is intended or rely on item's onTap.
                // final name = item['name'] ?? '';
                // context.push('/detail-laporan/$name');
              },
              mode: NewestReportsMode.simple,
              showIcon: false,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium14.copyWith(color: dark1),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
