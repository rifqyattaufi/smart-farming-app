import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
              reports: [
                {
                  'text': 'Data Akun',
                  'onTap': () => context.push('/detail'),
                },
                {
                  'text': 'Ubah Password',
                  'onTap': () => context.push('/lupa-password'),
                },
              ],
              onItemTap: (context, report) =>
                  context.push('/detail', extra: report),
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
                  'text': 'Manajemen Notifikasi Global',
                  'onTap': () => context.push('/manajemen-notifikasi'),
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
                final name = item['name'] ?? '';
                context.push('/detail-laporan/$name');
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
                final name = item['name'] ?? '';
                context.push('/detail-laporan/$name');
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
