import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            context.push('/tambah-pengguna');
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
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
                NewestReports(
                  title: 'Penanggung Jawab RFC',
                  reports: const [
                    {
                      'text': 'Pak Dimas',
                      'subtext': 'dimas@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Pak Dwi',
                      'subtext': 'dwi@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    }
                  ],
                  onItemTap: (context, item) {
                    final name = item['text'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
                const SizedBox(height: 12),
                NewestReports(
                  title: 'Petugas Pelaporan',
                  reports: const [
                    {
                      'text': 'Pak Adi',
                      'subtext': 'adi@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Pak Ebi',
                      'subtext': 'ebi@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    }
                  ],
                  onItemTap: (context, item) {
                    final name = item['text'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
                const SizedBox(height: 12),
                NewestReports(
                  title: 'Inventor RFC',
                  reports: const [
                    {
                      'text': 'Ryan',
                      'subtext': 'ryan@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Rifqy',
                      'subtext': 'rifqy@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    },
                    {
                      'text': 'Abriel',
                      'subtext': 'abriel@mail.com',
                      'icon': 'assets/icons/goclub.svg',
                    },
                  ],
                  onItemTap: (context, item) {
                    final name = item['text'] ?? '';
                    context.push('/detail-laporan/$name');
                  },
                  mode: NewestReportsMode.full,
                  titleTextStyle: bold18.copyWith(color: dark1),
                  reportTextStyle: medium12.copyWith(color: dark1),
                  timeTextStyle: regular12.copyWith(color: dark2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
