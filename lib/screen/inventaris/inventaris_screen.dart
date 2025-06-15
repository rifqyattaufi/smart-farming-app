import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/chip_filter.dart';
import 'package:smart_farming_app/widget/custom_tab.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  final InventarisService _inventarisService = InventarisService();
  final KomoditasService _komoditasService = KomoditasService();
  final KategoriInvService _kategoriInvService = KategoriInvService();

  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  bool _isInitialLoading = true;
  bool _isSearching = false;

  // Tab 0: Inventaris
  final List<dynamic> _allInventarisList = [];
  List<dynamic> _filteredInventarisList = [];
  List<Map<String, dynamic>> _kategoriInvForFilterChip = [];
  String? _selectedKategoriInventarisId;

  int _currentPageInventaris = 1;
  bool _isLoadingMoreInventaris = false;
  bool _hasNextPageInventaris = true;
  int _currentSearchPageInventaris = 1;
  bool _isLoadingMoreSearchInventaris = false;
  bool _hasNextSearchPageInventaris = true;

  // Tab 1: Hasil Panen (Komoditas)
  final List<dynamic> _komoditasPerkebunanList = [];
  final List<dynamic> _komoditasPeternakanList = [];

  List<dynamic> _displayPerkebunanList = [];
  List<dynamic> _displayPeternakanList = [];

  String _selectedHasilPanenFilter = 'Semua Hasil Panen';

  int _currentPagePerkebunan = 1;
  bool _isLoadingMorePerkebunan = false;
  bool _hasNextPagePerkebunan = true;
  int _currentPagePeternakan = 1;
  bool _isLoadingMorePeternakan = false;
  bool _hasNextPagePeternakan = true;

  // Paginasi untuk search Hasil Panen per tipe
  int _currentSearchPagePerkebunan = 1;
  bool _isLoadingMoreSearchPerkebunan = false;
  bool _hasNextSearchPagePerkebunan = true;
  int _currentSearchPagePeternakan = 1;
  bool _isLoadingMoreSearchPeternakan = false;
  bool _hasNextSearchPagePeternakan = true;

  final int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    _fetchKategoriInventaris();
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

  Future<void> _fetchKategoriInventaris() async {
    try {
      final response = await _kategoriInvService.getKategoriInventaris();
      if (mounted && response['status'] == true && response['data'] != null) {
        setState(() {
          _kategoriInvForFilterChip = [
            {'id': 'all', 'nama': 'Semua Item'}
          ];
          _kategoriInvForFilterChip.addAll(List<Map<String, dynamic>>.from(
              response['data']
                  .map((item) => {'id': item['id'], 'nama': item['nama']})));
          _selectedKategoriInventarisId = 'all';
        });
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    }
  }

  Future<void> _loadInitialDataForCurrentTab({bool isRefresh = false}) async {
    if (!mounted) return;
    if (!isRefresh && !_isSearching) {
      setState(() {
        _isInitialLoading = true;
      });
    }

    String currentSearchQuery = _searchController.text;
    bool searchIsActive = currentSearchQuery.isNotEmpty;

    if (_selectedTab == 0) {
      // Inventaris
      _currentPageInventaris = 1;
      _hasNextPageInventaris = true;
      _currentSearchPageInventaris = 1;
      _hasNextSearchPageInventaris = true;
      if (isRefresh) {
        _allInventarisList.clear();
        _filteredInventarisList.clear();
      }
      await _fetchInventarisPage(
          page: 1,
          isInitialSetupOrRefresh: true,
          searchQuery: searchIsActive ? currentSearchQuery : null);
    } else {
      // Hasil Panen
      _currentPagePerkebunan = 1;
      _hasNextPagePerkebunan = true;
      _currentPagePeternakan = 1;
      _hasNextPagePeternakan = true;
      _currentSearchPagePerkebunan = 1;
      _hasNextSearchPagePerkebunan = true;
      _currentSearchPagePeternakan = 1;
      _hasNextSearchPagePeternakan = true;

      if (isRefresh) {
        _komoditasPerkebunanList.clear();
        _komoditasPeternakanList.clear();
        _displayPerkebunanList.clear();
        _displayPeternakanList.clear();
      }

      List<Future> initialHasilPanenFetches = [];
      if (!searchIsActive ||
          _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
          _selectedHasilPanenFilter == 'Perkebunan') {
        initialHasilPanenFetches.add(_fetchKomoditasTipePage('tumbuhan',
            page: 1,
            isInitialSetupOrRefresh: true,
            searchQuery: searchIsActive ? currentSearchQuery : null));
      }
      if (!searchIsActive ||
          _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
          _selectedHasilPanenFilter == 'Peternakan') {
        initialHasilPanenFetches.add(_fetchKomoditasTipePage('hewan',
            page: 1,
            isInitialSetupOrRefresh: true,
            searchQuery: searchIsActive ? currentSearchQuery : null));
      }
      if (initialHasilPanenFetches.isNotEmpty) {
        await Future.wait(initialHasilPanenFetches);
      }
    }

    if (mounted && !isRefresh && !_isSearching) {
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  void _updateDisplayListsAfterFetchOrFilterChange() {
    if (!mounted) return;
    setState(() {
      if (_selectedTab == 0) {
        // Inventaris
        if (_searchController.text.isEmpty) {
          _filteredInventarisList = List.from(_allInventarisList);
        }
      } else {
        // Hasil Panen
        if (_searchController.text.isEmpty) {
          _displayPerkebunanList = List.from(_komoditasPerkebunanList);
          _displayPeternakanList = List.from(_komoditasPeternakanList);
        }
      }
    });
  }

  // --- Inventaris (Tab 0) ---
  Future<void> _fetchInventarisPage(
      {required int page,
      bool isInitialSetupOrRefresh = false,
      String? searchQuery}) async {
    if (!mounted ||
        (_isLoadingMoreInventaris &&
            !isInitialSetupOrRefresh &&
            searchQuery == null) ||
        (_isLoadingMoreSearchInventaris && searchQuery != null)) {
      return;
    }

    bool isSearchOp = searchQuery != null && searchQuery.isNotEmpty;
    if (mounted) {
      setState(() {
        if (isSearchOp) {
          if (isInitialSetupOrRefresh) {
            _isSearching = true;
          } else {
            _isLoadingMoreSearchInventaris = true;
          }
        } else {
          if (!isInitialSetupOrRefresh) _isLoadingMoreInventaris = true;
        }
      });
    }

    Map<String, dynamic> response;
    try {
      response = await _inventarisService.getPagedInventaris(
        page: page,
        limit: _pageSize,
        kategoriId: (isSearchOp || _selectedKategoriInventarisId == 'all')
            ? null
            : _selectedKategoriInventarisId,
        searchQuery: searchQuery,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isSearchOp) {
            _isSearching = false;
            _isLoadingMoreSearchInventaris = false;
          } else {
            _isLoadingMoreInventaris = false;
          }
          if (isInitialSetupOrRefresh && !isSearchOp) _isInitialLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer = response['currentPage'] ?? page;

        if (isSearchOp) {
          if (isInitialSetupOrRefresh || page == 1) {
            _filteredInventarisList.clear();
          }
          _filteredInventarisList.addAll(fetchedData);
          _hasNextSearchPageInventaris = currentPageFromServer < totalPages;
        } else {
          if (isInitialSetupOrRefresh || page == 1) _allInventarisList.clear();
          _allInventarisList.addAll(fetchedData);
          _hasNextPageInventaris = currentPageFromServer < totalPages;
          _isLoadingMoreInventaris = false;
          if (_searchController.text.isEmpty) {
            _filteredInventarisList = List.from(_allInventarisList);
          }
        }
        if (isSearchOp && isInitialSetupOrRefresh) {
        } else if (isSearchOp) {
          _isLoadingMoreSearchInventaris = false;
        } else if (isInitialSetupOrRefresh) {
          _isInitialLoading = false;
        } else {
          _isLoadingMoreInventaris = false;
        }
      });
    }
  }

  // --- Hasil Panen (Tab 1) ---
  Future<void> _fetchKomoditasTipePage(String tipe,
      {required int page,
      bool isInitialSetupOrRefresh = false,
      String? searchQuery}) async {
    if (!mounted) return;

    bool isSearchOp = searchQuery != null && searchQuery.isNotEmpty;

    List<dynamic> targetDisplayList =
        tipe == 'tumbuhan' ? _displayPerkebunanList : _displayPeternakanList;
    List<dynamic> mainDataList = tipe == 'tumbuhan'
        ? _komoditasPerkebunanList
        : _komoditasPeternakanList;

    bool isLoadingMoreFlag;
    Function(bool) setIsLoadingMoreFunction;
    Function(bool) setHasNextPageFunction;

    if (tipe == 'tumbuhan') {
      isLoadingMoreFlag = isSearchOp
          ? _isLoadingMoreSearchPerkebunan
          : _isLoadingMorePerkebunan;
      setIsLoadingMoreFunction = (val) => isSearchOp
          ? _isLoadingMoreSearchPerkebunan = val
          : _isLoadingMorePerkebunan = val;
      setHasNextPageFunction = (val) => isSearchOp
          ? _hasNextSearchPagePerkebunan = val
          : _hasNextPagePerkebunan = val;
    } else {
      // hewan
      isLoadingMoreFlag = isSearchOp
          ? _isLoadingMoreSearchPeternakan
          : _isLoadingMorePeternakan;
      setIsLoadingMoreFunction = (val) => isSearchOp
          ? _isLoadingMoreSearchPeternakan = val
          : _isLoadingMorePeternakan = val;
      setHasNextPageFunction = (val) => isSearchOp
          ? _hasNextSearchPagePeternakan = val
          : _hasNextPagePeternakan = val;
    }

    if (isLoadingMoreFlag && !isInitialSetupOrRefresh) return;

    if (mounted) {
      setState(() {
        if (isSearchOp) {
          if (isInitialSetupOrRefresh) {
            /* _isSearching dihandle di _onSearchChanged */
          }
          setIsLoadingMoreFunction(true);
        } else {
          if (!isInitialSetupOrRefresh) setIsLoadingMoreFunction(true);
        }
      });
    }

    Map<String, dynamic> response;
    try {
      if (isSearchOp) {
        response = await _komoditasService.getKomoditasSearch(searchQuery, tipe,
            page: page, limit: _pageSize);
      } else {
        response = await _komoditasService.getKomoditasByTipe(tipe,
            page: page, limit: _pageSize);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          setIsLoadingMoreFunction(false);
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
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer = response['currentPage'] ?? page;

        if (isSearchOp) {
          if (isInitialSetupOrRefresh || page == 1) targetDisplayList.clear();
          targetDisplayList.addAll(fetchedData);
        } else {
          if (isInitialSetupOrRefresh || page == 1) mainDataList.clear();
          mainDataList.addAll(fetchedData);
          if (_searchController.text.isEmpty) {
            if (tipe == 'tumbuhan') {
              _displayPerkebunanList = List.from(_komoditasPerkebunanList);
            } else {
              _displayPeternakanList = List.from(_komoditasPeternakanList);
            }
          }
        }
        setHasNextPageFunction(currentPageFromServer < totalPages);
        setIsLoadingMoreFunction(false);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isInitialLoading &&
        !_isSearching) {
      if (_selectedTab == 0) {
        // Inventaris
        if (_searchController.text.isNotEmpty) {
          if (_hasNextSearchPageInventaris && !_isLoadingMoreSearchInventaris) {
            _currentSearchPageInventaris++;
            _fetchInventarisPage(
                page: _currentSearchPageInventaris,
                searchQuery: _searchController.text);
          }
        } else {
          if (_hasNextPageInventaris && !_isLoadingMoreInventaris) {
            _currentPageInventaris++;
            _fetchInventarisPage(page: _currentPageInventaris);
          }
        }
      } else {
        // Hasil Panen
        if (_searchController.text.isNotEmpty) {
          bool canLoadMorePerkebunan =
              _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                  _selectedHasilPanenFilter == 'Perkebunan';
          bool canLoadMorePeternakan =
              _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                  _selectedHasilPanenFilter == 'Peternakan';

          if (canLoadMorePerkebunan &&
              _hasNextSearchPagePerkebunan &&
              !_isLoadingMoreSearchPerkebunan) {
            _currentSearchPagePerkebunan++;
            _fetchKomoditasTipePage('tumbuhan',
                page: _currentSearchPagePerkebunan,
                searchQuery: _searchController.text);
          }
          if (canLoadMorePeternakan &&
              _hasNextSearchPagePeternakan &&
              !_isLoadingMoreSearchPeternakan) {
            _currentSearchPagePeternakan++;
            _fetchKomoditasTipePage('hewan',
                page: _currentSearchPagePeternakan,
                searchQuery: _searchController.text);
          }
        } else {
          if ((_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                  _selectedHasilPanenFilter == 'Perkebunan') &&
              _hasNextPagePerkebunan &&
              !_isLoadingMorePerkebunan) {
            _currentPagePerkebunan++;
            _fetchKomoditasTipePage('tumbuhan', page: _currentPagePerkebunan);
          }
          if ((_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                  _selectedHasilPanenFilter == 'Peternakan') &&
              _hasNextPagePeternakan &&
              !_isLoadingMorePeternakan) {
            _currentPagePeternakan++;
            _fetchKomoditasTipePage('hewan', page: _currentPagePeternakan);
          }
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final String normalizedQuery = query.toLowerCase().trim();

      if (_selectedTab == 0) {
        // Inventaris
        _currentSearchPageInventaris = 1; // Reset page
        _hasNextSearchPageInventaris = true;
        _fetchInventarisPage(
            page: 1,
            searchQuery: normalizedQuery,
            isInitialSetupOrRefresh: true);
      } else {
        // Hasil Panen
        _currentSearchPagePerkebunan = 1;
        _hasNextSearchPagePerkebunan = true;
        _currentSearchPagePeternakan = 1;
        _hasNextSearchPagePeternakan = true;

        if (normalizedQuery.isEmpty) {
          setState(() {
            _isSearching = false; // Matikan global search state
            _displayPerkebunanList = List.from(_komoditasPerkebunanList);
            _displayPeternakanList = List.from(_komoditasPeternakanList);
          });
          return;
        }

        setState(() {
          _isSearching = true;
        });

        _displayPerkebunanList.clear();
        _displayPeternakanList.clear();

        bool searchPerkebunan =
            _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                _selectedHasilPanenFilter == 'Perkebunan';
        bool searchPeternakan =
            _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                _selectedHasilPanenFilter == 'Peternakan';

        List<Future> searchFutures = [];
        if (searchPerkebunan) {
          searchFutures.add(_fetchKomoditasTipePage('tumbuhan',
              page: 1,
              searchQuery: normalizedQuery,
              isInitialSetupOrRefresh: true));
        }
        if (searchPeternakan) {
          searchFutures.add(_fetchKomoditasTipePage('hewan',
              page: 1,
              searchQuery: normalizedQuery,
              isInitialSetupOrRefresh: true));
        }

        if (searchFutures.isEmpty && mounted) {
          setState(() => _isSearching = false);
          return;
        }

        Future.wait(searchFutures).whenComplete(() {
          if (mounted) {
            setState(() {
              _isSearching = false;
            });
          }
        });
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
    String selectedKategoriNama = "Semua Item";
    if (_selectedKategoriInventarisId != null &&
        _selectedKategoriInventarisId != 'all' &&
        _kategoriInvForFilterChip.isNotEmpty) {
      var found = _kategoriInvForFilterChip.firstWhere(
          (kat) => kat['id'] == _selectedKategoriInventarisId,
          orElse: () => <String, dynamic>{});
      if (found.isNotEmpty && found['nama'] != null) {
        selectedKategoriNama = found['nama'];
      }
    }

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
      floatingActionButton: _selectedTab == 0
          ? SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                key: const Key('addInventarisButton'),
                onPressed: () {
                  context
                      .push('/tambah-inventaris',
                          extra: AddInventarisScreen(
                            isEdit: false,
                            onInventarisAdded: _handleRefresh,
                          ))
                      .then((_) {/* _handleRefresh(); */});
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
                  key: const Key('inventarisSearchField'),
                  controller: _searchController,
                  onChanged: _onSearchChanged),
            ),
            CustomTabBar(
              key: const Key('inventarisTabs'),
              tabs: const ['Inventaris', 'Hasil Panen'],
              activeColor: green1,
              activeIndex: _selectedTab,
              onTabSelected: (index) {
                if (_selectedTab == index &&
                    !_isInitialLoading &&
                    !_isSearching) {
                  return; // Hindari rebuild jika tab sama & tidak loading
                }
                setState(() {
                  _selectedTab = index;
                  if (_searchController.text.isNotEmpty) {
                    _searchController.clear();
                  } else {
                    // Jika search sudah kosong, kita perlu update display list secara manual
                    _updateDisplayListsAfterFetchOrFilterChange();
                  }

                  bool needsData =
                      (_selectedTab == 0 && _allInventarisList.isEmpty) ||
                          (_selectedTab == 1 &&
                              (_komoditasPerkebunanList.isEmpty &&
                                  _komoditasPeternakanList.isEmpty));
                  if (needsData && !_isInitialLoading && !_isSearching) {
                    // Hanya load jika belum ada data dan tidak sedang ada proses lain
                    _loadInitialDataForCurrentTab();
                  }
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0.0);
                  }
                });
              },
            ),
            if (_selectedTab == 0 && _kategoriInvForFilterChip.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ChipFilter(
                  key: const Key('kategoriInventarisFilterChip'),
                  categories: _kategoriInvForFilterChip
                      .map((kat) => kat['nama'] as String)
                      .toList(),
                  selectedCategory: selectedKategoriNama,
                  onCategorySelected: (categoryName) {
                    setState(() {
                      var selectedCat = _kategoriInvForFilterChip.firstWhere(
                          (kat) => kat['nama'] == categoryName,
                          orElse: () => <String, dynamic>{});
                      _selectedKategoriInventarisId =
                          selectedCat['id'] as String? ?? 'all';
                      _currentPageInventaris = 1;
                      _hasNextPageInventaris = true; // Reset paginasi
                      _currentSearchPageInventaris = 1;
                      _hasNextSearchPageInventaris = true;
                      _allInventarisList.clear();
                      _filteredInventarisList.clear(); // Kosongkan list
                      _fetchInventarisPage(
                          page: 1,
                          isInitialSetupOrRefresh: true,
                          searchQuery: _searchController.text.isNotEmpty
                              ? _searchController.text
                              : null);
                    });
                  },
                ),
              ),
            if (_selectedTab == 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ChipFilter(
                  key: const Key('hasilPanenFilterChip'),
                  categories: const [
                    'Semua Hasil Panen',
                    'Perkebunan',
                    'Peternakan',
                  ],
                  selectedCategory: _selectedHasilPanenFilter,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedHasilPanenFilter = category;
                    });
                  },
                ),
              ),
            const SizedBox(height: 8),
            if ((_isInitialLoading || _isSearching) &&
                (_selectedTab == 0
                    ? _filteredInventarisList.isEmpty
                    : (_displayPerkebunanList.isEmpty &&
                        _displayPeternakanList.isEmpty)))
              Expanded(
                  child: Center(
                      child: CircularProgressIndicator(
                valueColor: _isSearching
                    ? const AlwaysStoppedAnimation<Color>(Colors.orange)
                    : null,
              )))
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
    bool isLoadingInventaris =
        _isLoadingMoreInventaris || _isLoadingMoreSearchInventaris;
    bool isLoadingHasilPanenPerkebunan =
        _isLoadingMorePerkebunan || _isLoadingMoreSearchPerkebunan;
    bool isLoadingHasilPanenPeternakan =
        _isLoadingMorePeternakan || _isLoadingMoreSearchPeternakan;

    bool showIndicator = false;
    if (_selectedTab == 0 && isLoadingInventaris) {
      showIndicator = true;
    } else if (_selectedTab == 1) {
      if ((_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
              _selectedHasilPanenFilter == 'Perkebunan') &&
          isLoadingHasilPanenPerkebunan) {
        showIndicator = true;
      }
      if ((_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
              _selectedHasilPanenFilter == 'Peternakan') &&
          isLoadingHasilPanenPeternakan) {
        showIndicator =
            true; // Bisa jadi ada dua indikator jika keduanya loading, atau gabungkan logikanya
      }
      // Jika salah satu loading, tampilkan.
      if (isLoadingHasilPanenPerkebunan || isLoadingHasilPanenPeternakan) {
        showIndicator = true;
      }
    }

    if (showIndicator) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _emptyContent(String message) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              key: const Key('emptyContentMessage'),
              message,
              style: regular14.copyWith(color: dark2),
              textAlign: TextAlign.center,
            )));
  }

  Widget _buildTabContent() {
    bool isCurrentlySearching = _searchController.text.isNotEmpty;
    if (_selectedTab == 0) {
      // Inventaris
      bool listToShowIsEmpty = _filteredInventarisList.isEmpty;
      bool mainListIsEmpty = _allInventarisList.isEmpty;
      bool isLoadingMore =
          _isLoadingMoreInventaris || _isLoadingMoreSearchInventaris;
      bool hasNextPage = isCurrentlySearching
          ? _hasNextSearchPageInventaris
          : _hasNextPageInventaris;

      if (isCurrentlySearching &&
          listToShowIsEmpty &&
          !_isSearching &&
          !isLoadingMore) {
        return _emptyContent("Inventaris tidak ditemukan.");
      }
      if (!isCurrentlySearching &&
          mainListIsEmpty &&
          !_isInitialLoading &&
          !isLoadingMore &&
          !hasNextPage) {
        return _emptyContent("Tidak ada data inventaris yang tersedia.");
      }
      if (listToShowIsEmpty &&
          (_isInitialLoading || _isSearching || isLoadingMore)) {
        return const SizedBox(
            height: 200,
            child: Center(child: Text("Memuat data inventaris...")));
      }
      if (listToShowIsEmpty &&
          !isCurrentlySearching &&
          !_isInitialLoading &&
          !isLoadingMore) {
        return _emptyContent(_selectedKategoriInventarisId != null &&
                _selectedKategoriInventarisId != 'all'
            ? "Tidak ada inventaris pada kategori ini."
            : "Tidak ada data inventaris.");
      }
      return _buildInventarisContent();
    } else {
      // Hasil Panen

      // Menggunakan _displayPerkebunanList dan _displayPeternakanList
      bool showPerkebunan = _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
          _selectedHasilPanenFilter == 'Perkebunan';
      bool showPeternakan = _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
          _selectedHasilPanenFilter == 'Peternakan';

      bool perkebunanEffectivelyEmpty =
          showPerkebunan && _displayPerkebunanList.isEmpty;
      bool peternakanEffectivelyEmpty =
          showPeternakan && _displayPeternakanList.isEmpty;

      bool isLoadingAnyPerkebunan =
          _isLoadingMorePerkebunan || _isLoadingMoreSearchPerkebunan;
      bool isLoadingAnyPeternakan =
          _isLoadingMorePeternakan || _isLoadingMoreSearchPeternakan;

      // Jika semua section yang relevan kosong dan tidak ada proses loading global
      if ((showPerkebunan ? perkebunanEffectivelyEmpty : true) &&
          (showPeternakan ? peternakanEffectivelyEmpty : true) &&
          !_isInitialLoading &&
          !_isSearching &&
          !isLoadingAnyPerkebunan &&
          !isLoadingAnyPeternakan) {
        if (isCurrentlySearching) {
          return _emptyContent(
              "Hasil panen tidak ditemukan untuk pencarian ini.");
        }
        if (_selectedHasilPanenFilter != 'Semua Hasil Panen') {
          return _emptyContent("Tidak ada hasil panen pada filter ini.");
        }
        return _emptyContent("Tidak ada data hasil panen yang tersedia.");
      }

      // Jika salah satu section yang relevan kosong tapi sedang ada proses loading global atau search
      if (((showPerkebunan &&
                      _displayPerkebunanList.isEmpty &&
                      (isLoadingAnyPerkebunan ||
                          _isInitialLoading ||
                          _isSearching)) ||
                  (showPeternakan &&
                      _displayPeternakanList.isEmpty &&
                      (isLoadingAnyPeternakan ||
                          _isInitialLoading ||
                          _isSearching))) &&
              !(perkebunanEffectivelyEmpty &&
                  peternakanEffectivelyEmpty &&
                  !_isInitialLoading &&
                  !_isSearching) // hindari jika keduanya memang kosong tanpa loading
          ) {
        return const SizedBox(
            height: 200,
            child: Center(child: Text("Memuat data hasil panen...")));
      }

      return _buildHarvestContent();
    }
  }

  Widget _buildInventarisContent() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> itemBaruSource =
        List.from(_filteredInventarisList);
    itemBaruSource.sort((a, b) {
      final dateA = a['createdAt'] != null
          ? DateTime.tryParse(a['createdAt'].replaceFirst(' ', 'T'))
          : null;
      final dateB = b['createdAt'] != null
          ? DateTime.tryParse(b['createdAt'].replaceFirst(' ', 'T'))
          : null;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    final itemBaru = itemBaruSource
        .where((inventaris) {
          final createdAtString = inventaris['createdAt'] as String?;
          if (createdAtString == null) return false;
          final createdAt =
              DateTime.tryParse(createdAtString.replaceFirst(' ', 'T'));
          if (createdAt == null) return false;
          return now.difference(createdAt).inDays <= 7;
        })
        .take(3)
        .toList();

    final stokRendah = _filteredInventarisList.where((inventaris) {
      final jumlah = inventaris['jumlah'] as int? ?? 0;
      final stokMinim = inventaris['stokMinim'] as int? ?? 0;
      return jumlah > 0 && stokMinim > 0 && jumlah < stokMinim;
    }).toList();

    final stokHabis = _filteredInventarisList.where((inventaris) {
      final jumlah = inventaris['jumlah'] as int? ?? 0;
      return jumlah == 0;
    }).toList();

    final itemYangSudahKadaluwarsa =
        _filteredInventarisList.where((inventaris) {
      final tanggalKadaluwarsaString =
          inventaris['tanggalKadaluwarsa'] as String?;

      if (tanggalKadaluwarsaString == null) return false;

      final kadaluarsaDate =
          DateTime.tryParse(tanggalKadaluwarsaString.replaceFirst(' ', 'T'));

      if (kadaluarsaDate == null) return false;

      return kadaluarsaDate.isBefore(now);
    }).toList();

    bool showSemuaInventarisSection = _filteredInventarisList.isNotEmpty;

    String formatTanggalKadaluwarsa(String? tanggalKadaluwarsaString) {
      if (tanggalKadaluwarsaString == null ||
          tanggalKadaluwarsaString.isEmpty) {
        return 'Tanggal tidak tersedia';
      }

      try {
        DateTime? tanggalKadaluwarsa =
            DateTime.tryParse(tanggalKadaluwarsaString);

        if (tanggalKadaluwarsa == null) {
          return 'Format tanggal tidak valid';
        }

        if (tanggalKadaluwarsa.year < 1900) {
          return 'Tidak diatur';
        }

        final DateFormat formatter = DateFormat('EE, MMM dd yyyy HH:mm');

        return formatter.format(tanggalKadaluwarsa);
      } catch (e) {
        return 'Error format tanggal';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (itemBaru.isNotEmpty)
          ListItem(
            key: const Key('itemBaruListItem'),
            title: 'Item Baru (7 Hari Terakhir)',
            type: 'basic',
            items: itemBaru
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category':
                          'Stok: ${inventaris['jumlah'] ?? 0} ${inventaris['Satuan']?['lambang'] ?? ''}',
                      'icon': inventaris['gambar'] as String?,
                      'id': inventaris['id'],
                    })
                .toList(),
            onItemTap: (ctx, item) => context
                .push('/detail-inventaris/${item['id']}')
                .then((_) => _handleRefresh()),
          ),
        if (itemYangSudahKadaluwarsa.isNotEmpty)
          ListItem(
            key: const Key('itemKadaluwarsaListItem'),
            title: 'Item Kadaluwarsa',
            type: 'basic',
            items: itemYangSudahKadaluwarsa
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category':
                          'Kadaluwarsa pada: ${formatTanggalKadaluwarsa(inventaris['tanggalKadaluwarsa'])}',
                      'icon': inventaris['gambar'] as String?,
                      'id': inventaris['id'],
                      'isActive': false,
                    })
                .toList(),
            onItemTap: (ctx, item) => context
                .push('/detail-inventaris/${item['id']}')
                .then((_) => _handleRefresh()),
          ),
        if (stokRendah.isNotEmpty)
          ListItem(
            key: const Key('stokRendahListItem'),
            title: 'Stok Rendah',
            type: 'basic',
            items: stokRendah
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category':
                          'Stok: ${inventaris['jumlah'] ?? 0} ${inventaris['Satuan']?['lambang'] ?? ''} (Min: ${inventaris['stokMinim'] ?? 0})',
                      'icon': inventaris['gambar'] as String?,
                      'id': inventaris['id'],
                    })
                .toList(),
            onItemTap: (ctx, item) => context
                .push('/detail-inventaris/${item['id']}')
                .then((_) => _handleRefresh()),
          ),
        if (stokHabis.isNotEmpty)
          ListItem(
            key: const Key('stokHabisListItem'),
            title: 'Stok Habis',
            type: 'basic',
            items: stokHabis
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category': 'Stok: Habis',
                      'icon': inventaris['gambar'] as String?,
                      'id': inventaris['id'],
                    })
                .toList(),
            onItemTap: (ctx, item) => context
                .push('/detail-inventaris/${item['id']}')
                .then((_) => _handleRefresh()),
          ),
        if (showSemuaInventarisSection)
          ListItem(
            key: const Key('semuaInventarisListItem'),
            title: 'Semua Stok Inventaris',
            items: _filteredInventarisList
                .map((inventaris) => {
                      'name': inventaris['nama'] ?? 'N/A',
                      'category':
                          'Stok: ${inventaris['jumlah'] ?? 0} ${inventaris['Satuan']?['lambang'] ?? ''}',
                      'icon': inventaris['gambar'] as String?,
                      'id': inventaris['id'],
                      'subCategory':
                          inventaris['kategoriInventaris']?['nama'] ?? '',
                    })
                .toList(),
            type: 'basic',
            onItemTap: (ctx, item) => context
                .push('/detail-inventaris/${item['id']}')
                .then((_) => _handleRefresh()),
          ),
      ],
    );
  }

  Widget _buildHarvestContent() {
    bool isSearchingActive = _searchController.text.isNotEmpty;

    List<dynamic> currentPerkebunanList = _displayPerkebunanList;
    List<dynamic> currentPeternakanList = _displayPeternakanList;

    // Kontrol visibilitas section berdasarkan filter chip
    bool showPerkebunanSection =
        _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
            _selectedHasilPanenFilter == 'Perkebunan';
    bool showPeternakanSection =
        _selectedHasilPanenFilter == 'Semua Hasil Panen' ||
            _selectedHasilPanenFilter == 'Peternakan';

    // Menentukan section Perkebunan sedang dalam proses loading aktif atau tidak
    bool isPerkebunanCurrentlyLoading = currentPerkebunanList.isEmpty &&
        ((_isInitialLoading &&
                !isSearchingActive &&
                (_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                    _selectedHasilPanenFilter ==
                        'Perkebunan')) || // Initial load untuk list utama Perkebunan
            _isLoadingMorePerkebunan ||
            (_isSearching &&
                isSearchingActive &&
                (_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                    _selectedHasilPanenFilter ==
                        'Perkebunan')) || // Search baru sedang berjalan untuk Perkebunan
            (isSearchingActive && _isLoadingMoreSearchPerkebunan));

    // Menentukan section Peternakan sedang dalam proses loading aktif atau tidak
    bool isPeternakanCurrentlyLoading = currentPeternakanList.isEmpty &&
        ((_isInitialLoading &&
                !isSearchingActive &&
                (_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                    _selectedHasilPanenFilter ==
                        'Peternakan')) || // Initial load untuk list utama Peternakan
            _isLoadingMorePeternakan ||
            (_isSearching &&
                isSearchingActive &&
                (_selectedHasilPanenFilter == 'Semua Hasil Panen' ||
                    _selectedHasilPanenFilter ==
                        'Peternakan')) || // Search baru sedang berjalan untuk Peternakan
            (isSearchingActive && _isLoadingMoreSearchPeternakan));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPerkebunanSection) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Text("Perkebunan", style: bold18.copyWith(color: dark1)),
          ),
          if (isPerkebunanCurrentlyLoading)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Memuat data perkebunan...",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('loadingPerkebunanMessage'))))
          else if (currentPerkebunanList.isEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  key: const Key('noPerkebunanDataMessage'),
                  "Tidak ada data perkebunan${isSearchingActive ? ' untuk pencarian ini' : (_selectedHasilPanenFilter != 'Semua Hasil Panen' ? ' pada filter ini' : '')}.",
                  style: regular14.copyWith(color: dark2),
                ),
              ),
            )
          else
            ListItem(
              key: const Key('perkebunanListItem'),
              items: currentPerkebunanList.map((komoditas) {
                final satuan = komoditas['Satuan'];
                return {
                  'name': komoditas['nama'] ?? 'N/A',
                  'category':
                      'Jumlah Stok ${komoditas['jumlah'] ?? 'N/A'} ${satuan != null ? satuan['lambang'] : ''}',
                  'icon': komoditas['gambar'] as String?,
                  'id': komoditas['id'],
                };
              }).toList(),
              type: 'basic',
            ),
          const SizedBox(height: 16),
        ],
        if (showPeternakanSection) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
                16.0,
                (showPerkebunanSection && currentPerkebunanList.isNotEmpty)
                    ? 0.0
                    : 8.0,
                16.0,
                8.0),
            child: Text("Peternakan", style: bold18.copyWith(color: dark1)),
          ),
          if (isPeternakanCurrentlyLoading) // Jika sedang loading aktif untuk Peternakan dan listnya masih kosong
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Memuat data peternakan...",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('loadingPeternakanMessage'))))
          else if (currentPeternakanList
              .isEmpty) // Jika tidak loading dan list kosong
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Center(
                child: Text(
                  key: const Key('noPeternakanDataMessage'),
                  "Tidak ada data peternakan${isSearchingActive ? ' untuk pencarian ini' : (_selectedHasilPanenFilter != 'Semua Hasil Panen' ? ' pada filter ini' : '')}.",
                  style: regular14.copyWith(color: dark2),
                ),
              ),
            )
          else
            ListItem(
              key: const Key('peternakanListItem'),
              items: currentPeternakanList.map((komoditas) {
                final satuan = komoditas['Satuan'];
                return {
                  'name': komoditas['nama'] ?? 'N/A',
                  'category':
                      'Jumlah Stok ${komoditas['jumlah'] ?? 'N/A'} ${satuan != null ? satuan['lambang'] : ''}',
                  'icon': komoditas['gambar'] as String?,
                  'id': komoditas['id'],
                };
              }).toList(),
              type: 'basic',
            ),
        ],
      ],
    );
  }
}
