import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/newest.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(headerType: HeaderType.basic),
      ),
      body: ListView(
        children: [
          NewestReports(
            title: 'Pengaturan Utama',
            reports: [
              {
                'text': 'Data Akun',
                'onTap': () => context.push('/detail'),
              },
              {
                'text': 'Pengingat Harian',
                'onTap': () => context.push('/detail'),
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
                'text': 'Ubah Password',
                'onTap': () => context.push('/detail'),
              },
              {
                'text': 'Log Aktivitas',
                'onTap': () => context.push('/log-aktivitas'),
              },
              {
                'text': 'Kebijakan Privasi',
                'onTap': () => context.push('/detail'),
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
              {
                'text': 'Keluar Akun',
                'onTap': () => context.push('/detail'),
              },
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
        ],
      ),
    );
  }
}
