import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/satuan/add_satuan_screen.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

class SatuanScreen extends StatefulWidget {
  const SatuanScreen({super.key});

  @override
  State<SatuanScreen> createState() => _SatuanScreenState();
}

class _SatuanScreenState extends State<SatuanScreen> {
  final SatuanService _satuanService = SatuanService();
  List<dynamic> _allSatuanList = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce;

  bool _isLoading = true;
  bool _isLoadingMore = false;

  int _currentPage = 1;
  int _totalPages = 1;
  final int _limit = 15;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSatuanData(page: 1, isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore &&
          _currentPage < _totalPages) {
        _fetchSatuanData(
            page: _currentPage + 1,
            query: _searchQuery.isEmpty ? null : _searchQuery);
      }
    });
  }

  Future<void> _fetchSatuanData(
      {required int page, bool isRefresh = false, String? query}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        _allSatuanList = [];
        _currentPage = 1;
        _totalPages = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _satuanService.getSatuan(
        page: page,
        limit: _limit,
        searchQuery: query,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final List<dynamic> newItems = response['data'] ?? [];
        setState(() {
          if (isRefresh) {
            _allSatuanList = newItems;
          } else {
            _allSatuanList.addAll(newItems);
          }
          _currentPage = response['currentPage'] ?? 1;
          _totalPages = response['totalPages'] ?? 1;
        });
      } else {
        _showError(
            response['message']?.toString() ?? 'Gagal memuat data satuan');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _performSearch(String query) {
    if (_searchQuery == query && !_isLoading) {
      return;
    }

    _searchQuery = query;
    _fetchSatuanData(
        page: 1,
        isRefresh: true,
        query: _searchQuery.isEmpty ? null : _searchQuery);
  }

  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final trimmedQuery = query.trim();
      if (_searchQuery != trimmedQuery) {
        _performSearch(trimmedQuery);
      }
    });
  }

  Future<void> _refreshData() async {
    await _fetchSatuanData(
        page: 1,
        isRefresh: true,
        query: _searchQuery.isEmpty ? null : _searchQuery);
  }

  void _showError(String message, {bool isError = true}) {
    if (mounted) {
      showAppToast(
        context,
        message,
        isError: isError,
      );
    }
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
          surfaceTintColor: white,
          scrolledUnderElevation: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Pengaturan Lainnya',
              greeting: 'Manajemen Satuan'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          key: const Key('add_satuan_fab'),
          onPressed: () {
            context.push('/tambah-satuan',
                extra: AddSatuanScreen(
                  isUpdate: false,
                  onSatuanAdded: () => _fetchSatuanData(
                      page: 1,
                      isRefresh: true,
                      query: _searchQuery.isEmpty ? null : _searchQuery),
                ));
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchField(
                key: const Key('satuan_search_field'),
                controller: _searchController,
                hintText: "Cari nama atau lambang satuan...",
                onChanged: _onSearchQueryChanged,
              ),
              const SizedBox(height: 16),
              Text('Daftar Satuan', style: bold18.copyWith(color: dark1)),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading && _allSatuanList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: green1,
                        backgroundColor: white,
                        child: _allSatuanList.isEmpty
                            ? Center(
                                child: Text(
                                  key: const Key('no_data_message'),
                                  'Tidak ada data satuan ditemukan.',
                                  style: medium14.copyWith(color: dark2),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _allSatuanList.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _allSatuanList.length &&
                                      _isLoadingMore) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  if (index >= _allSatuanList.length) {
                                    return const SizedBox.shrink();
                                  }

                                  final satuan = _allSatuanList[index];
                                  if (satuan is! Map<String, dynamic>) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: UnitItem(
                                      key: Key('satuan_item_${satuan['id']}'),
                                      unitName:
                                          satuan['nama']?.toString() ?? 'N/A',
                                      unitSymbol:
                                          satuan['lambang']?.toString() ??
                                              'N/A',
                                      onEdit: () {
                                        context.push('/tambah-satuan',
                                            extra: AddSatuanScreen(
                                              isUpdate: true,
                                              id: satuan['id']?.toString() ??
                                                  '',
                                              nama:
                                                  satuan['nama']?.toString() ??
                                                      '',
                                              lambang: satuan['lambang']
                                                      ?.toString() ??
                                                  '',
                                              onSatuanAdded: () =>
                                                  _fetchSatuanData(
                                                      page: 1,
                                                      isRefresh: true,
                                                      query:
                                                          _searchQuery.isEmpty
                                                              ? null
                                                              : _searchQuery),
                                            ));
                                      },
                                      onDelete: () {
                                        showDialog(
                                            context: context,
                                            builder: (dialogContext) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Konfirmasi Hapus'),
                                                content: Text(
                                                    'Apakah Anda yakin ingin menghapus satuan "${satuan['nama']}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                                dialogContext)
                                                            .pop(),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      Navigator.of(
                                                              dialogContext)
                                                          .pop();
                                                      final response =
                                                          await _satuanService
                                                              .deleteSatuan(
                                                                  satuan['id']!
                                                                      .toString());
                                                      if (!mounted) return;
                                                      if (response['status'] ==
                                                          true) {
                                                        _showError(
                                                            "Satuan berhasil dihapus",
                                                            isError: false);
                                                        _fetchSatuanData(
                                                            page: 1,
                                                            isRefresh: true,
                                                            query: _searchQuery
                                                                    .isEmpty
                                                                ? null
                                                                : _searchQuery);
                                                      } else {
                                                        _showError(response[
                                                                'message'] ??
                                                            'Gagal menghapus satuan');
                                                      }
                                                    },
                                                    child: const Text('Hapus',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
