import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/hama/add_hama_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/custom_tab.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class HamaScreen extends StatefulWidget {
  const HamaScreen({super.key});

  @override
  State<HamaScreen> createState() => _HamaScreenState();
}

class _HamaScreenState extends State<HamaScreen> {
  final HamaService _hamaService = HamaService();
  final AuthService _authService = AuthService();

  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  String? _userRole;

  bool _isInitialLoading = true;
  bool _isSearching = false;

  // State untuk Tab 0: Laporan Hama
  final List<dynamic> _laporanHamaList = [];
  List<dynamic> _filteredLaporanHamaList = [];
  int _currentPageLaporan = 1;
  bool _isLoadingMoreLaporan = false;
  bool _hasNextPageLaporan = true;
  int _currentSearchPageLaporan = 1;
  bool _isLoadingMoreSearchLaporan = false;
  bool _hasNextSearchPageLaporan = true;

  // State untuk Tab 1: Daftar Hama (JenisHama)
  final List<dynamic> _daftarHamaList = [];
  List<dynamic> _filteredDaftarHamaList = [];
  int _currentPageDaftarHama = 1;
  bool _isLoadingMoreDaftarHama = false;
  bool _hasNextPageDaftarHama = true;
  int _currentSearchPageDaftarHama = 1;
  bool _isLoadingMoreSearchDaftarHama = false;
  bool _hasNextSearchPageDaftarHama = true;

  final int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _loadInitialDataForCurrentTab();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      if (_searchController.text.isEmpty && (_debounce?.isActive ?? false)) {
        _debounce!.cancel();
        _onSearchChanged("");
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialDataForCurrentTab({bool isRefresh = false}) async {
    if (!mounted) return;
    if (!isRefresh) {
      setState(() {
        _isInitialLoading = true;
      });
    }

    final role = await _authService.getUserRole();

    if (_selectedTab == 0) {
      // Laporan Hama
      _currentPageLaporan = 1;
      _hasNextPageLaporan = true;
      if (isRefresh) {
        _laporanHamaList.clear();
        _filteredLaporanHamaList.clear();
      }
      await _fetchLaporanHamaPage(page: 1, isInitialSetupOrRefresh: true);
    } else {
      // Daftar Hama
      _currentPageDaftarHama = 1;
      _hasNextPageDaftarHama = true;
      if (isRefresh) {
        _daftarHamaList.clear();
        _filteredDaftarHamaList.clear();
      }
      await _fetchDaftarHamaPage(page: 1, isInitialSetupOrRefresh: true);
    }

    if (mounted) {
      setState(() {
        _userRole = role;
        _isInitialLoading = false;
      });
      _updateFilteredListForCurrentTab();
    }
  }

  void _updateFilteredListForCurrentTab() {
    if (_searchController.text.isEmpty) {
      if (_selectedTab == 0) {
        _filteredLaporanHamaList = List.from(_laporanHamaList);
      } else {
        _filteredDaftarHamaList = List.from(_daftarHamaList);
      }
    }
  }

  // --- Laporan Hama (Tab 0) ---
  Future<void> _fetchLaporanHamaPage(
      {required int page, bool isInitialSetupOrRefresh = false}) async {
    if (!mounted || (_isLoadingMoreLaporan && !isInitialSetupOrRefresh)) return;
    if (mounted && !isInitialSetupOrRefresh) {
      setState(() {
        _isLoadingMoreLaporan = true;
      });
    }

    Map<String, dynamic> response;
    try {
      response =
          await _hamaService.getLaporanHama(page: page, limit: _pageSize);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMoreLaporan = false;
          if (isInitialSetupOrRefresh) _isInitialLoading = false;
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
      return;
    }

    if (mounted) {
      setState(() {
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        if (isInitialSetupOrRefresh || page == 1) _laporanHamaList.clear();
        _laporanHamaList.addAll(fetchedData);
        _hasNextPageLaporan =
            (response['currentPage'] ?? page) < (response['totalPages'] ?? 0);
        _isLoadingMoreLaporan = false;
        if (isInitialSetupOrRefresh) _isInitialLoading = false;
        if (_searchController.text.isEmpty) {
          _filteredLaporanHamaList = List.from(_laporanHamaList);
        }
      });
    }
  }

  Future<void> _searchLaporanHama(String query,
      {bool isNewSearch = false}) async {
    final String normalizedQuery = query.toLowerCase().trim();
    if (isNewSearch) {
      if (normalizedQuery.isEmpty) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _filteredLaporanHamaList = List.from(_laporanHamaList);
            _currentSearchPageLaporan = 1;
            _hasNextSearchPageLaporan = true;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isSearching = true;
          _filteredLaporanHamaList.clear();
          _currentSearchPageLaporan = 1;
          _hasNextSearchPageLaporan = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingMoreSearchLaporan = true;
        });
      }
    }

    Map<String, dynamic> response;
    try {
      response = await _hamaService.searchLaporanHama(normalizedQuery,
          page: _currentSearchPageLaporan, limit: _pageSize);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isLoadingMoreSearchLaporan = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _isLoadingMoreSearchLaporan = false;
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        _filteredLaporanHamaList.addAll(fetchedData);
        _hasNextSearchPageLaporan =
            (response['currentPage'] ?? _currentSearchPageLaporan) <
                (response['totalPages'] ?? 0);
        if (response['status'] != true && isNewSearch) {
          _filteredLaporanHamaList.clear();
        }
      });
    }
  }

  Future<void> _fetchMoreLaporanHamaSearchResults({required int page}) async {
    if (_searchController.text.isNotEmpty) {
      await _searchLaporanHama(_searchController.text, isNewSearch: false);
    }
  }

  // --- Daftar Hama (Tab 1) ---
  Future<void> _fetchDaftarHamaPage(
      {required int page, bool isInitialSetupOrRefresh = false}) async {
    if (!mounted || (_isLoadingMoreDaftarHama && !isInitialSetupOrRefresh)) {
      return;
    }
    if (mounted && !isInitialSetupOrRefresh) {
      setState(() {
        _isLoadingMoreDaftarHama = true;
      });
    }
    Map<String, dynamic> response;
    try {
      response = await _hamaService.getDaftarHama(page: page, limit: _pageSize);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMoreDaftarHama = false;
          if (isInitialSetupOrRefresh) _isInitialLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        if (isInitialSetupOrRefresh || page == 1) _daftarHamaList.clear();
        _daftarHamaList.addAll(fetchedData);
        _hasNextPageDaftarHama =
            (response['currentPage'] ?? page) < (response['totalPages'] ?? 0);
        _isLoadingMoreDaftarHama = false;
        if (isInitialSetupOrRefresh) _isInitialLoading = false;
        if (_searchController.text.isEmpty) {
          _filteredDaftarHamaList = List.from(_daftarHamaList);
        }
      });
    }
  }

  Future<void> _searchDaftarHama(String query,
      {bool isNewSearch = false}) async {
    final String normalizedQuery = query.toLowerCase().trim();
    if (isNewSearch) {
      if (normalizedQuery.isEmpty) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _filteredDaftarHamaList = List.from(_daftarHamaList);
            _currentSearchPageDaftarHama = 1;
            _hasNextSearchPageDaftarHama = true;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _isSearching = true;
          _filteredDaftarHamaList.clear();
          _currentSearchPageDaftarHama = 1;
          _hasNextSearchPageDaftarHama = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingMoreSearchDaftarHama = true;
        });
      }
    }
    Map<String, dynamic> response;
    try {
      response = await _hamaService.searchDaftarHama(normalizedQuery,
          page: _currentSearchPageDaftarHama, limit: _pageSize);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isLoadingMoreSearchDaftarHama = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _isLoadingMoreSearchDaftarHama = false;
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        _filteredDaftarHamaList.addAll(fetchedData);
        _hasNextSearchPageDaftarHama =
            (response['currentPage'] ?? _currentSearchPageDaftarHama) <
                (response['totalPages'] ?? 0);
        if (response['status'] != true && isNewSearch) {
          _filteredDaftarHamaList.clear();
        }
      });
    }
  }

  Future<void> _fetchMoreDaftarHamaSearchResults({required int page}) async {
    if (_searchController.text.isNotEmpty) {
      await _searchDaftarHama(_searchController.text, isNewSearch: false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isInitialLoading &&
        !_isSearching) {
      if (_searchController.text.isNotEmpty) {
        // Search mode
        if (_selectedTab == 0 &&
            _hasNextSearchPageLaporan &&
            !_isLoadingMoreSearchLaporan) {
          _currentSearchPageLaporan++;
          _fetchMoreLaporanHamaSearchResults(page: _currentSearchPageLaporan);
        } else if (_selectedTab == 1 &&
            _hasNextSearchPageDaftarHama &&
            !_isLoadingMoreSearchDaftarHama) {
          _currentSearchPageDaftarHama++;
          _fetchMoreDaftarHamaSearchResults(page: _currentSearchPageDaftarHama);
        }
      } else {
        // Not in search mode
        if (_selectedTab == 0 &&
            _hasNextPageLaporan &&
            !_isLoadingMoreLaporan) {
          _currentPageLaporan++;
          _fetchLaporanHamaPage(page: _currentPageLaporan);
        } else if (_selectedTab == 1 &&
            _hasNextPageDaftarHama &&
            !_isLoadingMoreDaftarHama) {
          _currentPageDaftarHama++;
          _fetchDaftarHamaPage(page: _currentPageDaftarHama);
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_selectedTab == 0) {
        _searchLaporanHama(query, isNewSearch: true);
      } else {
        _searchDaftarHama(query, isNewSearch: true);
      }
    });
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        _searchController.clear();
      });
    }
    await _loadInitialDataForCurrentTab(isRefresh: true);
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
            title: 'Manajemen Hama Kebun',
            greeting: 'Riwayat dan Daftar Hama',
          ),
        ),
      ),
      floatingActionButton: _userRole == 'pjawab'
          ? SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                key: const Key('add_hama_button'),
                onPressed: () {
                  if (_selectedTab == 0) {
                    context
                        .push('/pelaporan-hama')
                        .then((_) => _handleRefresh());
                  } else {
                    context.push('/tambah-hama',
                        extra: AddHamaScreen(
                          isEdit: false,
                          onHamaAdded: _handleRefresh,
                        ));
                  }
                },
                backgroundColor: green1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchField(
                  key: const Key('search_hama'),
                  controller: _searchController,
                  onChanged: _onSearchChanged),
            ),
            CustomTabBar(
              key: const Key('hama_tabs'),
              tabs: const ['Laporan Hama', 'Daftar Hama'],
              activeColor: green1,
              underlineWidth: MediaQuery.of(context).size.width / 2.5,
              spacing: 20,
              activeIndex: _selectedTab,
              onTabSelected: (index) {
                if (_selectedTab == index && !_isInitialLoading) return;
                setState(() {
                  _selectedTab = index;
                  _searchController.clear();

                  bool needsData =
                      (_selectedTab == 0 && _laporanHamaList.isEmpty) ||
                          (_selectedTab == 1 && _daftarHamaList.isEmpty);
                  if (needsData && !_isInitialLoading) {
                    _loadInitialDataForCurrentTab();
                  } else if (_searchController.text.isEmpty) {
                    _updateFilteredListForCurrentTab();
                  }

                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0.0);
                  }
                });
              },
            ),
            const SizedBox(height: 10),
            if (_isInitialLoading &&
                (_selectedTab == 0
                    ? _filteredLaporanHamaList.isEmpty
                    : _filteredDaftarHamaList.isEmpty) &&
                !_isSearching)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_isSearching &&
                (_selectedTab == 0
                    ? _filteredLaporanHamaList.isEmpty
                    : _filteredDaftarHamaList.isEmpty))
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange))))
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: green1,
                  backgroundColor: white,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTabContent(),
                          _buildPaginationLoadingIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationLoadingIndicator() {
    bool isLoading = (_selectedTab == 0 &&
            (_isLoadingMoreLaporan || _isLoadingMoreSearchLaporan)) ||
        (_selectedTab == 1 &&
            (_isLoadingMoreDaftarHama || _isLoadingMoreSearchDaftarHama));
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTabContent() {
    bool isCurrentlySearching = _searchController.text.isNotEmpty;

    if (_selectedTab == 0) {
      // Laporan Hama
      if (isCurrentlySearching &&
          _filteredLaporanHamaList.isEmpty &&
          !_isSearching &&
          !_isLoadingMoreSearchLaporan) {
        return _emptyContent("Laporan hama tidak ditemukan.");
      }
      if (!isCurrentlySearching &&
          _laporanHamaList.isEmpty &&
          !_isInitialLoading &&
          !_isLoadingMoreLaporan &&
          !_hasNextPageLaporan) {
        return _emptyContent("Tidak ada laporan hama yang tersedia.");
      }
      if (_filteredLaporanHamaList.isEmpty &&
          (_isInitialLoading ||
              _isLoadingMoreLaporan ||
              _isLoadingMoreSearchLaporan ||
              _isSearching)) {
        return const SizedBox(
            height: 200, child: Center(child: Text("Memuat laporan hama...")));
      }
      if (_filteredLaporanHamaList.isEmpty &&
          !isCurrentlySearching &&
          !_isInitialLoading &&
          !_isLoadingMoreLaporan) {
        return _emptyContent("Tidak ada laporan hama.");
      }
      return _buildLaporanHamaContent();
    } else {
      // Daftar Hama
      if (isCurrentlySearching &&
          _filteredDaftarHamaList.isEmpty &&
          !_isSearching &&
          !_isLoadingMoreSearchDaftarHama) {
        return _emptyContent("Jenis hama tidak ditemukan.");
      }
      if (!isCurrentlySearching &&
          _daftarHamaList.isEmpty &&
          !_isInitialLoading &&
          !_isLoadingMoreDaftarHama &&
          !_hasNextPageDaftarHama) {
        return _emptyContent("Tidak ada jenis hama yang tersedia.");
      }
      if (_filteredDaftarHamaList.isEmpty &&
          (_isInitialLoading ||
              _isLoadingMoreDaftarHama ||
              _isLoadingMoreSearchDaftarHama ||
              _isSearching)) {
        return const SizedBox(
            height: 200, child: Center(child: Text("Memuat daftar hama...")));
      }
      if (_filteredDaftarHamaList.isEmpty &&
          !isCurrentlySearching &&
          !_isInitialLoading &&
          !_isLoadingMoreDaftarHama) {
        return _emptyContent("Tidak ada jenis hama.");
      }
      return _buildDaftarHamaContent();
    }
  }

  Widget _emptyContent(String message) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              key: const Key('empty_message'),
              message,
              style: regular14.copyWith(color: dark2),
              textAlign: TextAlign.center,
            )));
  }

  Widget _buildLaporanHamaContent() {
    return ListItem(
      key: const Key('laporan_hama_list'),
      type: 'history',
      personLabel: 'Pelaporan oleh',
      items: _filteredLaporanHamaList.map((laporan) {
        final jenisHama = laporan['Hama']?['JenisHama'];
        final unitBudidaya = laporan['UnitBudidaya'];
        final tgl = laporan['createdAt'] != null
            ? DateFormat('EEEE, dd MMM yyyy')
                .format(DateTime.parse(laporan['createdAt']))
            : 'N/A';
        final waktu = laporan['createdAt'] != null
            ? DateFormat('HH:mm').format(DateTime.parse(laporan['createdAt']))
            : 'N/A';
        final person = laporan['user']?['name'] ?? 'N/A';

        String kategori = "Jenis Hama: ${jenisHama?['nama'] ?? 'N/A'}";
        if (unitBudidaya?['nama'] != null) {
          kategori += "\nLokasi: ${unitBudidaya['nama']}";
        }
        kategori += "\nJumlah: ${laporan['Hama']?['jumlah'] ?? 0}";

        return {
          'name': laporan['judul'] ?? jenisHama?['nama'] ?? 'Laporan Hama',
          'category': kategori,
          'image': laporan['gambar'] ?? 'assets/images/placeholder_hama.png',
          'person': person,
          'date': tgl,
          'time': waktu,
          'id': laporan['id'],
        };
      }).toList(),
      onItemTap: (context, item) {
        final id = item['id'] as String?;
        if (id != null) {
          context
              .push('/detail-laporan-hama/$id')
              .then((_) => _handleRefresh());
        }
      },
    );
  }

  Widget _buildDaftarHamaContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _filteredDaftarHamaList.map((jenisHama) {
          return UnitItem(
            key: Key('jenis_hama_${jenisHama['id'] ?? 'unknown'}'),
            unitName: jenisHama['nama'] ?? 'N/A',
            onEdit: () {
              final id = jenisHama['id'] as String?;
              if (id != null) {
                context.push('/tambah-hama',
                    extra: AddHamaScreen(
                      isEdit: true,
                      id: id,
                      nama: jenisHama['nama'] ?? '',
                      onHamaAdded: _handleRefresh,
                    ));
              }
            },
            onDelete: () async {
              final id = jenisHama['id'] as String?;
              if (id == null) return;

              final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: const Text("Konfirmasi"),
                        content: Text(
                            "Yakin ingin menghapus jenis hama '${jenisHama['nama']}'?"),
                        actions: [
                          TextButton(
                              key: const Key('cancel_delete_button'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text("Batal")),
                          TextButton(
                              key: const Key('confirm_delete_button'),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text("Hapus",
                                  style: TextStyle(color: Colors.red))),
                        ],
                      ));
              if (confirm == true) {
                final response = await _hamaService.deleteJenisHama(id);
                if (mounted) {
                  showAppToast(
                      context,
                      response['message'] ??
                          (response['status'] == true
                              ? "Berhasil dihapus"
                              : "Gagal dihapus"),
                      isError: response['status'] != true);
                  if (response['status'] == true) _handleRefresh();
                }
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
