import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/grade/add_grade_screen.dart';
import 'package:smart_farming_app/service/grade_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  final GradeService _gradeService = GradeService();
  List<dynamic> gradeList = [];

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
    _fetchGradeData(page: 1, isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoadingMore &&
          _currentPage < _totalPages) {
        _fetchGradeData(
            page: _currentPage + 1,
            query: _searchQuery.isEmpty ? null : _searchQuery);
      }
    });
  }

  Future<void> _fetchGradeData(
      {required int page, bool isRefresh = false, String? query}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
        gradeList = [];
        _currentPage = 1;
        _totalPages = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final response = await _gradeService.getPagedGrades(
        page: page,
        limit: _limit,
        searchQuery: query,
      );

      if (!mounted) return;

      if (response['status'] == true) {
        final List<dynamic> newItems = response['data'] ?? [];
        setState(() {
          if (isRefresh) {
            gradeList = newItems;
          } else {
            gradeList.addAll(newItems);
          }
          _currentPage = response['currentPage'] ?? 1;
          _totalPages = response['totalPages'] ?? 1;
        });
      } else {
        if (mounted) {
          showAppToast(context, response['message'] ?? 'Gagal memuat data');
        }
      }
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
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
    _fetchGradeData(
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
    await _fetchGradeData(
        page: 1,
        isRefresh: true,
        query: _searchQuery.isEmpty ? null : _searchQuery);
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
                title: 'Manajemen Grade Hasil Panen',
                greeting: 'Daftar Grade Hasil Panen')),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          key: const Key('add_grade_button'),
          onPressed: () {
            context.push('/tambah-grade',
                extra: AddGradeScreen(
                  isUpdate: false,
                  onGradeAdded: () => _fetchGradeData(
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
                controller: searchController,
                hintText: "Cari nama grade hasil panen...",
                onChanged: _onSearchQueryChanged,
                key: const Key('search_grade_input'),
              ),
              const SizedBox(height: 16),
              Text('Daftar Grade Hasil Panen',
                  style: bold18.copyWith(color: dark1)),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading && gradeList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        color: green1,
                        backgroundColor: white,
                        child: gradeList.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada data grade hasil panen ditemukan',
                                  style: medium14.copyWith(color: dark2),
                                  key: const Key('no_data_message'),
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    gradeList.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= gradeList.length &&
                                      _isLoadingMore) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  if (index >= gradeList.length) {
                                    return const SizedBox.shrink();
                                  }

                                  final grade = gradeList[index];
                                  if (grade is! Map<String, dynamic>) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: UnitItem(
                                      key: Key('grade_item_${grade['id']}'),
                                      unitName:
                                          grade['nama']?.toString() ?? 'N/A',
                                      unitDescription:
                                          grade['deskripsi']?.toString() ??
                                              'Tidak ada deskripsi',
                                      onEdit: () {
                                        context.push('/tambah-grade',
                                            extra: AddGradeScreen(
                                                isUpdate: true,
                                                id: grade['id']?.toString() ??
                                                    '',
                                                nama: grade['nama']
                                                        ?.toString() ??
                                                    '',
                                                deskripsi: grade['deskripsi']
                                                        ?.toString() ??
                                                    '',
                                                onGradeAdded: () =>
                                                    _fetchGradeData(
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
                                                    'Apakah Anda yakin ingin menghapus grade "${grade['nama']}"?'),
                                                actions: [
                                                  TextButton(
                                                    key: const Key(
                                                        'cancel_button'),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    key: const Key(
                                                        'delete_button'),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      final response =
                                                          await _gradeService
                                                              .deleteGrade(grade[
                                                                      'id']!
                                                                  .toString());
                                                      if (!mounted) return;
                                                      if (response['status'] ==
                                                          true) {
                                                        showAppToast(context,
                                                            "Data grade hasil panen berhasil dihapus",
                                                            isError: false);
                                                        _fetchGradeData(
                                                            page: 1,
                                                            isRefresh: true,
                                                            query: _searchQuery
                                                                    .isEmpty
                                                                ? null
                                                                : _searchQuery);
                                                      } else {
                                                        showAppToast(
                                                            context,
                                                            response[
                                                                    'message'] ??
                                                                'Gagal menghapus data grade hasil panen');
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
