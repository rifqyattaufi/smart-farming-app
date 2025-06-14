import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class TanamanScreen extends StatefulWidget {
  const TanamanScreen({super.key});

  @override
  State<TanamanScreen> createState() => _TanamanScreenState();
}

class _TanamanScreenState extends State<TanamanScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final AuthService _authService = AuthService();

  List<dynamic> _tanamanList = [];
  List<dynamic> _filteredTanamanList = [];
  String? _userRole;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoading = true;
  bool _isSearching = false;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasNextPage = true;

  int _currentSearchPage = 1;
  bool _isLoadingMoreSearch = false;
  bool _hasNextSearchPage = true;

  final int _pageSize = 20;

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

    final role = await _authService.getUserRole();

    _currentPage = 1;
    _hasNextPage = true;
    if (isRefresh) {
      _tanamanList.clear();
      _filteredTanamanList.clear();
    }

    await _fetchDataPage(page: 1, isInitialSetupOrRefresh: true);

    if (mounted) {
      setState(() {
        _userRole = role;
        _isInitialLoading = false;
        if (_searchController.text.isEmpty) {
          _filteredTanamanList = List.from(_tanamanList);
        }
      });
    }
  }

  Future<void> _fetchDataPage(
      {required int page, bool isInitialSetupOrRefresh = false}) async {
    if (!mounted) return;
    if (_isLoadingMore && !isInitialSetupOrRefresh) return;

    if (mounted && !isInitialSetupOrRefresh) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    Map<String, dynamic> response;
    try {
      response = await _jenisBudidayaService.getJenisBudidayaByTipe(
        'tumbuhan',
        page: page,
        limit: _pageSize,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
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
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer = response['currentPage'] ?? page;

        if (isInitialSetupOrRefresh || page == 1) _tanamanList.clear();
        _tanamanList.addAll(fetchedData);
        _hasNextPage = currentPageFromServer < totalPages;
        _isLoadingMore = false;

        if (_searchController.text.isEmpty) {
          _filteredTanamanList = List.from(_tanamanList);
        }
        if (isInitialSetupOrRefresh) _isInitialLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isInitialLoading &&
        !_isSearching) {
      if (_searchController.text.isNotEmpty) {
        if (_hasNextSearchPage && !_isLoadingMoreSearch) {
          _currentSearchPage++;
          _fetchMoreSearchResults(page: _currentSearchPage);
        }
      } else {
        if (_hasNextPage && !_isLoadingMore) {
          _currentPage++;
          _fetchDataPage(page: _currentPage);
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _searchTanaman(query, isNewSearch: true);
    });
  }

  Future<void> _searchTanaman(String query, {bool isNewSearch = false}) async {
    final String normalizedQuery = query.toLowerCase().trim();

    if (isNewSearch) {
      if (normalizedQuery.isEmpty) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _filteredTanamanList = List.from(_tanamanList);
            _currentSearchPage = 1;
            _hasNextSearchPage = true;
          });
        }
        return;
      }
      setState(() {
        _isSearching = true;
        _filteredTanamanList.clear();
        _currentSearchPage = 1;
        _hasNextSearchPage = true;
      });
    } else {
      setState(() {
        _isLoadingMoreSearch = true;
      });
    }

    Map<String, dynamic> response;
    try {
      response = await _jenisBudidayaService.getJenisBudidayaSearch(
        normalizedQuery,
        'tumbuhan',
        page: _currentSearchPage,
        limit: _pageSize,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isLoadingMoreSearch = false;
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _isLoadingMoreSearch = false;
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer =
            response['currentPage'] ?? _currentSearchPage;

        if (response['status'] == true) {
          _filteredTanamanList.addAll(fetchedData);
          _hasNextSearchPage = currentPageFromServer < totalPages;
        } else {
          if (isNewSearch) _filteredTanamanList.clear();
          _hasNextSearchPage = false;
        }
      });
    }
  }

  Future<void> _fetchMoreSearchResults({required int page}) async {
    if (_searchController.text.isNotEmpty) {
      await _searchTanaman(_searchController.text, isNewSearch: false);
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
            title: 'Manajemen Jenis Tanaman',
            greeting: 'Daftar Jenis Tanaman',
          ),
        ),
      ),
      floatingActionButton: _userRole == 'pjawab'
          ? SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: () {
                  void handleTanamanUpdate() {
                    _handleRefresh();
                  }

                  context.push('/tambah-tanaman',
                      extra: AddTanamanScreen(
                        isEdit: false,
                        onTanamanAdded: handleTanamanUpdate,
                      ));
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
                  hintText: 'Cari jenis tanaman berdasarkan nama',
                  controller: _searchController,
                  onChanged: _onSearchChanged),
            ),
            const SizedBox(height: 10),
            if (_isInitialLoading &&
                _filteredTanamanList.isEmpty &&
                !_isSearching)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_isSearching && _filteredTanamanList.isEmpty)
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
                          _buildContent(),
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
    bool isLoading = _isLoadingMore || _isLoadingMoreSearch;
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent() {
    bool isCurrentlySearching = _searchController.text.isNotEmpty;

    if (isCurrentlySearching &&
        _filteredTanamanList.isEmpty &&
        !_isSearching &&
        !_isLoadingMoreSearch) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Jenis tanaman tidak ditemukan.")));
    }

    if (!isCurrentlySearching &&
        _tanamanList.isEmpty &&
        !_isInitialLoading &&
        !_isLoadingMore &&
        !_hasNextPage) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Tidak ada jenis tanaman yang tersedia.")));
    }

    if (_filteredTanamanList.isEmpty &&
        (_isInitialLoading ||
            _isLoadingMore ||
            _isLoadingMoreSearch ||
            _isSearching)) {
      return const SizedBox(
          height: 200, child: Center(child: Text("Memuat data...")));
    }

    if (_filteredTanamanList.isEmpty &&
        !isCurrentlySearching &&
        !_isInitialLoading &&
        !_isLoadingMore) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Tidak ada jenis tanaman.")));
    }

    return ListItem(
      title: 'Daftar Jenis Tanaman',
      items: _filteredTanamanList.map((item) {
        return {
          'name': item['nama'] ?? 'N/A',
          'icon': item['gambar'] as String? ?? '',
          'id': item['id'],
          'isActive': item['status'] ?? true,
        };
      }).toList(),
      type: 'basic',
      onItemTap: (context, item) {
        final id = item['id'] as String?;
        if (id != null && id.isNotEmpty) {
          context.push('/detail-tanaman/$id').then((_) {
            _loadInitialData(isRefresh: true);
          });
        }
      },
    );
  }
}
