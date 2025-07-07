import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/kategory_inv/add_kategori_inv_screen.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

class KategoriInvScreen extends StatefulWidget {
  const KategoriInvScreen({super.key});

  @override
  State<KategoriInvScreen> createState() => _KategoriInvScreenState();
}

class _KategoriInvScreenState extends State<KategoriInvScreen> {
  final KategoriInvService _kategoriInvService = KategoriInvService();
  List<dynamic> kategoriInvList = [];

  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
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
    _fetchKategoriInv(page: 1, isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore &&
          _currentPage < _totalPages) {
        _fetchKategoriInv(
            page: _currentPage + 1,
            query: _searchQuery.isEmpty ? null : _searchQuery);
      }
    });
  }

  Future<void> _fetchKategoriInv(
      {required int page, bool isRefresh = false, String? query}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        kategoriInvList = [];
        _currentPage = 1;
        _totalPages = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _kategoriInvService.getKategoriInventaris(
        page: page,
        limit: _limit,
        searchQuery: query,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final List<dynamic> newItems = response['data'] ?? [];
        setState(() {
          if (isRefresh) {
            kategoriInvList = newItems;
          } else {
            kategoriInvList.addAll(newItems);
          }
          _currentPage = response['currentPage'] ?? 1;
          _totalPages = response['totalPages'] ?? 1;
        });
      } else {
        _showError(response['message']?.toString() ??
            'Gagal memuat data kategori inventaris');
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
    _fetchKategoriInv(
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
    await _fetchKategoriInv(
        page: 1,
        isRefresh: true,
        query: _searchQuery.isEmpty ? null : _searchQuery);
  }

  void _showError(String message, {bool isError = true}) {
    if (mounted) {
      showAppToast(context, message,
          title: isError ? 'Error' : 'Success', isError: isError);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
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
              title: 'Manajemen Inventaris',
              greeting: 'Daftar Kategori Inventaris'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          key: const Key('add_kategori_inventaris'),
          onPressed: () {
            context.push('/tambah-kategori-inventaris',
                extra: AddKategoriInvScreen(
                  isUpdate: false,
                  onKategoriInvAdded: () => _fetchKategoriInv(
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
                key: const Key('search_kategori_inventaris'),
                controller: searchController,
                hintText: "Cari nama kategori inventaris...",
                onChanged: _onSearchQueryChanged,
              ),
              const SizedBox(height: 16),
              Text('Daftar Kategori', style: bold18.copyWith(color: dark1)),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading && kategoriInvList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: green1,
                        backgroundColor: white,
                        child: kategoriInvList.isEmpty
                            ? Center(
                                child: Text(
                                  key: const Key('no_data_kategori_inventaris'),
                                  'Tidak ada data kategori inventaris ditemukan.',
                                  style: medium14.copyWith(color: dark2),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: kategoriInvList.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= kategoriInvList.length &&
                                      _isLoadingMore) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  if (index >= kategoriInvList.length) {
                                    return const SizedBox.shrink();
                                  }

                                  final kategori = kategoriInvList[index];
                                  if (kategori is! Map<String, dynamic>) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: UnitItem(
                                      key: Key(
                                          'kategori_inv_item_${kategori['id']}'),
                                      unitName:
                                          kategori['nama']?.toString() ?? 'N/A',
                                      onEdit: () {
                                        context.push(
                                            '/tambah-kategori-inventaris',
                                            extra: AddKategoriInvScreen(
                                                isUpdate: true,
                                                id: kategori[
                                                            'id']
                                                        ?.toString() ??
                                                    '',
                                                nama: kategori['nama']
                                                        ?.toString() ??
                                                    '',
                                                onKategoriInvAdded: () =>
                                                    _fetchKategoriInv(
                                                        page: 1,
                                                        isRefresh: true,
                                                        query: _searchQuery
                                                                .isEmpty
                                                            ? null
                                                            : _searchQuery)));
                                      },
                                      onDelete: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Konfirmasi Hapus'),
                                                content: Text(
                                                    'Apakah Anda yakin ingin menghapus kategori "${kategori['nama']}"?'),
                                                actions: [
                                                  TextButton(
                                                    key: const Key(
                                                        'cancel_delete_kategori'),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    key: const Key(
                                                        'confirm_delete_kategori'),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      final response =
                                                          await _kategoriInvService
                                                              .deleteKategoriInventaris(
                                                                  kategori[
                                                                          'id']!
                                                                      .toString());
                                                      if (!mounted) return;
                                                      if (response['status'] ==
                                                          true) {
                                                        _showError(
                                                            "Kategori inventaris berhasil dihapus.",
                                                            isError: false);
                                                        _fetchKategoriInv(
                                                            page: 1,
                                                            isRefresh: true,
                                                            query: _searchQuery
                                                                    .isEmpty
                                                                ? null
                                                                : _searchQuery);
                                                      } else {
                                                        _showError(response[
                                                                'message'] ??
                                                            'Gagal menghapus kategori inventaris');
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
