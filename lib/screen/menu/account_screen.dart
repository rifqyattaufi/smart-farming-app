import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/section_item.dart';
import 'package:smart_farming_app/widget/section_title.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: green1,
        elevation: 0,
        toolbarHeight: 100,
        title: const Header(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SectionTitle(title: "Akun"),
          SectionItem(
              title: "Data Akun", icon: Icons.account_circle, onTap: () {}),
          SectionItem(
              title: "Riwayat Aktivitas",
              icon: Icons.insert_drive_file,
              onTap: () {}),
          const SectionTitle(title: "Informasi"),
          SectionItem(
              title: "Kebijakan Privasi",
              icon: Icons.request_page,
              tag: "Baru",
              onTap: () {}),
          SectionItem(
              title: "Bantuan",
              icon: Icons.help_center,
              tag: "Baru",
              onTap: () {}),
          const SectionTitle(title: "Pengaturan Lainnya"),
          SectionItem(
              title: "Notifikasi", icon: Icons.notifications, onTap: () {}),
          SectionItem(
              title: "Keluar",
              icon: Icons.logout,
              onTap: () {},
              iconColor: Colors.red,
              titleColor: Colors.red),
        ],
      ),
    );
  }
}
