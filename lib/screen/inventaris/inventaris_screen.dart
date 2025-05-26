import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/chip_filter.dart';
import 'package:smart_farming_app/widget/custom_tab.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  final InventarisService _inventarisService = InventarisService();
  Map<String, dynamic>? _inventarisData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventarisData();
  }

  Future<void> _fetchInventarisData() async {
    try {
      final data = await _inventarisService.getDashboardInventaris();
      setState(() {
        _inventarisData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int selectedTab = 0;
  TextEditingController searchController = TextEditingController();

  String selectedInventarisCategory = 'Semua Item';
  String selectedHarvestCategory = 'Semua Hasil Panen';

  final List<Map<String, String>> items = [
    {
      'name': 'Tanaman A',
      'category': 'Bibit Tanaman',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Tanaman B',
      'category': 'Bibit Tanaman',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Peralatan C',
      'category': 'Peralatan',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Peralatan D',
      'category': 'Peralatan',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Item E',
      'category': 'Semua Item',
      'image': 'assets/images/rooftop.jpg'
    },
  ];

  final List<Map<String, String>> harvestItems = [
    {
      'name': 'Telur Ayam',
      'category': 'Peternakan',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Telur Ayam',
      'category': 'Semua Hasil Panen',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Buah Melon',
      'category': 'Semua Hasil Panen',
      'image': 'assets/images/rooftop.jpg'
    },
    {
      'name': 'Buah Melon',
      'category': 'Perkebunan',
      'image': 'assets/images/rooftop.jpg'
    },
  ];

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
            title: 'Manajemen Inventaris',
            greeting: 'Daftar Inventaris',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push(
              '/tambah-inventaris',
              extra: AddInventarisScreen(
                isEdit: false,
                onInventarisAdded: _fetchInventarisData,
              ),
            );
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
                  tabs: const ['Inventaris', 'Hasil Panen'],
                  activeColor: green1,
                  underlineWidth: 120,
                  spacing: 100,
                  onTabSelected: (index) {
                    setState(() {
                      selectedTab = index;
                      if (selectedTab == 0) {
                        selectedInventarisCategory = 'Semua Item';
                      } else {
                        selectedHarvestCategory = 'Semua Hasil Panen';
                      }
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
        ? _buildInventarisContent()
        : _buildHarvestContent();
  }

  Widget _buildInventarisContent() {
    final filteredItems = items.where((item) {
      bool matchCategory = selectedInventarisCategory == 'Semua Item' ||
          item['category'] == selectedInventarisCategory;
      bool matchSearch = item['name']!
          .toLowerCase()
          .contains(searchController.text.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Column(
      children: [
        ChipFilter(
          categories: const [
            'Semua Item',
            'Bibit Tanaman',
            'Peralatan',
            'Nutrisi'
          ],
          selectedCategory: selectedInventarisCategory,
          onCategorySelected: (category) {
            setState(() {
              selectedInventarisCategory = category;
            });
          },
        ),
        const SizedBox(height: 12),
        filteredItems.isEmpty
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/nodata.svg',
                      height: 300,
                    ),
                    Text('Oops, Data Kosong!',
                        style: bold20.copyWith(color: grey)),
                  ],
                ),
              ))
            : Column(
                children: [
                  ListItem(
                    title: 'Riwayat Pemakaian Terbaru',
                    type: 'history',
                    items: filteredItems,
                    onItemTap: (context, item) {
                      final name = item['name'] ?? '';
                      context.push('/detail-laporan/$name');
                    },
                  ),
                  const SizedBox(height: 12),
                  ListItem(
                    title: 'Semua Riwayat Pemakaian',
                    type: 'history',
                    items: filteredItems,
                    onItemTap: (context, item) {
                      final name = item['name'] ?? '';
                      context.push('/detail-laporan/$name');
                    },
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildHarvestContent() {
    final filteredHarvestItems = harvestItems.where((item) {
      bool matchCategory = selectedHarvestCategory == 'Semua Hasil Panen' ||
          item['category'] == selectedHarvestCategory;
      bool matchSearch = item['name']!
          .toLowerCase()
          .contains(searchController.text.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();

    return Column(
      children: [
        ChipFilter(
          categories: const ['Semua Hasil Panen', 'Perkebunan', 'Peternakan'],
          selectedCategory: selectedHarvestCategory,
          onCategorySelected: (category) {
            setState(() {
              selectedHarvestCategory = category;
            });
          },
        ),
        const SizedBox(height: 12),
        filteredHarvestItems.isEmpty
            ? Center(
                child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/nodata.svg',
                      height: 300,
                    ),
                    Text('Oops, Data Kosong!',
                        style: bold20.copyWith(color: grey)),
                  ],
                ),
              ))
            : Column(
                children: [
                  if (filteredHarvestItems.any((item) =>
                      item['category'] == 'Perkebunan' ||
                      item['category'] == 'Semua Hasil Panen'))
                    ListItem(
                      title: 'Perkebunan',
                      type: 'history',
                      items: filteredHarvestItems
                          .where((item) =>
                              item['category'] == 'Perkebunan' ||
                              item['category'] == 'Semua Hasil Panen')
                          .toList(),
                      onItemTap: (context, item) {
                        final name = item['name'] ?? '';
                        context.push('/detail-laporan/$name');
                      },
                    ),
                  const SizedBox(height: 12),
                  if (filteredHarvestItems.any((item) =>
                      item['category'] == 'Peternakan' ||
                      item['category'] == 'Semua Hasil Panen'))
                    ListItem(
                      title: 'Peternakan',
                      type: 'history',
                      items: filteredHarvestItems
                          .where((item) =>
                              item['category'] == 'Peternakan' ||
                              item['category'] == 'Semua Hasil Panen')
                          .toList(),
                      onItemTap: (context, item) {
                        final name = item['name'] ?? '';
                        context.push('/detail-laporan/$name');
                      },
                    ),
                ],
              ),
      ],
    );
  }
}
