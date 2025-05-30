import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_ternak_screen.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
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
  final KomoditasService _komoditasService = KomoditasService();

  final List<dynamic> _komoditasTernakList = [];
  final List<dynamic> _komoditasKebunList = [];

  List<dynamic> _komoditasTernakListFiltered = [];
  List<dynamic> _komoditasKebunListFiltered = [];

  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoading = true;
  bool _isSearching = false;

  int _currentPageKebun = 1;
  bool _isLoadingMoreKebun = false;
  bool _hasNextPageKebun = true;

  int _currentPageTernak = 1;
  bool _isLoadingMoreTernak = false;
  bool _hasNextPageTernak = true;

  int _currentSearchPageKebun = 1;
  bool _isLoadingMoreSearchKebun = false;
  bool _hasNextSearchPageKebun = true;

  int _currentSearchPageTernak = 1;
  bool _isLoadingMoreSearchTernak = false;
  bool _hasNextSearchPageTernak = true;

  final int _pageSize = 6;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

  Future<void> _loadInitialData({bool isRefresh = false}) async {
    if (!mounted) return;
    if (!isRefresh) {
      setState(() {
        _isInitialLoading = true;
      });
    }

    _currentPageKebun = 1;
    _hasNextPageKebun = true;
    _currentPageTernak = 1;
    _hasNextPageTernak = true;

    if (isRefresh) {
      _komoditasKebunList.clear();
      _komoditasTernakList.clear();
      _komoditasKebunListFiltered.clear();
      _komoditasTernakListFiltered.clear();
    }

    await _fetchKomoditasPage(
        tipe: 'tumbuhan', page: 1, isInitialSetupOrRefresh: true);
    await _fetchKomoditasPage(
        tipe: 'hewan', page: 1, isInitialSetupOrRefresh: true);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
        if (_searchController.text.isEmpty) {
          _komoditasKebunListFiltered = List.from(_komoditasKebunList);
          _komoditasTernakListFiltered = List.from(_komoditasTernakList);
        }
      });
    }
  }

  Future<void> _fetchKomoditasPage(
      {required String tipe,
      required int page,
      bool isInitialSetupOrRefresh = false}) async {
    if (!mounted) return;

    bool isLoadingMore =
        tipe == 'tumbuhan' ? _isLoadingMoreKebun : _isLoadingMoreTernak;
    if (isLoadingMore && !isInitialSetupOrRefresh) return;

    if (mounted && !isInitialSetupOrRefresh) {
      setState(() {
        if (tipe == 'tumbuhan') _isLoadingMoreKebun = true;
        if (tipe == 'hewan') _isLoadingMoreTernak = true;
      });
    }

    Map<String, dynamic> response;
    try {
      response = await _komoditasService.getKomoditasByTipe(tipe,
          page: page, limit: _pageSize);
    } catch (e) {
      if (mounted) {
        setState(() {
          if (tipe == 'tumbuhan') _isLoadingMoreKebun = false;
          if (tipe == 'hewan') _isLoadingMoreTernak = false;
          if (isInitialSetupOrRefresh) _isInitialLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memuat data $tipe: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer = response['currentPage'] ?? page;

        if (tipe == 'tumbuhan') {
          if (isInitialSetupOrRefresh || page == 1) _komoditasKebunList.clear();
          _komoditasKebunList.addAll(fetchedData);
          _hasNextPageKebun = currentPageFromServer < totalPages;
          _isLoadingMoreKebun = false;
          if (_searchController.text.isEmpty) {
            _komoditasKebunListFiltered = List.from(_komoditasKebunList);
          }
        } else if (tipe == 'hewan') {
          if (isInitialSetupOrRefresh || page == 1) {
            _komoditasTernakList.clear();
          }
          _komoditasTernakList.addAll(fetchedData);
          _hasNextPageTernak = currentPageFromServer < totalPages;
          _isLoadingMoreTernak = false;
          if (_searchController.text.isEmpty) {
            _komoditasTernakListFiltered = List.from(_komoditasTernakList);
          }
        }
        if (isInitialSetupOrRefresh && tipe == 'hewan') {
          _isInitialLoading = false;
        } else if (isInitialSetupOrRefresh &&
            tipe == 'tumbuhan' &&
            _isInitialLoading) {}
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isInitialLoading &&
        !_isSearching) {
      if (_searchController.text.isNotEmpty) {
        if (_selectedTab == 0 &&
            _hasNextSearchPageKebun &&
            !_isLoadingMoreSearchKebun) {
          _currentSearchPageKebun++;
          _fetchMoreSearchResults(page: _currentSearchPageKebun);
        } else if (_selectedTab == 1 &&
            _hasNextSearchPageTernak &&
            !_isLoadingMoreSearchTernak) {
          _currentSearchPageTernak++;
          _fetchMoreSearchResults(page: _currentSearchPageTernak);
        }
      } else {
        if (_selectedTab == 0 && _hasNextPageKebun && !_isLoadingMoreKebun) {
          _currentPageKebun++;
          _fetchKomoditasPage(tipe: 'tumbuhan', page: _currentPageKebun);
        } else if (_selectedTab == 1 &&
            _hasNextPageTernak &&
            !_isLoadingMoreTernak) {
          _currentPageTernak++;
          _fetchKomoditasPage(tipe: 'hewan', page: _currentPageTernak);
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchKomoditas(query, isNewSearch: true);
    });
  }

  Future<void> _searchKomoditas(String query,
      {bool isNewSearch = false}) async {
    final String normalizedQuery = query.toLowerCase().trim();
    String currentTipe = _selectedTab == 0 ? 'tumbuhan' : 'hewan';

    if (isNewSearch) {
      if (normalizedQuery.isEmpty) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _komoditasTernakListFiltered = List.from(_komoditasTernakList);
            _komoditasKebunListFiltered = List.from(_komoditasKebunList);
            _currentSearchPageKebun = 1;
            _hasNextSearchPageKebun = true;
            _currentSearchPageTernak = 1;
            _hasNextSearchPageTernak = true;
          });
        }
        return;
      }
      setState(() {
        _isSearching = true;
        if (currentTipe == 'tumbuhan') {
          _komoditasKebunListFiltered.clear();
          _currentSearchPageKebun = 1;
          _hasNextSearchPageKebun = true;
        } else {
          _komoditasTernakListFiltered.clear();
          _currentSearchPageTernak = 1;
          _hasNextSearchPageTernak = true;
        }
      });
    } else {
      setState(() {
        if (currentTipe == 'tumbuhan') {
          _isLoadingMoreSearchKebun = true;
        } else {
          _isLoadingMoreSearchTernak = true;
        }
      });
    }

    Map<String, dynamic> response;
    try {
      int pageToFetch = currentTipe == 'tumbuhan'
          ? _currentSearchPageKebun
          : _currentSearchPageTernak;

      response = await _komoditasService.getKomoditasSearch(
          normalizedQuery, currentTipe,
          page: pageToFetch, limit: _pageSize);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          if (currentTipe == 'tumbuhan') {
            _isLoadingMoreSearchKebun = false;
          } else {
            _isLoadingMoreSearchTernak = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal melakukan pencarian: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer = response['currentPage'] ??
            (currentTipe == 'tumbuhan'
                ? _currentSearchPageKebun
                : _currentSearchPageTernak);

        if (response['status'] == true) {
          if (currentTipe == 'tumbuhan') {
            _komoditasKebunListFiltered.addAll(fetchedData);
            _hasNextSearchPageKebun = currentPageFromServer < totalPages;
            _isLoadingMoreSearchKebun = false;
          } else {
            _komoditasTernakListFiltered.addAll(fetchedData);
            _hasNextSearchPageTernak = currentPageFromServer < totalPages;
            _isLoadingMoreSearchTernak = false;
          }
        } else {
          if (currentTipe == 'tumbuhan') {
            if (isNewSearch) {
              _komoditasKebunListFiltered.clear();
              _hasNextSearchPageKebun = false;
              _isLoadingMoreSearchKebun = false;
            } else {
              _hasNextSearchPageKebun = false;
              _isLoadingMoreSearchKebun = false;
            }
          } else {
            if (isNewSearch) {
              _komoditasTernakListFiltered.clear();
              _hasNextSearchPageTernak = false;
              _isLoadingMoreSearchTernak = false;
            } else {
              _hasNextSearchPageTernak = false;
              _isLoadingMoreSearchTernak = false;
            }
          }
          if (response['message'] != null &&
              (response['status'] == false || fetchedData.isEmpty)) {
            if (isNewSearch ||
                (fetchedData.isEmpty && currentPageFromServer == 1)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Info: ${response['message']}')),
              );
            }
          }
        }
      });
    }
  }

  Future<void> _fetchMoreSearchResults({required int page}) async {
    if (_searchController.text.isNotEmpty) {
      await _searchKomoditas(_searchController.text, isNewSearch: false);
    }
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        _searchController.clear();
      });
    }
    await _loadInitialData(isRefresh: true);
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
            void handleKomoditasUpdate() {
              _handleRefresh();
            }

            if (_selectedTab == 0) {
              context.push('/tambah-komoditas-tanaman',
                  extra: AddKomoditasTanamanScreen(
                    isEdit: false,
                    onKomoditasTanamanAdded: handleKomoditasUpdate,
                  ));
            } else {
              context.push('/tambah-komoditas-ternak',
                  extra: AddKomoditasTernakScreen(
                    isEdit: false,
                    onKomoditasAdded: handleKomoditasUpdate,
                  ));
            }
          },
          backgroundColor: green1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchField(
                  hintText: 'Cari komoditas berdasarkan nama',
                  controller: _searchController,
                  onChanged: _onSearchChanged),
            ),
            CustomTabBar(
              tabs: const ['Komoditas Perkebunan', 'Komoditas Peternakan'],
              activeColor: green1,
              activeIndex: _selectedTab,
              onTabSelected: (index) {
                if (_selectedTab == index && !_isInitialLoading) return;
                setState(() {
                  _selectedTab = index;
                  _searchController.clear();

                  bool needsDataForNewTab =
                      (_selectedTab == 0 && _komoditasKebunList.isEmpty) ||
                          (_selectedTab == 1 && _komoditasTernakList.isEmpty);
                  if (needsDataForNewTab && !_isInitialLoading) {
                    _loadInitialData();
                  } else {
                    if (_searchController.text.isEmpty) {
                      _komoditasKebunListFiltered =
                          List.from(_komoditasKebunList);
                      _komoditasTernakListFiltered =
                          List.from(_komoditasTernakList);
                    }
                  }

                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0.0);
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            if (_isInitialLoading &&
                (_selectedTab == 0
                    ? _komoditasKebunListFiltered.isEmpty
                    : _komoditasTernakListFiltered.isEmpty) &&
                !_isSearching)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_isSearching &&
                (_selectedTab == 0
                    ? _komoditasKebunListFiltered.isEmpty
                    : _komoditasTernakListFiltered.isEmpty))
              const Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange))))
            else
              Expanded(
                child: RefreshIndicator(
                  color: green1,
                  backgroundColor: white,
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
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
    bool isLoadingMoreMain = (_selectedTab == 0 && _isLoadingMoreKebun) ||
        (_selectedTab == 1 && _isLoadingMoreTernak);
    bool isLoadingMoreSearch =
        (_selectedTab == 0 && _isLoadingMoreSearchKebun) ||
            (_selectedTab == 1 && _isLoadingMoreSearchTernak);

    if (isLoadingMoreMain || isLoadingMoreSearch) {
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
      // Perkebunan
      if (isCurrentlySearching &&
          _komoditasKebunListFiltered.isEmpty &&
          !_isSearching &&
          !_isLoadingMoreSearchKebun) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Komoditas tanaman tidak ditemukan.")));
      }
      if (!isCurrentlySearching &&
          _komoditasKebunList.isEmpty &&
          !_isInitialLoading &&
          !_isLoadingMoreKebun &&
          !_hasNextPageKebun) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Tidak ada komoditas tanaman yang tersedia.")));
      }

      if (_komoditasKebunListFiltered.isEmpty &&
          (_isInitialLoading ||
              _isLoadingMoreKebun ||
              _isLoadingMoreSearchKebun ||
              _isSearching)) {
        return const SizedBox.shrink();
      }
      return _buildPerkebunanContent();
    } else {
      // Peternakan
      if (isCurrentlySearching &&
          _komoditasTernakListFiltered.isEmpty &&
          !_isSearching &&
          !_isLoadingMoreSearchTernak) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Komoditas ternak tidak ditemukan.")));
      }
      if (!isCurrentlySearching &&
          _komoditasTernakList.isEmpty &&
          !_isInitialLoading &&
          !_isLoadingMoreTernak &&
          !_hasNextPageTernak) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Tidak ada komoditas ternak yang tersedia.")));
      }
      if (_komoditasTernakListFiltered.isEmpty &&
          (_isInitialLoading ||
              _isLoadingMoreTernak ||
              _isLoadingMoreSearchTernak ||
              _isSearching)) {
        return const SizedBox.shrink();
      }
      return _buildPeternakanContent();
    }
  }

  Widget _buildPerkebunanContent() {
    return ListItem(
      items: _komoditasKebunListFiltered
          .map((komoditas) => {
                'name': komoditas['nama'] ?? 'N/A',
                'category': komoditas['JenisBudidaya']?['nama'] ?? 'N/A',
                'icon': komoditas['gambar'] as String? ?? '',
                'id': komoditas['id'],
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
    );
  }

  Widget _buildPeternakanContent() {
    return ListItem(
      items: _komoditasTernakListFiltered
          .map((komoditas) => {
                'name': komoditas['nama'] ?? 'N/A',
                'category': komoditas['JenisBudidaya']?['nama'] ?? 'N/A',
                'icon': komoditas['gambar'] as String? ?? '',
                'id': komoditas['id'],
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
    );
  }
}
