import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class TernakScreen extends StatefulWidget {
  const TernakScreen({super.key});

  @override
  State<TernakScreen> createState() => _TernakScreenState();
}

class _TernakScreenState extends State<TernakScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();

  List<dynamic> _ternakList = [];
  List<dynamic> _filteredTernakList = [];

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

    _currentPage = 1;
    _hasNextPage = true;
    if (isRefresh) {
      _ternakList.clear();
      _filteredTernakList.clear();
    }

    await _fetchDataPage(page: 1, isInitialSetupOrRefresh: true);

    if (mounted) {
      setState(() {
        _isInitialLoading = false;
        if (_searchController.text.isEmpty) {
          _filteredTernakList = List.from(_ternakList);
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
        'hewan',
        page: page,
        limit: _pageSize,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          if (isInitialSetupOrRefresh) _isInitialLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memuat data: ${e.toString()}'),
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

        if (isInitialSetupOrRefresh || page == 1) _ternakList.clear();
        _ternakList.addAll(fetchedData);
        _hasNextPage = currentPageFromServer < totalPages;
        _isLoadingMore = false;

        if (_searchController.text.isEmpty) {
          _filteredTernakList = List.from(_ternakList);
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
      _searchTernak(query, isNewSearch: true);
    });
  }

  Future<void> _searchTernak(String query, {bool isNewSearch = false}) async {
    final String normalizedQuery = query.toLowerCase().trim();

    if (isNewSearch) {
      if (normalizedQuery.isEmpty) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _filteredTernakList = List.from(_ternakList);
            _currentSearchPage = 1;
            _hasNextSearchPage = true;
          });
        }
        return;
      }
      setState(() {
        _isSearching = true;
        _filteredTernakList.clear();
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
        'hewan',
        page: _currentSearchPage,
        limit: _pageSize,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isLoadingMoreSearch = false;
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
        _isLoadingMoreSearch = false;
        final List<dynamic> fetchedData =
            List<dynamic>.from(response['data'] ?? []);
        final int totalPages = response['totalPages'] ?? 0;
        final int currentPageFromServer =
            response['currentPage'] ?? _currentSearchPage;

        if (response['status'] == true) {
          _filteredTernakList.addAll(fetchedData);
          _hasNextSearchPage = currentPageFromServer < totalPages;
        } else {
          if (isNewSearch) _filteredTernakList.clear();
          _hasNextSearchPage = false;
        }
      });
    }
  }

  Future<void> _fetchMoreSearchResults({required int page}) async {
    if (_searchController.text.isNotEmpty) {
      await _searchTernak(_searchController.text, isNewSearch: false);
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
            title: 'Manajemen Ternak',
            greeting: 'Daftar Ternak',
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            void handleTernakUpdate() {
              _handleRefresh();
            }

            context.push('/tambah-ternak',
                extra: AddTernakScreen(
                  isEdit: false,
                  onTernakAdded: handleTernakUpdate,
                ));
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
                  hintText: 'Cari ternak berdasarkan nama',
                  controller: _searchController,
                  onChanged: _onSearchChanged),
            ),
            const SizedBox(height: 10),
            if (_isInitialLoading &&
                _filteredTernakList.isEmpty &&
                !_isSearching)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_isSearching && _filteredTernakList.isEmpty)
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
        _filteredTernakList.isEmpty &&
        !_isSearching &&
        !_isLoadingMoreSearch) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Ternak tidak ditemukan.")));
    }

    if (!isCurrentlySearching &&
        _ternakList.isEmpty &&
        !_isInitialLoading &&
        !_isLoadingMore &&
        !_hasNextPage) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Tidak ada ternak yang tersedia.")));
    }

    if (_filteredTernakList.isEmpty &&
        (_isInitialLoading ||
            _isLoadingMore ||
            _isLoadingMoreSearch ||
            _isSearching)) {
      return const SizedBox(
          height: 200, child: Center(child: Text("Memuat data...")));
    }

    if (_filteredTernakList.isEmpty &&
        !isCurrentlySearching &&
        !_isInitialLoading &&
        !_isLoadingMore) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0), child: Text("Tidak ada ternak.")));
    }

    return ListItem(
      title: 'Daftar Ternak',
      items: _filteredTernakList.map((item) {
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
          context.push('/detail-ternak/$id').then((_) {
            _loadInitialData(isRefresh: true);
          });
        }
      },
    );
  }
}
