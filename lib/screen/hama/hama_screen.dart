import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/custom_tab.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

class HamaScreen extends StatefulWidget {
  const HamaScreen({super.key});

  @override
  State<HamaScreen> createState() => _HamaScreenState();
}

class _HamaScreenState extends State<HamaScreen> {
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
            title: 'Laporan Hama',
            greeting: 'Riwayat Pelaporan Hama',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            if (selectedTab == 0) {
              context.push('/pelaporan-hama');
            } else {
              context.push('/tambah-hama');
            }
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
                CustomTabBar(
                  tabs: const ['Laporan Hama', 'Daftar Hama'],
                  activeColor: green1,
                  underlineWidth: 120,
                  spacing: 100,
                  onTabSelected: (index) {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildTabContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return selectedTab == 0 ? _buildLaporanHamaContent() : _buildHamaContent();
  }

  Widget _buildLaporanHamaContent() {
    return Column(
      children: [
        ListItem(
          items: const [
            {
              'name': 'Tikus',
              'category': 'Diidentifikasi terdapat 2 ekor',
              'icon': 'assets/icons/goclub.svg',
            },
            {
              'name': 'Ulat Bulu',
              'category': 'Diidentifikasi terdapat 5 ekor',
              'icon': 'assets/icons/goclub.svg',
            }
          ],
          type: 'basic',
          onItemTap: (context, item) {
            final name = item['name'] ?? '';
            context.push('/detail-laporan/$name');
          },
        ),
      ],
    );
  }

  Widget _buildHamaContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          UnitItem(
            unitName: 'Ulat Bulu',
            onEdit: () {
              // handle edit ulat bulu
            },
            onDelete: () {
              // handle delete ulat bulu
            },
          ),
          UnitItem(
            unitName: 'Tikus',
            onEdit: () {
              // handle edit tikus
            },
            onDelete: () {
              // handle delete tikus
            },
          ),
        ],
      ),
    );
  }
}
