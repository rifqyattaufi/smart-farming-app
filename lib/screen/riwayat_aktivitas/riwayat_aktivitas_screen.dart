import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/dashboard_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/utils/detail_laporan_redirect.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/newest.dart';

class RiwayatAktivitasScreen extends StatefulWidget {
  const RiwayatAktivitasScreen({super.key});

  @override
  State<RiwayatAktivitasScreen> createState() => _RiwayatAktivitasScreenState();
}

class _RiwayatAktivitasScreenState extends State<RiwayatAktivitasScreen> {
  final DashboardService _dashboardService = DashboardService();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isFetchingMore = false;

  List<Map<String, dynamic>> _allActivities = [];
  int _currentPage = 1;
  int _totalPages = 1;
  static const int _defaultLimit = 10;

  @override
  void initState() {
    super.initState();
    _fetchData(page: _currentPage, isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMore &&
          _currentPage < _totalPages) {
        _fetchData(page: _currentPage + 1);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData({required int page, bool isRefresh = false}) async {
    if (isRefresh) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _allActivities.clear();
          _currentPage = 1;
        });
      }
    } else {
      if (_isFetchingMore || !mounted) {
        return;
      }
      setState(() {
        _isFetchingMore = true;
      });
    }

    try {
      final Map<String, dynamic> response = await _dashboardService
          .riwayatAktivitasAll(page: page, limit: _defaultLimit);

      if (mounted) {
        final List<dynamic> newRawActivities =
            response['data']?['aktivitasTerbaru'] as List<dynamic>? ?? [];
        final List<Map<String, dynamic>> newActivities =
            newRawActivities.whereType<Map<String, dynamic>>().toList();

        final paginationData = response['pagination'] as Map<String, dynamic>?;

        setState(() {
          if (isRefresh) {
            _allActivities = newActivities;
          } else {
            _allActivities.addAll(newActivities);
          }
          _currentPage = paginationData?['currentPage'] as int? ?? _currentPage;
          _totalPages = paginationData?['totalPages'] as int? ?? _totalPages;

          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchData(page: 1, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reportItems = _allActivities
        .map((aktivitas) {
          return {
            'text': aktivitas['judul'] as String? ?? '-',
            'id': aktivitas['id'] as String?,
            'time': aktivitas['createdAt'] as String?,
            'icon': aktivitas['userAvatarUrl'] as String? ?? '-',
            'tipe': aktivitas['tipe'] as String? ?? '-',
            'jenisBudidaya': aktivitas['jenisBudidayaTipe'] as String? ?? '-',
          };
        })
        .where((item) => item.containsKey('id') && item['id'] != null)
        .toList();

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
            title: 'Menu Aplikasi',
            greeting: 'Riwayat Aktivitas Pelaporan',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading && _allActivities.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _handleRefresh,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            reportItems.length + (_isFetchingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == reportItems.length && _isFetchingMore) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (index >= reportItems.length) {
                            return const SizedBox.shrink();
                          }
                          if (index == 0) {
                            return NewestReports(
                              key: const Key('riwayat_aktivitas_reports'),
                              title: 'Semua Aktivitas Pelaporan',
                              reports: reportItems,
                              onItemTap: (context, item) {
                                final String? itemId = item['id']?.toString();
                                if (itemId != null &&
                                    itemId.isNotEmpty &&
                                    itemId != '-') {
                                  navigateToDetailLaporan(context,
                                      idLaporan: item['id'],
                                      jenisLaporan: item['tipe'],
                                      jenisBudidaya: item['jenisBudidaya']);
                                } else {
                                  showAppToast(
                                    context,
                                    'ID laporan tidak valid. Silakan coba lagi.',
                                  );
                                }
                              },
                              mode: NewestReportsMode.full,
                              titleTextStyle: bold18.copyWith(color: dark1),
                              reportTextStyle: medium12.copyWith(color: dark1),
                              timeTextStyle: regular12.copyWith(color: dark2),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
