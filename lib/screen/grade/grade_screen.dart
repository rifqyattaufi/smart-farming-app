import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:smart_farming_app/screen/grade/add_grade_screen.dart';
import 'package:smart_farming_app/service/grade_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';
import 'package:smart_farming_app/widget/unit_item.dart';

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
        _showError(response['message']?.toString() ??
            'Gagal memuat data grade hasil panen');
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
    _fetchGradeData(
        page: 1,
        isRefresh: true,
        query: _searchQuery.isEmpty ? null : _searchQuery);
  }

  void _onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_searchQuery != query.trim()) {
        _performSearch(query.trim());
      }
    });
  }

  Future<void> _refreshData() async {
    await _fetchGradeData(
        page: 1,
        isRefresh: true,
        query: _searchQuery.isEmpty ? null : _searchQuery);
  }

  void _showError(String message, {bool isError = true}) {
    if (mounted) {
      toastification.show(
        context: context,
        title: Text(message),
        type: isError ? ToastificationType.error : ToastificationType.success,
        style: ToastificationStyle.flatColored,
        autoCloseDuration: const Duration(seconds: 4),
      );
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
                title: 'Manajemen Grade Hasil Panen',
                greeting: 'Daftar Grade Hasil Panen')),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            context.push('/tambah-grade',
                extra: AddGradeScreen(
                  isUpdate: false,
                  onGradeAdded: () => _fetchGradeData(page: 1, isRefresh: true),
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
                                                nama:
                                                    grade['nama']?.toString() ??
                                                        '',
                                                deskripsi: grade['deskripsi']
                                                        ?.toString() ??
                                                    '',
                                                onGradeAdded: () =>
                                                    _fetchGradeData(
                                                        page: 1,
                                                        isRefresh: true)));
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
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
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
                                                        _showError(
                                                            "data grade hasil panen berhasil dihapus",
                                                            isError: false);
                                                        _fetchGradeData(
                                                            page: 1,
                                                            isRefresh: true);
                                                      } else {
                                                        _showError(response[
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
