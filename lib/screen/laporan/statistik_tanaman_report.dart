import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/service/report_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/utils/custom_picker_utils.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/harian.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/info.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/panen.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/sakit.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/nutrisi.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/mati.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';

class StatistikTanamanReport extends StatefulWidget {
  final String? idTanaman;

  const StatistikTanamanReport({super.key, this.idTanaman});

  @override
  State<StatistikTanamanReport> createState() => _StatistikTanamanReportState();
}

class _StatistikTanamanReportState extends State<StatistikTanamanReport> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ReportService _reportService = ReportService();
  final LaporanService _laporanService = LaporanService();

  Map<String, dynamic>? _tanamanReport;
  List<dynamic> _kebunList = [];
  int _jumlahTanaman = 0;
  bool _isLoadingInitialData = true;

  // State untuk Statistik Harian (Overview Card)
  Map<String, dynamic>? _statistikHarianData;
  // ignore: unused_field
  bool _isLoadingStatistikHarian = true;
  String? _statistikHarianErrorMessage;

  // --- Unified State for Charts and Riwayat ---
  final Map<String, ChartDataState<List<dynamic>>> _chartStates = {
    'laporanHarian': ChartDataState<List<dynamic>>(),
    'penyiraman': ChartDataState<List<dynamic>>(),
    'pruning': ChartDataState<List<dynamic>>(),
    'repotting': ChartDataState<List<dynamic>>(),
    'nutrisi': ChartDataState<List<dynamic>>(),
    'laporanSakit': ChartDataState<List<dynamic>>(),
    'laporanMati': ChartDataState<List<dynamic>>(),
    'statistikPenyakit': ChartDataState<List<dynamic>>(),
    'statistikPenyebabKematian': ChartDataState<List<dynamic>>(),
    'laporanNutrisi': ChartDataState<List<dynamic>>(),
    'laporanVitamin': ChartDataState<List<dynamic>>(),
    'laporanDisinfektan': ChartDataState<List<dynamic>>(),
    'laporanPanen': ChartDataState<List<dynamic>>(),
    'panenKomoditas': ChartDataState<List<dynamic>>(),
    'panenGrade': ChartDataState<List<dynamic>>(),
  };

  final Map<String, RiwayatDataState<List<dynamic>>> _riwayatStates = {
    'umum': RiwayatDataState<List<dynamic>>(),
    'pupuk': RiwayatDataState<List<dynamic>>(),
    'sakit': RiwayatDataState<List<dynamic>>(),
    'mati': RiwayatDataState<List<dynamic>>(),
    'nutrisi': RiwayatDataState<List<dynamic>>(),
    'panen': RiwayatDataState<List<dynamic>>(),
  };
  // --- End Unified State ---

  ChartFilterType _selectedChartFilterType = ChartFilterType.weekly;
  DateTimeRange? _selectedChartDateRange;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.idTanaman == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAppToast(
          context,
          'ID Tanaman tidak ditemukan',
        );
        context.pop();
      });
      return;
    }

    final now = DateTime.now();
    _selectedChartDateRange =
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
    _fetchInitialDataAndDependencies();
  }

  // Helper function to safely extract numeric values from dynamic data
  num _safeNumericValue(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _fetchInitialDataAndDependencies() async {
    await _fetchInitialData();
    if (widget.idTanaman != null && mounted && _tanamanReport != null) {
      // Fetch data that depends on initial data or idTanaman
      await _fetchStatistikHarian(); // Statistik harian card data
      await _fetchAllReportsAndHistoriesData(); // All charts and history lists
    }
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingInitialData = true);
    try {
      if (widget.idTanaman == null) {
        showAppToast(context, 'ID Tanaman tidak ditemukan');
        if (mounted) setState(() => _isLoadingInitialData = false);
        return;
      }

      final response =
          await _jenisBudidayaService.getJenisBudidayaById(widget.idTanaman!);

      if (mounted) {
        if (response.containsKey('status') &&
            response['status'] == true &&
            response.containsKey('data')) {
          final responseData = response['data'] as Map<String, dynamic>?;
          if (responseData != null &&
              responseData.containsKey('jenisBudidaya') &&
              responseData.containsKey('unitBudidaya')) {
            final jenisBudidayaDetailData =
                responseData['jenisBudidaya'] as Map<String, dynamic>?;
            final unitBudidayaRawList =
                responseData['unitBudidaya'] as List<dynamic>?;

            if (jenisBudidayaDetailData != null &&
                unitBudidayaRawList != null) {
              int totalJumlahObjekBudidayaDariResponse = 0;
              if (responseData.containsKey('jumlahBudidaya') &&
                  responseData['jumlahBudidaya'] is int) {
                totalJumlahObjekBudidayaDariResponse =
                    responseData['jumlahBudidaya'] as int;
              } else {
                for (var unitKebun in unitBudidayaRawList) {
                  final kebunMap = unitKebun as Map<String, dynamic>?;
                  if (kebunMap != null &&
                      kebunMap.containsKey('ObjekBudidayas') &&
                      kebunMap['ObjekBudidayas'] is List) {
                    totalJumlahObjekBudidayaDariResponse +=
                        (kebunMap['ObjekBudidayas'] as List).length;
                  }
                }
              }
              setState(() {
                _tanamanReport = jenisBudidayaDetailData;
                _kebunList = unitBudidayaRawList;
                _jumlahTanaman = totalJumlahObjekBudidayaDariResponse;
              });
            } else {
              showAppToast(context,
                  'Data detail jenis budidaya atau unit budidaya tidak lengkap');
            }
          } else {
            showAppToast(context,
                'Struktur data utama (jenisBudidaya / unitBudidaya) tidak ditemukan');
          }
        } else {
          showAppToast(context, response['message'] ?? 'Gagal memuat data');
        }
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) setState(() => _isLoadingInitialData = false);
    }
  }

  Future<void> _fetchStatistikHarian() async {
    if (widget.idTanaman == null || !mounted) return;
    setState(() {
      _isLoadingStatistikHarian = true;
      _statistikHarianErrorMessage = null;
    });
    try {
      final response = await _reportService
          .getStatistikHarianJenisBudidaya(widget.idTanaman!);
      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() =>
              _statistikHarianData = response['data'] as Map<String, dynamic>);
        } else {
          setState(() => _statistikHarianErrorMessage =
              response['message'] as String? ??
                  'Gagal memuat statistik harian.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statistikHarianErrorMessage =
            'Terjadi kesalahan: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoadingStatistikHarian = false);
    }
  }

  Map<String, dynamic> _processBackendChartData({
    required List<dynamic> rawBackendData,
    required ChartFilterType filterType,
    required DateTimeRange selectedDateRange,
    required String valueKey,
  }) {
    List<Map<String, dynamic>> processedDataPoints = [];
    List<String> processedXLabels = [];
    DateTime startDate = selectedDateRange.start;
    DateTime endDate = selectedDateRange.end;
    Map<String, Map<String, dynamic>> backendDataMap = {
      for (var item in rawBackendData.whereType<Map<String, dynamic>>())
        if (item['period'] != null) item['period'].toString(): item
    };

    if (filterType == ChartFilterType.weekly ||
        filterType == ChartFilterType.custom) {
      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        final String periodKey = DateFormat('yyyy-MM-dd').format(currentDate);
        final String displayLabel = DateFormat('dd').format(currentDate);
        final backendEntry = backendDataMap[periodKey];
        processedDataPoints.add({
          'period': periodKey,
          valueKey: backendEntry != null
              ? _safeNumericValue(backendEntry[valueKey])
              : 0
        });
        processedXLabels.add(displayLabel);
        currentDate = currentDate.add(const Duration(days: 1));
        if (processedXLabels.length > 14 &&
            filterType == ChartFilterType.weekly) {
          break;
        }
      }
    } else if (filterType == ChartFilterType.monthly) {
      DateTime currentDate = DateTime(startDate.year, startDate.month, 1);
      DateTime loopEndDate = DateTime(endDate.year, endDate.month,
          DateTime(endDate.year, endDate.month + 1, 0).day);
      while (!currentDate.isAfter(loopEndDate)) {
        final String periodKey = DateFormat('yyyy-MM-01').format(currentDate);
        final String displayLabel = DateFormat('MMM yy').format(currentDate);
        final backendEntry = backendDataMap[periodKey];
        processedDataPoints.add({
          'period': periodKey,
          valueKey: backendEntry != null
              ? _safeNumericValue(backendEntry[valueKey])
              : 0
        });
        processedXLabels.add(displayLabel);
        currentDate = (currentDate.month == 12)
            ? DateTime(currentDate.year + 1, 1, 1)
            : DateTime(currentDate.year, currentDate.month + 1, 1);
        if (processedXLabels.length > 24) break;
      }
    } else if (filterType == ChartFilterType.yearly) {
      DateTime currentDate = DateTime(startDate.year, 1, 1);
      DateTime loopEndDate = DateTime(endDate.year, 12, 31);
      while (!currentDate.isAfter(loopEndDate)) {
        final String periodKey = DateFormat('yyyy-01-01').format(currentDate);
        final String displayLabel = DateFormat('yyyy').format(currentDate);
        final backendEntry = backendDataMap[periodKey];
        processedDataPoints.add({
          'period': periodKey,
          valueKey: backendEntry != null
              ? _safeNumericValue(backendEntry[valueKey])
              : 0
        });
        processedXLabels.add(displayLabel);
        currentDate = DateTime(currentDate.year + 1, 1, 1);
        if (processedXLabels.length > 10) break;
      }
    }
    return {'points': processedDataPoints, 'labels': processedXLabels};
  }

  Future<void> _fetchAndProcessChartData({
    required String chartKey,
    required String valueKey,
    required Future<Map<String, dynamic>> Function(
            String groupBy, DateTime start, DateTime end)
        fetchFunction,
    required String groupBy,
    String? defaultErrorMessage,
  }) async {
    if (!mounted ||
        widget.idTanaman == null ||
        _selectedChartDateRange == null) {
      return;
    }
    setState(() => _chartStates[chartKey]?.setLoading());
    try {
      final response = await fetchFunction(groupBy,
          _selectedChartDateRange!.start, _selectedChartDateRange!.end);
      if (mounted) {
        if (response['status'] == true) {
          final processed = _processBackendChartData(
            rawBackendData: response['data'] as List<dynamic>? ?? [],
            filterType: _selectedChartFilterType,
            selectedDateRange: _selectedChartDateRange!,
            valueKey: valueKey,
          );
          // Ensure XLabels for other charts align with laporanHarian if available
          List<String> finalXLabels = processed['labels'];
          if (chartKey != 'laporanHarian' &&
              chartKey != 'laporanSakit' &&
              chartKey != 'laporanMati' &&
              chartKey != 'laporanNutrisi' &&
              chartKey != 'laporanVitamin' &&
              chartKey != 'laporanDisinfektan' &&
              chartKey != 'laporanPanen' &&
              _chartStates['laporanHarian']!.xLabels.isNotEmpty) {
            finalXLabels =
                List<String>.from(_chartStates['laporanHarian']!.xLabels);
          }

          _chartStates[chartKey]?.setData(processed['points'], finalXLabels,
              response['data'] as List<dynamic>?);
        } else {
          _chartStates[chartKey]?.setError(response['message'] as String? ??
              defaultErrorMessage ??
              'Gagal memuat data chart.');
        }
      }
    } catch (e) {
      if (mounted) {
        _chartStates[chartKey]?.setError('Error ($chartKey): ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() {}); // Trigger rebuild after state update
    }
  }

  Future<void> _fetchAndProcessRiwayatData({
    required String riwayatKey,
    required Future<Map<String, dynamic>> Function() fetchFunction,
    String? defaultErrorMessage,
  }) async {
    if (!mounted || widget.idTanaman == null) return;
    setState(() => _riwayatStates[riwayatKey]?.setLoading());
    try {
      final response = await fetchFunction();
      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          _riwayatStates[riwayatKey]?.setData(
              List<Map<String, dynamic>>.from(response['data']),
              response['data'] as List<dynamic>?);
        } else {
          _riwayatStates[riwayatKey]?.setError(response['message'] as String? ??
              defaultErrorMessage ??
              'Gagal memuat riwayat.');
        }
      }
    } catch (e) {
      if (mounted) {
        _riwayatStates[riwayatKey]
            ?.setError('Error ($riwayatKey): ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() {}); // Trigger rebuild
    }
  }

  Future<void> _fetchAllReportsAndHistoriesData() async {
    if (widget.idTanaman == null ||
        _selectedChartDateRange == null ||
        !mounted) {
      return;
    }

    // Set loading for all
    setState(() {
      _chartStates.forEach((_, state) => state.setLoading());
      _riwayatStates.forEach((_, state) => state.setLoading());
    });

    String groupBy;
    switch (_selectedChartFilterType) {
      case ChartFilterType.monthly:
        groupBy = 'month';
        break;
      case ChartFilterType.yearly:
        groupBy = 'year';
        break;
      default:
        groupBy = 'day';
        break;
    }

    try {
      await Future.wait([
        _fetchAndProcessChartData(
          chartKey: 'laporanHarian',
          valueKey: 'jumlahLaporan',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik laporan harian',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikLaporanHarian(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'laporanSakit',
          valueKey: 'jumlahSakit',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik laporan sakit',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikLaporanSakit(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'statistikPenyakit',
          valueKey: 'jumlahKasus',
          groupBy: 'day',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPenyakit(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end),
        ),
        _fetchAndProcessChartData(
          chartKey: 'statistikPenyebabKematian',
          valueKey: 'jumlahKematian',
          groupBy: 'day',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPenyebabKematian(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end),
        ),
        _fetchAndProcessChartData(
          chartKey: 'laporanMati',
          valueKey: 'jumlahKematian',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik laporan kematian',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikKematian(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'penyiraman',
          valueKey: 'jumlahPenyiraman',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik penyiraman',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPenyiraman(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'pruning',
          valueKey: 'jumlahPruning',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik pruning',
          fetchFunction: (gb, start, end) => _reportService.getStatistikPruning(
              jenisBudidayaId: widget.idTanaman!,
              startDate: start,
              endDate: end,
              groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'repotting',
          valueKey: 'jumlahRepotting',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik repotting',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikRepotting(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'nutrisi',
          valueKey: 'jumlahKejadianPemberianPupuk',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik nutrisi',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPemberianNutrisi(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'laporanVitamin',
          valueKey: 'jumlahPemberianVitamin',
          groupBy: groupBy,
          defaultErrorMessage:
              'Gagal memuat statistik laporan pemberian vitamin',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPemberianVitamin(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'laporanNutrisi',
          valueKey: 'jumlahKejadianPemberianPupuk',
          groupBy: groupBy,
          defaultErrorMessage:
              'Gagal memuat statistik laporan pemberian nutrisi',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPemberianNutrisi(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'laporanDisinfektan',
          valueKey: 'jumlahPemberianDisinfektan',
          groupBy: groupBy,
          defaultErrorMessage:
              'Gagal memuat statistik laporan pemberian disinfektan',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikPemberianDisinfektan(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'laporanPanen',
          valueKey: 'jumlahLaporanPanenTanaman',
          groupBy: groupBy,
          defaultErrorMessage: 'Gagal memuat statistik laporan panen',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikLaporanPanenTanaman(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end,
                  groupBy: gb),
        ),
        _fetchAndProcessChartData(
          chartKey: 'panenKomoditas',
          valueKey: 'totalPanen',
          groupBy: 'day',
          fetchFunction: (gb, start, end) =>
              _reportService.getStatistikJumlahPanenTanaman(
                  jenisBudidayaId: widget.idTanaman!,
                  startDate: start,
                  endDate: end),
        ),
        _fetchPanenGradeData(),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'umum',
            defaultErrorMessage: 'Gagal memuat riwayat pelaporan umum',
            fetchFunction: () => _reportService.getRiwayatLaporanHarianTanaman(
                jenisBudidayaId: widget.idTanaman!, limit: 5, page: 1)),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'sakit',
            defaultErrorMessage: 'Gagal memuat riwayat pelaporan sakit',
            fetchFunction: () =>
                _reportService.getRiwayatLaporanSakitJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!, limit: 3, page: 1)),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'mati',
            defaultErrorMessage: 'Gagal memuat riwayat pelaporan kematian',
            fetchFunction: () =>
                _reportService.getRiwayatLaporanKematianJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!, limit: 5, page: 1)),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'pupuk',
            defaultErrorMessage: 'Gagal memuat riwayat pemberian pupuk',
            fetchFunction: () =>
                _reportService.getRiwayatPemberianNutrisiJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!,
                    limit: 3,
                    page: 1,
                    tipeNutrisi: 'pupuk')),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'nutrisi',
            defaultErrorMessage:
                'Gagal memuat riwayat pelaporan pemberian nutrisi',
            fetchFunction: () =>
                _reportService.getRiwayatPemberianNutrisiJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!,
                    limit: 5,
                    page: 1,
                    tipeNutrisi: 'pupuk,vitamin,disinfektan')),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'panen',
            defaultErrorMessage: 'Gagal memuat riwayat pelaporan panen',
            fetchFunction: () => _reportService.getRiwayatPelaporanPanenTanaman(
                jenisBudidayaId: widget.idTanaman!, limit: 5, page: 1)),
      ]);
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) setState(() {}); // Final rebuild to ensure UI consistency
    }
  }

  Future<void> _showDateFilterDialog() async {
    DateTimeRange? newRange;
    final DateTime now = DateTime.now();
    DateTimeRange currentSafeRange = _selectedChartDateRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);

    if (_selectedChartFilterType == ChartFilterType.weekly ||
        _selectedChartFilterType == ChartFilterType.custom) {
      final DateTime? pickedStartDate = await showDatePicker(
        context: context,
        initialDate: currentSafeRange.start,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 5),
        helpText: 'Pilih Tanggal Mulai',
      );
      if (pickedStartDate != null) {
        newRange = DateTimeRange(
            start: pickedStartDate,
            end: pickedStartDate.add(const Duration(days: 6)));
      }
    } else if (_selectedChartFilterType == ChartFilterType.monthly) {
      newRange = await showCustomMonthRangePicker(context,
          initialRange: currentSafeRange);
    } else if (_selectedChartFilterType == ChartFilterType.yearly) {
      newRange = await showCustomYearRangePicker(context,
          initialRange: currentSafeRange);
    }

    if (newRange != null && newRange != _selectedChartDateRange) {
      setState(() => _selectedChartDateRange = newRange);
      await _fetchAllReportsAndHistoriesData();
    }
  }

  void _handleChartFilterTypeChanged(ChartFilterType? newValue) {
    if (newValue != null && newValue != _selectedChartFilterType) {
      setState(() {
        _selectedChartFilterType = newValue;
        final DateTime now = DateTime.now();
        if (newValue == ChartFilterType.monthly) {
          _selectedChartDateRange = DateTimeRange(
              start: DateTime(now.year, now.month - 5, 1),
              end: DateTime(now.year, now.month + 1, 0));
        } else if (newValue == ChartFilterType.yearly) {
          _selectedChartDateRange = DateTimeRange(
              start: DateTime(now.year - 4, 1, 1),
              end: DateTime(now.year, 12, 31));
        } else {
          _selectedChartDateRange = DateTimeRange(
              start: now.subtract(const Duration(days: 6)), end: now);
        }
      });
      _fetchAllReportsAndHistoriesData();
    }
  }

  String get formattedDisplayedDateRange {
    if (_selectedChartDateRange == null) return "Pilih rentang tanggal";
    final range = _selectedChartDateRange!;
    String formattedStart, formattedEnd;
    final dfDayMonthYear = DateFormat('d MMM yyyy');
    final dfMonthYear = DateFormat('MMM yyyy');
    final dfYear = DateFormat('yyyy');

    switch (_selectedChartFilterType) {
      case ChartFilterType.weekly:
      case ChartFilterType.custom:
        formattedStart = dfDayMonthYear.format(range.start);
        formattedEnd = dfDayMonthYear.format(range.end);
        if (_selectedChartFilterType == ChartFilterType.custom &&
            range.start.year == range.end.year &&
            range.start.month == range.end.month &&
            range.start.day == range.end.day) {
          return "Penggunaan $formattedStart";
        }
        return "Pelaporan Per $formattedStart - $formattedEnd";
      case ChartFilterType.monthly:
        formattedStart = dfMonthYear.format(range.start);
        formattedEnd = dfMonthYear.format(range.end);
        if (range.start.year == range.end.year &&
            range.start.month == range.end.month) {
          return "Penggunaan Bulan ${dfMonthYear.format(range.start)}";
        }
        return "Pelaporan Per $formattedStart - $formattedEnd";
      case ChartFilterType.yearly:
        formattedStart = dfYear.format(range.start);
        formattedEnd = dfYear.format(range.end);
        if (range.start.year == range.end.year) {
          return "Penggunaan Tahun ${dfYear.format(range.start)}";
        }
        return "Pelaporan Per $formattedStart - $formattedEnd";
    }
  }

  int _selectedTabIndex = 0;
  final List<String> tabList = [
    'Informasi',
    'Panen',
    'Harian',
    'Sakit',
    'Mati',
    'Nutrisi'
  ];
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Map<String, dynamic> _findMinMaxDays(
      List<dynamic> dataPoints, String valueKey) {
    if (dataPoints.isEmpty) {
      return {
        'minValue': 0,
        'maxValue': 0,
        'minDays': <DateTime>[],
        'maxDays': <DateTime>[]
      };
    }

    num minValue = double.infinity;
    num maxValue = double.negativeInfinity;

    for (var item in dataPoints) {
      final value = _safeNumericValue(item[valueKey]);
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    List<DateTime> minDays = [];
    List<DateTime> maxDays = [];

    for (var item in dataPoints) {
      final value = _safeNumericValue(item[valueKey]);
      final date = DateTime.tryParse(item['period'] ?? '');
      if (date == null) continue;

      if (value == minValue) {
        minDays.add(date);
      }
      if (value == maxValue) {
        maxDays.add(date);
      }
    }

    return {
      'minValue': minValue,
      'maxValue': maxValue,
      'minDays': minDays.toSet().toList(),
      'maxDays': maxDays.toSet().toList()
    };
  }

  String _formatConsecutiveDates(List<DateTime> dates) {
    if (dates.isEmpty) return '';

    dates.sort((a, b) => a.compareTo(b));

    // Jika hanya 1 atau 2 tanggal, format sederhana saja
    if (dates.length <= 2) {
      final formatter = DateFormat('d MMMM yyyy');
      return dates.map((d) => formatter.format(d)).join(' & ');
    }

    // Cek Pola Tahunan (misal: 1 Jan 2021, 1 Jan 2022, 1 Jan 2023)
    bool isYearlyConsecutive = true;
    for (int i = 0; i < dates.length - 1; i++) {
      if (dates[i].day != dates[i + 1].day ||
          dates[i].month != dates[i + 1].month ||
          dates[i].year != dates[i + 1].year - 1) {
        isYearlyConsecutive = false;
        break;
      }
    }
    if (isYearlyConsecutive) {
      final startYear = DateFormat('yyyy').format(dates.first);
      final endYear = DateFormat('yyyy').format(dates.last);
      // Tampilkan tanggal lengkap untuk konteks jika hanya rentang tahun
      final fullDateExample = DateFormat('d MMMM').format(dates.first);
      if (startYear == endYear) {
        return DateFormat('d MMMM yyyy').format(dates.first);
      }
      // return "$startYear - $endYear (setiap tanggal $fullDateExample)";
      return "setiap tanggal $fullDateExample dari tahun $startYear - $endYear";
    }

    // Cek Pola Bulanan dalam tahun yang sama (misal: 1 Jan 2025, 1 Feb 2025, 1 Mar 2025)
    bool isMonthlyConsecutive = true;
    for (int i = 0; i < dates.length - 1; i++) {
      DateTime expectedNextMonth =
          DateTime(dates[i].year, dates[i].month + 1, dates[i].day);
      // Normalisasi jika melewati akhir tahun
      if (expectedNextMonth.month != (dates[i].month + 1) % 12) {
        expectedNextMonth = DateTime(dates[i].year + 1, 1, dates[i].day);
      }

      if (dates[i + 1].day != dates[i].day ||
          dates[i + 1].month != expectedNextMonth.month ||
          dates[i + 1].year != expectedNextMonth.year) {
        isMonthlyConsecutive = false;
        break;
      }
    }
    if (isMonthlyConsecutive) {
      final start = dates.first;
      final end = dates.last;
      final dfMonth = DateFormat('MMMM');
      final dfMonthYear = DateFormat('MMMM yyyy');

      if (start.year == end.year) {
        // return "Setiap tanggal ${start.day} dari ${dfMonth.format(start)} - ${dfMonthYear.format(end)}";
        return "${dfMonth.format(start)} - ${dfMonthYear.format(end)} (setiap tanggal ${start.day})";
      } else {
        return "${dfMonthYear.format(start)} - ${dfMonthYear.format(end)} (setiap tanggal ${start.day})";
      }
    }

    // Fallback ke Logika Awal (Harian) jika tidak ada pola tahunan/bulanan
    final List<String> parts = [];
    int i = 0;
    while (i < dates.length) {
      final List<DateTime> sequence = [dates[i]];
      int j = i + 1;
      while (
          j < dates.length && dates[j].difference(dates[j - 1]).inDays == 1) {
        sequence.add(dates[j]);
        j++;
      }

      if (sequence.length >= 3) {
        final start = sequence.first;
        final end = sequence.last;
        final dfDay = DateFormat('d');
        final dfDayMonthYear = DateFormat('d MMMM yyyy');

        if (start.month == end.month && start.year == end.year) {
          parts.add("${dfDay.format(start)} - ${dfDayMonthYear.format(end)}");
        } else if (start.year == end.year) {
          parts.add(
              "${DateFormat('d MMMM').format(start)} - ${dfDayMonthYear.format(end)}");
        } else {
          parts.add(
              "${dfDayMonthYear.format(start)} - ${dfDayMonthYear.format(end)}");
        }
      } else {
        final formatter = DateFormat('d MMMM yyyy');
        parts.addAll(sequence.map((d) => formatter.format(d)));
      }
      i = j;
    }

    return parts.join(' & ');
  }

  String _generateStatistikRangkumanText() {
    if (_selectedChartDateRange == null) {
      return "Silakan pilih rentang tanggal untuk melihat rangkuman statistik.";
    }

    final range = _selectedChartDateRange!;
    final dfDay = DateFormat('d');
    final dfMonthYear = DateFormat('d MMMM yyyy');
    final dfFull = DateFormat('d MMMM yyyy');
    String displayRange;

    if (range.start.year == range.end.year) {
      if (range.start.month == range.end.month) {
        // Contoh: 2 - 8 Juni 2025
        displayRange =
            "${dfDay.format(range.start)} - ${dfMonthYear.format(range.end)}";
      } else {
        // Contoh: 1 Januari - 30 Juni 2025
        displayRange =
            "${DateFormat('d MMMM').format(range.start)} - ${dfFull.format(range.end)}";
      }
    } else {
      // Contoh: 1 Januari 2024 - 30 Juni 2025
      displayRange =
          "${dfFull.format(range.start)} - ${dfFull.format(range.end)}";
    }

    final StringBuffer summary = StringBuffer(
        "Berdasarkan statistik pelaporan pada tanggal $displayRange, ");

    final laporanHarianState = _chartStates['laporanHarian']!;
    if (laporanHarianState.isLoading) {
      return "Memuat rangkuman statistik...";
    }
    if (laporanHarianState.error != null) {
      return "Tidak dapat memuat rangkuman karena terjadi kesalahan pada data laporan harian.";
    }

    // Check if all chart states are empty or have zero values
    final penyiramanState = _chartStates['penyiraman']!;
    final pruningState = _chartStates['pruning']!;
    final repottingState = _chartStates['repotting']!;
    final nutrisiState = _chartStates['nutrisi']!;
    final sakitState = _chartStates['laporanSakit']!;
    final matiState = _chartStates['laporanMati']!;
    final vitaminState = _chartStates['laporanVitamin']!;
    final pupukState = _chartStates['laporanNutrisi']!;
    final disinfektanState = _chartStates['laporanDisinfektan']!;
    final panenState = _chartStates['laporanPanen']!;

    // Calculate totals for all activities
    num totalLaporan = laporanHarianState.dataPoints.fold(
        0, (prev, curr) => prev + _safeNumericValue(curr['jumlahLaporan']));
    num totalPenyiraman = penyiramanState.dataPoints.fold(
        0, (prev, curr) => prev + _safeNumericValue(curr['jumlahPenyiraman']));
    num totalPruning = pruningState.dataPoints.fold(
        0, (prev, curr) => prev + _safeNumericValue(curr['jumlahPruning']));
    num totalRepotting = repottingState.dataPoints.fold(
        0, (prev, curr) => prev + _safeNumericValue(curr['jumlahRepotting']));
    num totalNutrisiMain = nutrisiState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + _safeNumericValue(curr['jumlahKejadianPemberianPupuk']));
    num totalSakit = sakitState.dataPoints
        .fold(0, (prev, curr) => prev + _safeNumericValue(curr['jumlahSakit']));
    num totalMati = matiState.dataPoints.fold(
        0, (prev, curr) => prev + _safeNumericValue(curr['jumlahKematian']));
    num totalVitamin = vitaminState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + _safeNumericValue(curr['jumlahPemberianVitamin']));
    num totalPupuk = pupukState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + _safeNumericValue(curr['jumlahKejadianPemberianPupuk']));
    num totalDisinfektan = disinfektanState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + _safeNumericValue(curr['jumlahPemberianDisinfektan']));
    num totalPanen = panenState.dataPoints.fold(
        0,
        (prev, curr) =>
            prev + _safeNumericValue(curr['jumlahLaporanPanenTanaman']));

    // Check if ALL activities are zero (complete empty state)
    if (totalLaporan == 0 &&
        totalPenyiraman == 0 &&
        totalPruning == 0 &&
        totalRepotting == 0 &&
        totalNutrisiMain == 0 &&
        totalSakit == 0 &&
        totalMati == 0 &&
        totalVitamin == 0 &&
        totalPupuk == 0 &&
        totalDisinfektan == 0 &&
        totalPanen == 0) {
      return "Berdasarkan statistik pelaporan pada tanggal $displayRange, tidak ditemukan aktivitas perawatan tanaman atau pelaporan apapun. Mulai lakukan pelaporan dan perawatan rutin untuk memantau kondisi dan pertumbuhan tanaman Anda secara optimal.";
    }

    if (laporanHarianState.dataPoints.isEmpty) {
      summary.write(
          "tidak ditemukan adanya aktivitas pelaporan harian, namun terdapat beberapa aktivitas lainnya.\n\n");
    } else {
      // Menghitung jumlah hari aktual dalam rentang yang dipilih
      final int daysInPeriod = range.end.difference(range.start).inDays + 1;
      double avgLaporan = totalLaporan / daysInPeriod; // Pembagi diubah
      summary.write(
          "telah dilakukan perawatan dan pelaporan harian dengan rata-rata ${avgLaporan.toStringAsFixed(1)} laporan per hari.\n\n");

      final minMaxLaporan =
          _findMinMaxDays(laporanHarianState.dataPoints, 'jumlahLaporan');
      // Gunakan helper yang sudah diperbaiki
      final String minDaysText =
          _formatConsecutiveDates(minMaxLaporan['minDays']);
      final String maxDaysText =
          _formatConsecutiveDates(minMaxLaporan['maxDays']);

      if (minDaysText.isNotEmpty && maxDaysText.isNotEmpty) {
        summary.write(
            "Hari dengan pelaporan terendah pada tanggal $minDaysText (${minMaxLaporan['minValue']} laporan) dan hari dengan pelaporan terbanyak pada tanggal $maxDaysText (${minMaxLaporan['maxValue']} laporan).\n\n");
      }
    }

    if (!penyiramanState.isLoading &&
        penyiramanState.dataPoints.isNotEmpty &&
        totalPenyiraman > 0) {
      final int daysInPeriod = range.end.difference(range.start).inDays + 1;
      double avgPenyiraman = totalPenyiraman / daysInPeriod;
      summary.write(
          "Frekuensi penyiraman tanaman terjadi $totalPenyiraman kali dengan rata-rata ${avgPenyiraman.toStringAsFixed(1)} kali per hari. ");
    }

    if (!pruningState.isLoading &&
        pruningState.dataPoints.isNotEmpty &&
        totalPruning > 0) {
      final int daysInPeriod = range.end.difference(range.start).inDays + 1;
      double avgPruning = totalPruning / daysInPeriod;
      summary.write(
          "Kemudian, frekuensi pruning tanaman terjadi $totalPruning kali dengan rata-rata ${avgPruning.toStringAsFixed(1)} kali per hari.\n\n");
    }

    if (!repottingState.isLoading &&
        repottingState.dataPoints.isNotEmpty &&
        totalRepotting > 0) {
      final int daysInPeriod = range.end.difference(range.start).inDays + 1;
      double avgRepotting = totalRepotting / daysInPeriod;
      summary.write(
          "Frekuensi repotting tanaman terjadi $totalRepotting kali dengan rata-rata ${avgRepotting.toStringAsFixed(1)} kali per hari.\n\n");
    }

    if (!nutrisiState.isLoading &&
        nutrisiState.dataPoints.isNotEmpty &&
        totalNutrisiMain > 0) {
      final int daysInPeriod = range.end.difference(range.start).inDays + 1;
      double avgNutrisi = totalNutrisiMain / daysInPeriod;
      summary.write(
          "Frekuensi pemberian nutrisi tanaman terjadi $totalNutrisiMain kali dengan rata-rata ${avgNutrisi.toStringAsFixed(1)} kali per hari.\n\n");
    }

    final List<String> attentionItems = [];
    if (totalSakit > 0) {
      attentionItems.add("$totalSakit laporan tanaman sakit");
    }
    if (totalMati > 0) {
      attentionItems.add("$totalMati laporan kematian tanaman");
    }
    if (totalVitamin > 0) {
      attentionItems.add("$totalVitamin laporan pemberian vitamin");
    }
    if (totalPupuk > 0) {
      attentionItems.add("$totalPupuk laporan pemberian nutrisi");
    }
    if (totalDisinfektan > 0) {
      attentionItems.add("$totalDisinfektan laporan pemberian disinfektan");
    }
    if (totalPanen > 0) {
      attentionItems.add("$totalPanen laporan panen tanaman");
    }

    if (attentionItems.isNotEmpty) {
      summary
          .write("Perlu menjadi perhatian, selama periode ini tercatat ada ");
      if (attentionItems.length == 1) {
        summary.write(attentionItems.first);
      } else if (attentionItems.length == 2) {
        summary.write("${attentionItems.first} dan ${attentionItems.last}");
      } else {
        final lastItem = attentionItems.removeLast();
        summary.write("${attentionItems.join(', ')}, dan $lastItem");
      }
      summary.write(".\n\n");
    }

    // Analisis Distribusi Tinggi Tanaman
    if (_statistikHarianData != null &&
        _statistikHarianData!['grafikTinggiTanaman'] != null) {
      final grafikTinggiTanaman =
          _statistikHarianData!['grafikTinggiTanaman'] as Map<String, dynamic>?;

      if (grafikTinggiTanaman != null && grafikTinggiTanaman.isNotEmpty) {
        final labels = grafikTinggiTanaman['labels'] as List<dynamic>? ?? [];
        final datasets =
            grafikTinggiTanaman['datasets'] as List<dynamic>? ?? [];

        if (labels.isNotEmpty && datasets.isNotEmpty) {
          final dataset = datasets.first as Map<String, dynamic>;
          final dataPoints = dataset['data'] as List<dynamic>? ?? [];

          if (dataPoints.isNotEmpty) {
            // Analisis distribusi tinggi tanaman
            final heights =
                dataPoints.map((e) => (e as num).toDouble()).toList();
            heights.sort();

            final totalTanaman = heights.length;
            final tinggiMin = heights.first;
            final tinggiMax = heights.last;
            final tinggiRataRata =
                heights.reduce((a, b) => a + b) / totalTanaman;

            // Kelompokkan untuk mencari modus (tinggi yang paling sering muncul)
            Map<double, int> heightFrequency = {};
            for (var height in heights) {
              heightFrequency[height] = (heightFrequency[height] ?? 0) + 1;
            }

            final sortedByFrequency = heightFrequency.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final tinggiTerbanyak = sortedByFrequency.first.key;
            final jumlahTinggiTerbanyak = sortedByFrequency.first.value;

            // Hitung median
            double tinggiMedian;
            if (totalTanaman % 2 == 0) {
              tinggiMedian = (heights[totalTanaman ~/ 2 - 1] +
                      heights[totalTanaman ~/ 2]) /
                  2;
            } else {
              tinggiMedian = heights[totalTanaman ~/ 2];
            }

            // Klasifikasi distribusi
            final rentangTinggi = tinggiMax - tinggiMin;
            String distribusiKategori;
            if (rentangTinggi <= 5) {
              distribusiKategori = "sangat seragam";
            } else if (rentangTinggi <= 10) {
              distribusiKategori = "cukup seragam";
            } else if (rentangTinggi <= 20) {
              distribusiKategori = "bervariasi";
            } else {
              distribusiKategori = "sangat bervariasi";
            }

            summary.write(
                "Dari segi pertumbuhan fisik tanaman, analisis distribusi tinggi menunjukkan bahwa dari $totalTanaman tanaman yang dipantau, ");
            summary.write(
                "tinggi tanaman berkisar antara ${tinggiMin.toStringAsFixed(1)} cm hingga ${tinggiMax.toStringAsFixed(1)} cm ");
            summary.write(
                "dengan rata-rata ${tinggiRataRata.toStringAsFixed(1)} cm dan median ${tinggiMedian.toStringAsFixed(1)} cm. ");

            summary.write(
                "Tinggi yang paling umum ditemukan adalah ${tinggiTerbanyak.toStringAsFixed(1)} cm ");
            summary
                .write("yang dimiliki oleh $jumlahTinggiTerbanyak tanaman. ");

            summary.write(
                "Secara keseluruhan, distribusi tinggi tanaman tergolong $distribusiKategori ");

            if (distribusiKategori == "sangat seragam" ||
                distribusiKategori == "cukup seragam") {
              summary.write(
                  "yang menunjukkan pertumbuhan yang konsisten dan kondisi perawatan yang baik.\n\n");
            } else if (distribusiKategori == "bervariasi") {
              summary.write(
                  "yang dapat mengindikasikan adanya variasi dalam kondisi tumbuh atau tahap pertumbuhan yang berbeda.\n\n");
            } else {
              summary.write(
                  "yang mungkin memerlukan perhatian khusus untuk mengidentifikasi faktor-faktor yang menyebabkan perbedaan pertumbuhan yang signifikan.\n\n");
            }
          }
        }
      }
    }

    summary.write(
        "Bukti pelaporan dapat dilihat pada detail riwayat di setiap tab terkait.");

    summary.write(
        "\n\nCatatan: Statistik di atas berdasarkan data yang tersedia dan dapat berubah seiring waktu. Pastikan untuk melakukan pemantauan rutin terhadap kesehatan tanaman.");
    return summary.toString().trim();
  }

  Future<void> _fetchPanenGradeData() async {
    if (!mounted ||
        widget.idTanaman == null ||
        _selectedChartDateRange == null) {
      return;
    }

    final gradeState = _chartStates['panenGrade'];
    if (gradeState == null) return;

    setState(() => gradeState.setLoading());

    try {
      final response =
          await _laporanService.getStatistikPanenGradeByJenisBudidaya(
        jenisBudidayaId: widget.idTanaman!,
        startDate:
            _selectedChartDateRange!.start.toIso8601String().split('T')[0],
        endDate: _selectedChartDateRange!.end.toIso8601String().split('T')[0],
      );

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          final data = response['data'] as Map<String, dynamic>;
          final chartData = data['chartData'] as List<dynamic>? ?? [];

          // Convert to chart data points with proper double handling
          final dataPoints = chartData
              .map((item) => {
                    'label': item['label']?.toString() ?? '',
                    'value': _safeNumericValue(item['value']),
                    'commodity': item['commodity']?.toString() ?? '',
                    'unit': item['unit']?.toString() ?? '',
                  })
              .toList();

          final labels =
              chartData.map((item) => item['label']?.toString() ?? '').toList();

          gradeState.setData(dataPoints, labels, chartData);
        } else {
          gradeState.setError(response['message'] as String? ??
              'Gagal memuat data grade panen');
        }
      }
    } catch (e) {
      if (mounted) {
        gradeState.setError('Error grade panen: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() {}); // Trigger rebuild
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
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Laporan Perkebunan',
            greeting: 'Laporan Tanaman',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tabs(
              key: const Key('reportTabs'),
              onTabChanged: _onTabChanged,
              selectedIndex: _selectedTabIndex,
              tabTitles: tabList,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _selectedTabIndex = index),
                children: [
                  InfoTab(
                    key: const Key('infoTab'),
                    isLoadingInitialData: _isLoadingInitialData,
                    tanamanReport: _tanamanReport,
                    kebunList: _kebunList,
                    jumlahTanaman: _jumlahTanaman,
                    scrollController: _scrollController,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  PanenTab(
                    key: const Key('panenTab'),
                    laporanPanenState: _chartStates['laporanPanen'] ??
                        ChartDataState<List<dynamic>>(),
                    panenKomoditasState: _chartStates['panenKomoditas'] ??
                        ChartDataState<List<dynamic>>(),
                    panenGradeState: _chartStates['panenGrade'] ??
                        ChartDataState<List<dynamic>>(),
                    riwayatPanenState: _riwayatStates['panen'] ??
                        RiwayatDataState<List<dynamic>>(),
                    onDateIconPressed: _showDateFilterDialog,
                    selectedChartFilterType: _selectedChartFilterType,
                    formattedDisplayedDateRange: formattedDisplayedDateRange,
                    onChartFilterTypeChanged: _handleChartFilterTypeChanged,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  HarianTab(
                    key: const Key('harianTab'),
                    laporanHarianState: _chartStates['laporanHarian']!,
                    penyiramanState: _chartStates['penyiraman']!,
                    nutrisiState: _chartStates['nutrisi']!,
                    pruningState: _chartStates['pruning']!,
                    repottingState: _chartStates['repotting']!,
                    statistikHarianErrorMessage: _statistikHarianErrorMessage,
                    statistikHarianData: _statistikHarianData,
                    onDateIconPressed: _showDateFilterDialog,
                    selectedChartFilterType: _selectedChartFilterType,
                    formattedDisplayedDateRange: formattedDisplayedDateRange,
                    onChartFilterTypeChanged: _handleChartFilterTypeChanged,
                    generatedStatistikRangkumanText:
                        _generateStatistikRangkumanText(),
                    riwayatUmumState: _riwayatStates['umum']!,
                    riwayatPupukState: _riwayatStates['pupuk']!,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  SakitTab(
                    key: const Key('sakitTab'),
                    laporanSakitState: _chartStates['laporanSakit']!,
                    statistikPenyakitState: _chartStates['statistikPenyakit']!,
                    riwayatSakitState: _riwayatStates['sakit']!,
                    onDateIconPressed: _showDateFilterDialog,
                    selectedChartFilterType: _selectedChartFilterType,
                    formattedDisplayedDateRange: formattedDisplayedDateRange,
                    onChartFilterTypeChanged: _handleChartFilterTypeChanged,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  MatiTab(
                    key: const Key('matiTab'),
                    laporanMatiState: _chartStates['laporanMati']!,
                    statistikPenyebabState:
                        _chartStates['statistikPenyebabKematian']!,
                    riwayatMatiState: _riwayatStates['mati']!,
                    onDateIconPressed: _showDateFilterDialog,
                    selectedChartFilterType: _selectedChartFilterType,
                    formattedDisplayedDateRange: formattedDisplayedDateRange,
                    onChartFilterTypeChanged: _handleChartFilterTypeChanged,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  NutrisiTab(
                    key: const Key('nutrisiTab'),
                    nutrisiState: _chartStates['laporanNutrisi']!,
                    vitaminState: _chartStates['laporanVitamin']!,
                    disinfektanState: _chartStates['laporanDisinfektan']!,
                    riwayatNutrisiState: _riwayatStates['nutrisi']!,
                    onDateIconPressed: _showDateFilterDialog,
                    selectedChartFilterType: _selectedChartFilterType,
                    formattedDisplayedDateRange: formattedDisplayedDateRange,
                    onChartFilterTypeChanged: _handleChartFilterTypeChanged,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
