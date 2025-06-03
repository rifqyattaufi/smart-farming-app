import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/harian.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/info.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/panen.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/sakit.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/vitamin.dart';
import 'package:smart_farming_app/screen/laporan/tab_tanaman/mati.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/report_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/utils/custom_picker_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/tabs.dart';

// --- State Helper Classes ---
class ChartDataState<T> {
  bool isLoading;
  String? error;
  List<Map<String, dynamic>> dataPoints;
  List<String> xLabels;
  T? rawData;

  ChartDataState({
    this.isLoading = true,
    this.error,
    this.dataPoints = const [],
    this.xLabels = const [],
    this.rawData,
  });

  void setLoading() {
    isLoading = true;
    error = null;
    // dataPoints = []; // Optional: clear data on new load
    // xLabels = [];    // Optional: clear data on new load
  }

  void setData(List<Map<String, dynamic>> points, List<String> labels,
      [T? raw]) {
    dataPoints = points;
    xLabels = labels;
    isLoading = false;
    error = null;
    rawData = raw;
  }

  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    dataPoints = [];
    xLabels = [];
  }
}

class RiwayatDataState<T> {
  bool isLoading;
  String? error;
  List<Map<String, dynamic>> items;
  T? rawData;

  RiwayatDataState({
    this.isLoading = true,
    this.error,
    this.items = const [],
    this.rawData,
  });

  void setLoading() {
    isLoading = true;
    error = null;
  }

  void setData(List<Map<String, dynamic>> newItems, [T? raw]) {
    items = newItems;
    isLoading = false;
    error = null;
    rawData = raw;
  }

  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    items = [];
  }
}
// --- End State Helper Classes ---

class StatistikTanamanReport extends StatefulWidget {
  final String? idTanaman;

  const StatistikTanamanReport({super.key, this.idTanaman});

  @override
  State<StatistikTanamanReport> createState() => _StatistikTanamanReportState();
}

class _StatistikTanamanReportState extends State<StatistikTanamanReport> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ReportService _reportService = ReportService();

  Map<String, dynamic>? _tanamanReport;
  List<dynamic> _kebunList = [];
  int _jumlahTanaman = 0;
  bool _isLoadingInitialData = true;

  // State untuk Statistik Harian (Overview Card)
  Map<String, dynamic>? _statistikHarianData;
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
  };

  final Map<String, RiwayatDataState<List<dynamic>>> _riwayatStates = {
    'umum': RiwayatDataState<List<dynamic>>(),
    'pupuk': RiwayatDataState<List<dynamic>>(),
    'sakit': RiwayatDataState<List<dynamic>>(),
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
          valueKey: backendEntry != null ? (backendEntry[valueKey] ?? 0) : 0
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
          valueKey: backendEntry != null ? (backendEntry[valueKey] ?? 0) : 0
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
          valueKey: backendEntry != null ? (backendEntry[valueKey] ?? 0) : 0
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
        _fetchAndProcessRiwayatData(
            riwayatKey: 'umum',
            defaultErrorMessage: 'Gagal memuat riwayat pelaporan umum',
            fetchFunction: () =>
                _reportService.getRiwayatLaporanUmumJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!, limit: 3, page: 1)),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'sakit',
            defaultErrorMessage: 'Gagal memuat riwayat pelaporan sakit',
            fetchFunction: () =>
                _reportService.getRiwayatLaporanSakitJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!, limit: 3, page: 1)),
        _fetchAndProcessRiwayatData(
            riwayatKey: 'pupuk',
            defaultErrorMessage: 'Gagal memuat riwayat pemberian pupuk',
            fetchFunction: () =>
                _reportService.getRiwayatPemberianNutrisiJenisBudidaya(
                    jenisBudidayaId: widget.idTanaman!,
                    limit: 3,
                    page: 1,
                    tipeNutrisi: 'pupuk')),
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

  String _generateStatistikRangkumanText() {
    if (_selectedChartDateRange == null) {
      return "Silakan pilih rentang tanggal untuk melihat rangkuman statistik.";
    }
    final DateFormat rangeFormatter = DateFormat('d MMM yyyy');
    final String startDateFormatted =
        rangeFormatter.format(_selectedChartDateRange!.start);
    final String endDateFormatted =
        rangeFormatter.format(_selectedChartDateRange!.end);
    final StringBuffer summary = StringBuffer(
        "Berdasarkan statistik pelaporan pada periode $startDateFormatted hingga $endDateFormatted:\n\n");

    // Helper sub-functions
    String getChartSummary(
        String chartKey, String valueKey, String entityName, String unit) {
      final state = _chartStates[chartKey]!;
      if (state.isLoading) return "Statistik $entityName sedang dimuat...\n\n";
      if (state.error != null) {
        return "Tidak dapat memuat statistik $entityName: ${state.error}\n\n";
      }
      if (state.dataPoints.isEmpty) {
        return "Tidak ada data $entityName untuk periode ini.\n\n";
      }

      num total = state.dataPoints
          .fold(0, (prev, curr) => prev + ((curr[valueKey] as num?) ?? 0));
      String text = "Telah diterima total $total $unit $entityName. ";
      if ((_selectedChartFilterType == ChartFilterType.weekly ||
              _selectedChartFilterType == ChartFilterType.custom) &&
          state.dataPoints.isNotEmpty) {
        double average = total / state.dataPoints.length;
        text +=
            "Dengan rata-rata ${average.toStringAsFixed(1)} $unit per hari. ";
        if (chartKey == 'laporanHarian') {
          // Min/Max specific for laporanHarian
          try {
            final minItem = state.dataPoints.reduce((c, n) =>
                ((c[valueKey] as num?) ?? double.infinity) <
                        ((n[valueKey] as num?) ?? double.infinity)
                    ? c
                    : n);
            final maxItem = state.dataPoints.reduce((c, n) =>
                ((c[valueKey] as num?) ?? double.negativeInfinity) >
                        ((n[valueKey] as num?) ?? double.negativeInfinity)
                    ? c
                    : n);
            final DateFormat dayMonthFormatter = DateFormat('d MMMM');
            String minDay =
                dayMonthFormatter.format(DateTime.parse(minItem['period']));
            String maxDay =
                dayMonthFormatter.format(DateTime.parse(maxItem['period']));
            text +=
                "Pelaporan terendah pada tanggal $minDay (${minItem[valueKey]}) dan tertinggi pada $maxDay (${maxItem[valueKey]}).";
          } catch (e) {
            text += "Detail hari terendah/tertinggi tidak dapat ditampilkan.";
          }
        }
      }
      return "$text\n\n";
    }

    summary.write(getChartSummary(
        'laporanHarian', 'jumlahLaporan', 'laporan harian', 'laporan'));

    if (_isLoadingStatistikHarian) {
      summary.write("Statistik tinggi tanaman sedang dimuat...\n\n");
    } else if (_statistikHarianData != null &&
        _statistikHarianData!['detailTanaman'] != null) {
      final List<dynamic> listDetailTanaman =
          _statistikHarianData!['detailTanaman'] as List<dynamic>;
      List<double> tinggiTanamanValues = listDetailTanaman
          .whereType<Map<String, dynamic>>()
          .where((t) => t['tinggiTanaman'] != null && t['tinggiTanaman'] is num)
          .map((t) => (t['tinggiTanaman'] as num).toDouble())
          .toList();
      if (tinggiTanamanValues.isNotEmpty) {
        double totalTinggi = tinggiTanamanValues.reduce((a, b) => a + b);
        double rataRataTinggi = totalTinggi / tinggiTanamanValues.length;
        summary.write(
            "Rata-rata tinggi tanaman yang dilaporkan adalah ${rataRataTinggi.toStringAsFixed(1)} cm. ");
      } else {
        summary.write(
            "Tidak ada data tinggi tanaman yang valid untuk dihitung rata-ratanya. ");
      }
      summary.write("\n\n");
    }

    summary.write(getChartSummary(
        'penyiraman', 'jumlahPenyiraman', 'penyiraman tanaman', 'kali'));
    summary.write(getChartSummary(
        'nutrisi', 'jumlahKejadianPemberianPupuk', 'pemberian pupuk', 'kali'));
    summary
        .write(getChartSummary('pruning', 'jumlahPruning', 'pruning', 'kali'));
    summary.write(
        getChartSummary('repotting', 'jumlahRepotting', 'repotting', 'kali'));

    summary.write(
        "Catatan: Statistik di atas berdasarkan data yang tersedia dan dapat berubah seiring waktu. Pastikan untuk melakukan pemantauan rutin terhadap kesehatan tanaman Anda.");
    return summary.toString().trim();
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
                    isLoadingInitialData: _isLoadingInitialData,
                    tanamanReport: _tanamanReport,
                    kebunList: _kebunList,
                    jumlahTanaman: _jumlahTanaman,
                    scrollController: _scrollController,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  const PanenTab(),
                  HarianTab(
                    laporanHarianState: _chartStates['laporanHarian']!,
                    penyiramanState: _chartStates['penyiraman']!,
                    nutrisiState: _chartStates['nutrisi']!,
                    pruningState: _chartStates['pruning']!,
                    repottingState: _chartStates['repotting']!,
                    isLoadingStatistikHarian: _isLoadingStatistikHarian,
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
                    onRiwayatPelaporanUmumItemTap:
                        (tappedContext, tappedItem) {},
                    onRiwayatPemberianPupukItemTap:
                        (tappedContext, tappedItem) {},
                  ),
                  SakitTab(
                    laporanSakitState: _chartStates['laporanSakit']!,
                    riwayatSakitState: _riwayatStates['sakit']!,
                    onDateIconPressed: _showDateFilterDialog,
                    selectedChartFilterType: _selectedChartFilterType,
                    formattedDisplayedDateRange: formattedDisplayedDateRange,
                    onChartFilterTypeChanged: _handleChartFilterTypeChanged,
                    formatDisplayDate: formatDisplayDate,
                    formatDisplayTime: formatDisplayTime,
                  ),
                  const MatiTab(),
                  NutrisiTab(
                    nutrisiState: _chartStates['nutrisi']!,
                    riwayatPupukState: _riwayatStates['pupuk']!,
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
