import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/custom_tab.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class KomoditasScreen extends StatefulWidget {
  const KomoditasScreen({super.key});

  @override
  State<KomoditasScreen> createState() => _KomoditasScreenState();
}

class _KomoditasScreenState extends State<KomoditasScreen> {
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
            title: 'Manajemen Komoditas',
            greeting: 'Daftar Komoditas',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            if (selectedTab == 0) {
              context.push('/tambah-komoditas-tanaman');
            } else {
              context.push('/tambah-komoditas-ternak');
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
                  tabs: const ['Perkebunan', 'Peternakan'],
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
    return selectedTab == 0
        ? _buildPerkebunanContent()
        : _buildPeternakanContent();
  }

  Widget _buildPerkebunanContent() {
    return Column(
      children: [
        ListItem(
          title: 'Daftar Komoditas',
          items: const [
            {
              'name': 'Buah Melon',
              'category': 'Melon',
              'icon': 'assets/icons/goclub.svg',
            },
            {
              'name': 'Buah Anggur',
              'category': 'Anggur',
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

  Widget _buildPeternakanContent() {
    return Column(
      children: [
        ListItem(
          title: 'Daftar Komoditas',
          items: const [
            {
              'name': 'Telur',
              'category': 'Ayam',
              'icon': 'assets/icons/goclub.svg',
            },
            {
              'name': 'Daging',
              'category': 'Ayam',
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
}
