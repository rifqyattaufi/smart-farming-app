import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
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
  final KomoditasService _komoditasService = KomoditasService();

  List<dynamic> allInventarisList = [];
  List<dynamic> allInventarisListFiltered = [];
  List<dynamic> allKomoditasList = [];
  List<dynamic> allKomoditasListFiltered = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final inventarisResponse = await _inventarisService.getInventaris();
    final komoditasResponse = await _komoditasService.getKomoditas();

    if (mounted) {
      setState(() {
        allInventarisList =
            List<dynamic>.from(inventarisResponse['data'] ?? []);
        allInventarisListFiltered = List.from(allInventarisList);
        allKomoditasList = List<dynamic>.from(komoditasResponse['data'] ?? []);
        allKomoditasListFiltered  = List.from(allKomoditasList);
      });
    }
  }

  void _searchData(String query) async {
    final String normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) {
      setState(() {
        allInventarisListFiltered = List.from(allInventarisList);
        allKomoditasListFiltered = List.from(allKomoditasList);
      });
      return;
    }

    if (selectedTab == 0) {
      // Filter inventaris
      setState(() {
        allInventarisListFiltered = allInventarisList.where((item) {
          final nama = (item['nama'] ?? '').toString().toLowerCase();
          return nama.contains(normalizedQuery);
        }).toList();
      });
    } else {
      // Filter hasil panen (komoditas)
      setState(() {
        allKomoditasListFiltered = allKomoditasList.where((item) {
          final nama = (item['nama'] ?? '').toString().toLowerCase();
          return nama.contains(normalizedQuery);
        }).toList();
      });
    }
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
                onInventarisAdded: _fetchData,
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
                      controller: searchController, onChanged: _searchData),
                ),
                const SizedBox(height: 20),
                CustomTabBar(
                  tabs: const ['Inventaris', 'Hasil Panen'],
                  activeColor: green1,
                  activeIndex: selectedTab,
                  onTabSelected: (index) {
                    setState(() {
                      selectedTab = index;
                      searchController.clear();
                      _searchData('');
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

  // ...existing code...
  Widget _buildInventarisContent() {
    if (allInventarisListFiltered.isEmpty && searchController.text.isNotEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Tidak ada data inventaris yang ditemukan."),
      ));
    }
    if (allInventarisList.isEmpty && searchController.text.isEmpty) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Tidak ada data inventaris yang tersedia."),
      ));
    }

    final now = DateTime.now();
    final itemBaru = allInventarisListFiltered.where((inventaris) {
      if (inventaris['createdAt'] == null) return false;
      final createdAt = DateTime.tryParse(
        inventaris['createdAt'].replaceFirst(' ', 'T'),
      );
      if (createdAt == null) return false;
      return now.difference(createdAt).inDays <= 7;
    }).toList();

    final stokRendah = allInventarisListFiltered.where((inventaris) {
      final jumlah = inventaris['jumlah'] ?? 0;
      final stokMinim = inventaris['stokMinim'] ?? 0;
      return jumlah > 0 && jumlah < stokMinim;
    }).toList();

    final stokHabis = allInventarisListFiltered.where((inventaris) {
      final jumlah = inventaris['jumlah'] ?? 0;
      return jumlah == 0;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (itemBaru.isNotEmpty)
          ListItem(
            title: 'Item Baru',
            type: 'history',
            items: itemBaru
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category': 'Stok: ${inventaris['jumlah'] ?? 0}',
                      'icon': inventaris['gambar'],
                      'id': inventaris['id'],
                    })
                .toList(),
            onItemTap: (context, item) {
              final id = item['id'];
              if (id != null) {
                context.push('/detail-laporan/$id');
              }
            },
          ),
        if (stokHabis.isNotEmpty) const SizedBox(height: 12),
        if (stokHabis.isNotEmpty)
          ListItem(
            title: 'Stok Habis',
            type: 'history',
            items: stokHabis
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category': 'Stok: 0',
                      'icon': inventaris['gambar'],
                      'id': inventaris['id'],
                    })
                .toList(),
            onItemTap: (context, item) {
              final id = item['id'];
              if (id != null) {
                context.push('/detail-laporan/$id');
              }
            },
          ),
        if (stokRendah.isNotEmpty) const SizedBox(height: 12),
        if (stokRendah.isNotEmpty)
          ListItem(
            title: 'Stok Rendah',
            type: 'history',
            items: stokRendah
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category': 'Stok: ${inventaris['jumlah'] ?? 0}',
                      'icon': inventaris['gambar'],
                      'id': inventaris['id'],
                    })
                .toList(),
            onItemTap: (context, item) {
              final id = item['id'];
              if (id != null) {
                context.push('/detail-laporan/$id');
              }
            },
          ),
        const SizedBox(height: 12),
        ListItem(
          title: 'Semua Inventaris',
          items: allInventarisListFiltered
              .map((inventaris) => {
                    'name': inventaris['nama'] ?? 'N/A',
                    'category': 'Stok: ${inventaris['jumlah'] ?? 0}',
                    'icon': inventaris['gambar'],
                    'id': inventaris['id'],
                  })
              .toList(),
          type: 'basic',
          onItemTap: (context, item) {
            final id = item['id'];
            if (id != null) {
              context.push('/detail-laporan/$id');
            } else {
              final name = item['name'] ?? '';
              context.push('/detail-laporan/$name');
            }
          },
        ),
      ],
    );
  }
  // ...existing code...
  // final filteredItems = items.where((item) {
  //   bool matchCategory = selectedInventarisCategory == 'Semua Item' ||
  //       item['category'] == selectedInventarisCategory;
  //   bool matchSearch = item['name']!
  //       .toLowerCase()
  //       .contains(searchController.text.toLowerCase());
  //   return matchCategory && matchSearch;
  // }).toList();

  // ChipFilter(
  //   categories: const [
  //     'Semua Item',
  //     'Bibit Tanaman',
  //     'Peralatan',
  //     'Nutrisi'
  //   ],
  //   selectedCategory: selectedInventarisCategory,
  //   onCategorySelected: (category) {
  //     setState(() {
  //       selectedInventarisCategory = category;
  //     });
  //   },
  // ),
  //     const SizedBox(height: 12),
  //     filteredItems.isEmpty
  //         ? Center(
  //             child: Padding(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               children: [
  //                 SvgPicture.asset(
  //                   'assets/images/nodata.svg',
  //                   height: 300,
  //                 ),
  //                 Text('Oops, Data Kosong!',
  //                     style: bold20.copyWith(color: grey)),
  //               ],
  //             ),
  //           ))
  //         : Column(
  //             children: [
  //               ListItem(
  //                 title: 'Item Baru',
  //                 type: 'history',
  //                 items: filteredItems,
  //                 onItemTap: (context, item) {
  //                   final name = item['name'] ?? '';
  //                   context.push('/detail-laporan/$name');
  //                 },
  //               ),
  //               const SizedBox(height: 12),
  //               ListItem(
  //                 title: 'Stok Habis',
  //                 type: 'history',
  //                 items: filteredItems,
  //                 onItemTap: (context, item) {
  //                   final name = item['name'] ?? '';
  //                   context.push('/detail-laporan/$name');
  //                 },
  //               ),
  //               const SizedBox(height: 12),
  //               ListItem(
  //                 title: 'Stok Rendah',
  //                 type: 'history',
  //                 items: filteredItems,
  //                 onItemTap: (context, item) {
  //                   final name = item['name'] ?? '';
  //                   context.push('/detail-laporan/$name');
  //                 },
  //               ),
  //               const SizedBox(height: 12),
  //               ListItem(
  //                 title: 'Semua Item',
  //                 type: 'history',
  //                 items: filteredItems,
  //                 onItemTap: (context, item) {
  //                   final name = item['name'] ?? '';
  //                   context.push('/detail-laporan/$name');
  //                 },
  //               ),
  //             ],
  //           ),
  //   ],
  // );
}

Widget _buildHarvestContent() {
  return const Center(
      child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Text("Tidak ada data inventaris yang ditemukan."),
  ));
  // if (allKomoditasListFiltered.isEmpty && searchController.text.isNotEmpty) {
  //   return const Center(
  //       child: Padding(
  //     padding: EdgeInsets.all(16.0),
  //     child: Text("Tidak ada data inventaris yang ditemukan."),
  //   ));
  // }
  // if (allInventarisList.isEmpty && searchController.text.isEmpty) {
  //   return const Center(
  //       child: Padding(
  //     padding: EdgeInsets.all(16.0),
  //     child: Text("Tidak ada data inventaris yang tersedia."),
  //   ));
  // }
  // return ListItem(
  //   title: 'Semua Inventaris',
  //   items: allKomoditasListFiltered
  //       .map((inventaris) => {
  //             'name': inventaris['nama'] ?? 'N/A',
  //             'category': 'Stok: ${inventaris['jumlah'] ?? 0}',
  //             'icon': inventaris['gambar'],
  //             'id': inventaris['id'],
  //           })
  //       .toList(),
  //   type: 'basic',
  //   onItemTap: (context, item) {
  //     final id = item['id'];
  //     if (id != null) {
  //       context.push('/detail-laporan/$id');
  //     } else {
  //       final name = item['name'] ?? '';
  //       context.push('/detail-laporan/$name');
  //     }
  //   },
  // );
  // final filteredHarvestItems = harvestItems.where((item) {
  //   bool matchCategory = selectedHarvestCategory == 'Semua Hasil Panen' ||
  //       item['category'] == selectedHarvestCategory;
  //   bool matchSearch = item['name']!
  //       .toLowerCase()
  //       .contains(searchController.text.toLowerCase());
  //   return matchCategory && matchSearch;
  // }).toList();

  // return Column(
  //   children: [
  //     ChipFilter(
  //       categories: const ['Semua Hasil Panen', 'Perkebunan', 'Peternakan'],
  //       selectedCategory: selectedHarvestCategory,
  //       onCategorySelected: (category) {
  //         setState(() {
  //           selectedHarvestCategory = category;
  //         });
  //       },
  //     ),
  //     const SizedBox(height: 12),
  //     filteredHarvestItems.isEmpty
  //         ? Center(
  //             child: Padding(
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               children: [
  //                 SvgPicture.asset(
  //                   'assets/images/nodata.svg',
  //                   height: 300,
  //                 ),
  //                 Text('Oops, Data Kosong!',
  //                     style: bold20.copyWith(color: grey)),
  //               ],
  //             ),
  //           ))
  //         : Column(
  //             children: [
  //               if (filteredHarvestItems.any((item) =>
  //                   item['category'] == 'Perkebunan' ||
  //                   item['category'] == 'Semua Hasil Panen'))
  //                 ListItem(
  //                   title: 'Perkebunan',
  //                   type: 'history',
  //                   items: filteredHarvestItems
  //                       .where((item) =>
  //                           item['category'] == 'Perkebunan' ||
  //                           item['category'] == 'Semua Hasil Panen')
  //                       .toList(),
  //                   onItemTap: (context, item) {
  //                     final name = item['name'] ?? '';
  //                     context.push('/detail-laporan/$name');
  //                   },
  //                 ),
  //               const SizedBox(height: 12),
  //               if (filteredHarvestItems.any((item) =>
  //                   item['category'] == 'Peternakan' ||
  //                   item['category'] == 'Semua Hasil Panen'))
  //                 ListItem(
  //                   title: 'Peternakan',
  //                   type: 'history',
  //                   items: filteredHarvestItems
  //                       .where((item) =>
  //                           item['category'] == 'Peternakan' ||
  //                           item['category'] == 'Semua Hasil Panen')
  //                       .toList(),
  //                   onItemTap: (context, item) {
  //                     final name = item['name'] ?? '';
  //                     context.push('/detail-laporan/$name');
  //                   },
  //                 ),
  //             ],
  //           ),
  //   ],
  //   );
}
