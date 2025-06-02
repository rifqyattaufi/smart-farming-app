import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/report_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_enums.dart';
import 'package:smart_farming_app/utils/custom_picker_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/tabs.dart';
import 'package:smart_farming_app/widget/chart.dart';

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
  List<dynamic> _objekTanamanList = [];
  List<dynamic> _kebunList = [];
  int _jumlahTanaman = 0;
  bool _isLoadingInitialData = true;

  // State untuk Statistik Harian
  Map<String, dynamic>? _statistikHarianData;
  bool _isLoadingStatistikHarian = true;
  String? _statistikHarianErrorMessage;

  // State untuk Statistik Laporan Harian
  List<Map<String, dynamic>> _laporanHarianChartDataPoints = [];
  List<String> _laporanHarianChartXLabels = [];
  bool _isLoadingLaporanHarianChart = true;
  String? _errorLaporanHarianChart;

  // State untuk Statistik Penyiraman
  List<Map<String, dynamic>> _penyiramanChartDataPoints = [];
  List<String> _penyiramanChartXLabels = [];
  bool _isLoadingPenyiramanChart = true;
  String? _errorPenyiramanChart;

  // State untuk Statistik Pemberian Nutrisi
  List<Map<String, dynamic>> _nutrisiChartDataPoints = [];
  List<String> _nutrisiChartXLabels = [];
  bool _isLoadingNutrisiChart = true;
  String? _errorNutrisiChart;

  // Riwayat Pelaporan Umum
  List<Map<String, dynamic>> _riwayatPelaporanUmum = [];
  bool _isLoadingRiwayatPelaporanUmum = true;
  String? _errorRiwayatPelaporanUmum;

  // Riwayat Pemberian Pupuk
  List<Map<String, dynamic>> _riwayatPemberianPupuk = [];
  bool _isLoadingRiwayatPemberianPupuk = true;
  String? _errorRiwayatPemberianPupuk;

  ChartFilterType _selectedChartFilterType = ChartFilterType.weekly;
  DateTimeRange? _selectedChartDateRange;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.idTanaman == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ID Tanaman tidak valid.'),
              backgroundColor: Colors.red),
        );
        context.pop();
      });
      return;
    }

    final now = DateTime.now();
    _selectedChartDateRange =
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
    _fetchInitialData().then((_) {
      if (widget.idTanaman != null) {
        _fetchAllReportChartsData();
        _fetchRiwayatPelaporanUmum();
        _fetchRiwayatPemberianPupuk();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingInitialData = true;
    });
    try {
      if (widget.idTanaman == null) {
        _showErrorSnackbar('ID Tanaman tidak valid.');
        setState(() {
          _isLoadingInitialData = false;
        });
        return;
      }

      final response = await _jenisBudidayaService.getJenisBudidayaById(
        widget.idTanaman!,
      );

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

          if (jenisBudidayaDetailData != null && unitBudidayaRawList != null) {
            List<dynamic> objekBudidayaFinalList = [];

            if (unitBudidayaRawList.isNotEmpty) {
              final firstUnitBudidaya =
                  unitBudidayaRawList[0] as Map<String, dynamic>?;
              if (firstUnitBudidaya != null &&
                  firstUnitBudidaya.containsKey('ObjekBudidayas') &&
                  firstUnitBudidaya['ObjekBudidayas'] != null &&
                  firstUnitBudidaya['ObjekBudidayas'] is List) {
                objekBudidayaFinalList =
                    firstUnitBudidaya['ObjekBudidayas'] as List<dynamic>;
              }
            }

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

            if (mounted) {
              setState(() {
                _tanamanReport = jenisBudidayaDetailData;
                _kebunList = unitBudidayaRawList;
                _objekTanamanList = [];
                _jumlahTanaman = totalJumlahObjekBudidayaDariResponse;
                _isLoadingInitialData = false;
              });
              await _fetchStatistikHarian();
            }
          } else {
            _showErrorSnackbar(
                'Data detail jenis budidaya atau unit budidaya tidak lengkap atau formatnya salah.');
            if (mounted) _setLoadingFalseAndClearData();
          }
        } else {
          _showErrorSnackbar(
              'Struktur data utama (key jenisBudidaya / unitBudidaya) tidak ditemukan atau formatnya salah.');
          if (mounted) _setLoadingFalseAndClearData();
        }
      } else {
        _showErrorSnackbar(response['message'] as String? ??
            'Gagal memuat data inventaris atau status respons tidak berhasil.');
        if (mounted) _setLoadingFalseAndClearData();
      }
    } catch (e) {
      _showErrorSnackbar('Error saat mengambil data: ${e.toString()}');
      if (mounted) _setLoadingFalseAndClearData();
    } finally {
      if (mounted && _isLoadingInitialData) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  void _setLoadingFalseAndClearData() {
    setState(() {
      _isLoadingInitialData = false;
      _tanamanReport = null;
      _kebunList = [];
      _objekTanamanList = [];
      _jumlahTanaman = 0;
    });
  }

  Future<void> _fetchStatistikHarian() async {
    if (widget.idTanaman == null) return;

    setState(() {
      _isLoadingStatistikHarian = true;
      _statistikHarianErrorMessage = null;
    });

    try {
      final response = await _reportService
          .getStatistikHarianJenisBudidaya(widget.idTanaman!);

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _statistikHarianData = response['data'] as Map<String, dynamic>;
            _isLoadingStatistikHarian = false;
          });
        } else {
          setState(() {
            _statistikHarianErrorMessage = response['message'] as String? ??
                'Gagal memuat statistik harian.';
            _isLoadingStatistikHarian = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statistikHarianErrorMessage = 'Terjadi kesalahan: ${e.toString()}';
          _isLoadingStatistikHarian = false;
        });
      }
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

    Map<String, Map<String, dynamic>> backendDataMap = {};
    for (var item in rawBackendData) {
      if (item is Map<String, dynamic> && item['period'] != null) {
        backendDataMap[item['period'].toString()] = item;
      }
    }

    if (filterType == ChartFilterType.weekly ||
        filterType == ChartFilterType.custom) {
      DateTime currentDate = startDate;
      while (!currentDate.isAfter(endDate)) {
        final String periodKey = DateFormat('yyyy-MM-dd').format(currentDate);
        final String displayLabel = DateFormat('dd').format(currentDate);
        final backendEntry = backendDataMap[periodKey];
        processedDataPoints.add({
          'period': periodKey,
          valueKey: backendEntry != null ? (backendEntry[valueKey] ?? 0) : 0,
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
          valueKey: backendEntry != null ? (backendEntry[valueKey] ?? 0) : 0,
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
          valueKey: backendEntry != null ? (backendEntry[valueKey] ?? 0) : 0,
        });
        processedXLabels.add(displayLabel);
        currentDate = DateTime(currentDate.year + 1, 1, 1);
        if (processedXLabels.length > 10) break;
      }
    }
    return {'points': processedDataPoints, 'labels': processedXLabels};
  }

  Future<void> _fetchAllReportChartsData() async {
    if (widget.idTanaman == null || _selectedChartDateRange == null) return;

    // Set loading states for all charts
    setState(() {
      _isLoadingLaporanHarianChart = true;
      _isLoadingPenyiramanChart = true;
      _isLoadingNutrisiChart = true;
      _errorLaporanHarianChart = null;
      _errorPenyiramanChart = null;
      _errorNutrisiChart = null;
    });

    String groupBy;
    switch (_selectedChartFilterType) {
      case ChartFilterType.monthly:
        groupBy = 'month';
        break;
      case ChartFilterType.yearly:
        groupBy = 'year';
        break;
      case ChartFilterType.weekly:
      default:
        groupBy = 'day';
        break;
    }

    try {
      // Fetch Laporan Harian Chart Data
      try {
        final responseLaporan = await _reportService.getStatistikLaporanHarian(
          jenisBudidayaId: widget.idTanaman!,
          startDate: _selectedChartDateRange!.start,
          endDate: _selectedChartDateRange!.end,
          groupBy: groupBy,
        );
        if (mounted) {
          if (responseLaporan['status'] == true) {
            final processed = _processBackendChartData(
              rawBackendData: responseLaporan['data'] ?? [],
              filterType: _selectedChartFilterType,
              selectedDateRange: _selectedChartDateRange!,
              valueKey: 'jumlahLaporan',
            );
            setState(() {
              _laporanHarianChartDataPoints = processed['points'];
              _laporanHarianChartXLabels = processed['labels'];
            });
          } else {
            setState(() {
              _errorLaporanHarianChart = responseLaporan['message'] ??
                  'Gagal memuat statistik laporan harian';
              _laporanHarianChartDataPoints = [];
              _laporanHarianChartXLabels = [];
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorLaporanHarianChart = 'Error: ${e.toString()}';
            _laporanHarianChartDataPoints = [];
            _laporanHarianChartXLabels = [];
          });
        }
      } finally {
        if (mounted) setState(() => _isLoadingLaporanHarianChart = false);
      }

      // Fetch Penyiraman Chart Data
      try {
        final responsePenyiraman = await _reportService.getStatistikPenyiraman(
          jenisBudidayaId: widget.idTanaman!,
          startDate: _selectedChartDateRange!.start,
          endDate: _selectedChartDateRange!.end,
          groupBy: groupBy,
        );
        if (mounted) {
          if (responsePenyiraman['status'] == true) {
            final processed = _processBackendChartData(
              rawBackendData: responsePenyiraman['data'] ?? [],
              filterType: _selectedChartFilterType,
              selectedDateRange: _selectedChartDateRange!,
              valueKey: 'jumlahPenyiraman',
            );
            setState(() {
              _penyiramanChartDataPoints = processed['points'];
              if (_laporanHarianChartXLabels.isNotEmpty) {
                _penyiramanChartXLabels =
                    List<String>.from(_laporanHarianChartXLabels);
              } else {
                _penyiramanChartXLabels = processed['labels'];
              }
            });
          } else {
            setState(() {
              _errorPenyiramanChart = responsePenyiraman['message'] ??
                  'Gagal memuat statistik penyiraman';
              _penyiramanChartDataPoints = [];
              _penyiramanChartXLabels = [];
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorPenyiramanChart = 'Error: ${e.toString()}';
            _penyiramanChartDataPoints = [];
            _penyiramanChartXLabels = [];
          });
        }
      } finally {
        if (mounted) setState(() => _isLoadingPenyiramanChart = false);
      }

      // Fetch Pemberian Nutrisi Chart Data
      try {
        final responseNutrisi =
            await _reportService.getStatistikPemberianNutrisi(
          jenisBudidayaId: widget.idTanaman!,
          startDate: _selectedChartDateRange!.start,
          endDate: _selectedChartDateRange!.end,
          groupBy: groupBy,
        );
        if (mounted) {
          if (responseNutrisi['status'] == true) {
            final processed = _processBackendChartData(
              rawBackendData: responseNutrisi['data'] ?? [],
              filterType: _selectedChartFilterType,
              selectedDateRange: _selectedChartDateRange!,
              valueKey: 'jumlahKejadianPemberianPupuk',
            );
            setState(() {
              _nutrisiChartDataPoints = processed['points'];
              if (_laporanHarianChartXLabels.isNotEmpty) {
                _nutrisiChartXLabels =
                    List<String>.from(_laporanHarianChartXLabels);
              } else {
                _nutrisiChartXLabels = processed['labels'];
              }
            });
          } else {
            setState(() {
              _errorNutrisiChart = responseNutrisi['message'] ??
                  'Gagal memuat statistik nutrisi';
              _nutrisiChartDataPoints = [];
              _nutrisiChartXLabels = [];
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorNutrisiChart = 'Error: ${e.toString()}';
            _nutrisiChartDataPoints = [];
            _nutrisiChartXLabels = [];
          });
        }
      } finally {
        if (mounted) setState(() => _isLoadingNutrisiChart = false);
      }

      // Fetch Riwayat Pelaporan Umum
      await _fetchRiwayatPelaporanUmum();
      // Fetch Riwayat Pemberian Pupuk
      await _fetchRiwayatPemberianPupuk();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(
            'Terjadi kesalahan saat memuat data chart: ${e.toString()}');
        setState(() {
          _isLoadingLaporanHarianChart = false;
          _isLoadingPenyiramanChart = false;
          _isLoadingNutrisiChart = false;
        });
      }
    }
  }

  Future<void> _fetchRiwayatPelaporanUmum() async {
    if (widget.idTanaman == null || !mounted) return;
    setState(() {
      _isLoadingRiwayatPelaporanUmum = true;
      _errorRiwayatPelaporanUmum = null;
    });
    try {
      final response = await _reportService.getRiwayatLaporanUmumJenisBudidaya(
        jenisBudidayaId: widget.idTanaman!,
        limit: 3,
        page: 1,
      );

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _riwayatPelaporanUmum =
                List<Map<String, dynamic>>.from(response['data']);
          });
        } else {
          setState(() => _errorRiwayatPelaporanUmum =
              response['message'] as String? ??
                  'Gagal memuat riwayat pelaporan');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorRiwayatPelaporanUmum = 'Terjadi kesalahan: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoadingRiwayatPelaporanUmum = false);
    }
  }

  Future<void> _fetchRiwayatPemberianPupuk() async {
    if (widget.idTanaman == null || !mounted) return;
    setState(() {
      _isLoadingRiwayatPemberianPupuk = true;
      _errorRiwayatPemberianPupuk = null;
    });
    try {
      final response =
          await _reportService.getRiwayatPemberianNutrisiJenisBudidaya(
        jenisBudidayaId: widget.idTanaman!,
        limit: 3,
        page: 1,
        tipeNutrisi: 'pupuk',
      );

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _riwayatPemberianPupuk =
                List<Map<String, dynamic>>.from(response['data']);
          });
        } else {
          setState(() => _errorRiwayatPemberianPupuk =
              response['message'] as String? ?? 'Gagal memuat riwayat nutrisi');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorRiwayatPemberianPupuk = 'Terjadi kesalahan: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoadingRiwayatPemberianPupuk = false);
    }
  }

  void _showErrorSnackbar(String message, {bool isError = true}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
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
      newRange = await showCustomMonthRangePicker(
        context,
        initialRange: currentSafeRange,
      );
    } else if (_selectedChartFilterType == ChartFilterType.yearly) {
      newRange = await showCustomYearRangePicker(
        context,
        initialRange: currentSafeRange,
      );
    }

    if (newRange != null && newRange != _selectedChartDateRange) {
      setState(() {
        _selectedChartDateRange = newRange;
      });
      await _fetchAllReportChartsData();
    }
  }

  String get formattedDisplayedDateRange {
    if (_selectedChartDateRange == null) {
      return "Pilih rentang tanggal";
    }

    final range = _selectedChartDateRange!;
    String formattedStart;
    String formattedEnd;

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
    'Nutrisi',
  ];
  final PageController _pageController = PageController();

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _formatDisplayDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime == null) return 'Invalid date';

      if (dateTime.year < 1900) return 'Tidak diatur';
      return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  String _formatDisplayTime(String? dateString) {
    if (dateString == null) return 'Unknown time';
    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime == null) return 'Invalid time';

      if (dateTime.year < 1900 && dateTime.hour == 0 && dateTime.minute == 0) {
        return '';
      }
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'Invalid time format';
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
              greeting: 'Laporan Tanaman Melon'),
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
                onPageChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                children: [_buildTabContent()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildInfo();
      case 1:
        return _buildPanen();
      case 2:
        return _buildHarian();
      case 3:
        return _buildSakit();
      case 4:
        return _buildMati();
      case 5:
        return _buildNutrisi();
      default:
        return const Center(child: Text('Tab tidak dikenal'));
    }
  }

  Widget _buildInfo() {
    if (_isLoadingInitialData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tanamanReport == null) {
      return const Center(child: Text("Laporan Perkebunan tidak ditemukan."));
    }

    List<Widget> daftarTanamanPerKebunWidgets = [];

    if (_kebunList.isNotEmpty && _tanamanReport != null) {
      for (var kebunData in _kebunList) {
        final kebunItem = kebunData as Map<String, dynamic>?;
        if (kebunItem == null) continue;

        final List<dynamic> objekBudidayaDiKebunIni =
            (kebunItem['ObjekBudidayas'] as List<dynamic>?) ?? [];

        if (objekBudidayaDiKebunIni.isNotEmpty) {
          daftarTanamanPerKebunWidgets.add(Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListItem(
              title: 'Tanaman di ${kebunItem['nama'] ?? 'Kebun Tanpa Nama'}',
              type: 'basic',
              items: objekBudidayaDiKebunIni.map((item) {
                final plantItem = item as Map<String, dynamic>?;
                final jenisBudidayaNama =
                    _tanamanReport!['nama'] as String? ?? 'Tidak Diketahui';
                final plantImg = _tanamanReport!['gambar'] as String? ?? '';

                return {
                  'name': plantItem?['namaId'] as String? ?? 'Tanpa Nama',
                  'icon': plantImg,
                  'category': jenisBudidayaNama,
                  'id': plantItem?['id'] as String? ?? '',
                  'subtitle': plantItem?['deskripsi'] as String? ?? '',
                };
              }).toList(),
              onItemTap: (context, selectedPlant) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Tanaman dipilih: ${selectedPlant['name']} dari kebun ${kebunItem['nama']}')),
                );
              },
            ),
          ));
        } else {
          daftarTanamanPerKebunWidgets.add(
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Tidak ada daftar tanaman di ${kebunItem['nama'] ?? 'Kebun Tanpa Nama'}.",
                style: regular14.copyWith(color: dark2),
              ),
            ),
          );
        }
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DottedBorder(
              color: green1,
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageBuilder(
                  url: _tanamanReport?['gambar'] ?? '',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Informasi Jenis Tanaman",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                infoItem("Nama jenis tanaman",
                    "${_tanamanReport?['nama'] ?? 'Tidak diketahui'}"),
                infoItem("Nama latin",
                    "${_tanamanReport?['latin'] ?? 'Tidak diketahui'}"),
                infoItem("Lokasi tanaman",
                    "${_tanamanReport?['nama'] ?? 'Tidak diketahui'}"),
                infoItem("Jumlah tanaman", "$_jumlahTanaman"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Status tanaman",
                          style: medium14.copyWith(color: dark1)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_tanamanReport?['status'] == true ||
                                  _tanamanReport?['status'] == 1)
                              ? green2.withValues(alpha: 0.1)
                              : red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          (_tanamanReport?['status'] == true ||
                                  _tanamanReport?['status'] == 1)
                              ? 'Budidaya'
                              : 'Tidak Budidaya',
                          style: (_tanamanReport?['status'] == true ||
                                  _tanamanReport?['status'] == 1)
                              ? regular12.copyWith(color: green2)
                              : regular12.copyWith(color: red),
                        ),
                      ),
                    ],
                  ),
                ),
                infoItem("Tanggal didaftarkan",
                    _formatDisplayDate(_tanamanReport?['createdAt'])),
                infoItem("Waktu didaftarkan",
                    _formatDisplayTime(_tanamanReport?['createdAt'])),
                const SizedBox(height: 8),
                Text("Deskripsi tanaman",
                    style: medium14.copyWith(color: dark1)),
                const SizedBox(height: 8),
                Text(
                  _tanamanReport?['detail'] ??
                      'Tidak ada deskripsi yang tersedia.',
                  style: regular14.copyWith(color: dark2),
                ),
              ],
            ),
          ),

          // --- DAFTAR KEBUN (UNIT BUDIDAYA) ---
          if (_kebunList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ListItem(
                title: 'Daftar Kebun Budidaya',
                type: 'basic',
                items: _kebunList.map((kebun) {
                  final kebunItem = kebun as Map<String, dynamic>?;
                  final jumlahObjekDiKebun =
                      (kebunItem?['ObjekBudidayas'] as List<dynamic>?)
                              ?.length ??
                          kebunItem?['jumlah'] ??
                          0;

                  return {
                    'name':
                        kebunItem?['nama'] as String? ?? 'Nama Kebun Tidak Ada',
                    'icon': kebunItem?['gambar'] as String? ?? '',
                    'category':
                        kebunItem?['lokasi'] as String? ?? 'Lokasi Tidak Ada',
                    'id': kebunItem?['id'] as String? ?? '',
                    'subtitle': 'Jumlah Tanaman: $jumlahObjekDiKebun',
                    'description': kebunItem?['deskripsi'] as String? ?? '',
                  };
                }).toList(),
                onItemTap: (context, selectedKebun) {
                  print(
                      'Kebun di-tap: ${selectedKebun['id']} - ${selectedKebun['name']}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Kebun dipilih: ${selectedKebun['name']}')),
                  );
                },
              ),
            )
          else if (_tanamanReport != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  "Tidak ditemukan daftar kebun untuk jenis tanaman ini.",
                  style: regular14.copyWith(color: dark2)),
            ),
          // --- AKHIR DAFTAR KEBUN ---

          const SizedBox(height: 16),

          // --- DAFTAR TANAMAN (OBJEK BUDIDAYA) ---
          if (daftarTanamanPerKebunWidgets.isNotEmpty)
            ...daftarTanamanPerKebunWidgets
          else if (_kebunList.isEmpty && _tanamanReport != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Tidak ada data kebun untuk menampilkan daftar tanaman.",
                style: regular14.copyWith(color: dark2),
              ),
            ),
          // --- AKHIR DAFTAR TANAMAN ---

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }

  Widget _buildPanen() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ChartWidget(
          //   firstDate: firstDate,
          //   lastDate: lastDate,
          //   data: data,
          //   title: 'Total Hasil Panen',
          //   titleStats: 'Statistik Hasil Panen Tanaman',
          //   showCounter: true,
          //   counter: 120,
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan panen tiap 2 bulan sekali, didapatkan hasil panen sangat optimal, dengan rata-rata di atas 18 buah yang dihasilkan per waktu panen.\n\nTerdapat 2 kondisi terbaik saat panen, yaitu pada bulan Agustus 2024 dan Februari 2025 dengan total panen, yaitu 20 buah.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan',
            reports: const [
              {
                'text': 'Pak Adi telah melaporkan hasil panen',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              },
              {
                'text': 'Pak Adi telah melaporkan hasil panen',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              },
            ],
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
            },
            onViewAll: () {
              context.push('/');
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikHarianCard() {
    if (_isLoadingStatistikHarian) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_statistikHarianErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error statistik: $_statistikHarianErrorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_statistikHarianData == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Data statistik harian tidak tersedia.'),
      );
    }

    // Akses data dari _statistikHarianData
    final int totalTanaman = _statistikHarianData!['totalTanaman'] as int? ?? 0;
    final int tanamanSehat = _statistikHarianData!['tanamanSehat'] as int? ?? 0;
    final int perluPerhatian =
        _statistikHarianData!['perluPerhatian'] as int? ?? 0;
    final int kritis = _statistikHarianData!['kritis'] as int? ?? 0;
    final String rekomendasi =
        _statistikHarianData!['rekomendasi'] as String? ??
            'Tidak ada rekomendasi.';
    final double persentaseSehat =
        (_statistikHarianData!['persentaseSehat'] as num?)?.toDouble() ?? 0.0;
    final double persentasePerluPerhatian =
        (_statistikHarianData!['persentasePerluPerhatian'] as num?)
                ?.toDouble() ??
            0.0;
    final double persentaseKritis =
        (_statistikHarianData!['persentaseKritis'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Kesehatan Tanaman',
                style: bold16.copyWith(color: dark1),
              ),
              const SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Tanaman:',
                      style: medium14.copyWith(color: dark2)),
                  Text('$totalTanaman', style: bold14.copyWith(color: dark1)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tanaman Sehat:',
                      style: medium14.copyWith(color: green1)),
                  Text('$tanamanSehat (${persentaseSehat.toStringAsFixed(1)}%)',
                      style: bold14.copyWith(color: green1)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Perlu Perhatian:',
                      style: medium14.copyWith(color: Colors.orange)),
                  Text(
                      '$perluPerhatian (${persentasePerluPerhatian.toStringAsFixed(1)}%)',
                      style: bold14.copyWith(color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kritis:', style: medium14.copyWith(color: red)),
                  Text('$kritis (${persentaseKritis.toStringAsFixed(1)}%)',
                      style: bold14.copyWith(color: red)),
                ],
              ),
              const SizedBox(height: 12.0),
              const Divider(),
              const SizedBox(height: 8.0),
              Text(
                'Rekomendasi:',
                style: medium14.copyWith(color: dark1),
              ),
              const SizedBox(height: 4.0),
              Text(
                rekomendasi,
                style: regular14.copyWith(color: dark2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSkorTanamanList() {
    if (_isLoadingStatistikHarian) {
      return const SizedBox.shrink();
    }
    if (_statistikHarianData == null ||
        _statistikHarianData!['detailTanaman'] == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Detai tanaman tidak tersedia.'),
      );
    }

    final List<dynamic> listTanaman =
        _statistikHarianData!['detailTanaman'] as List<dynamic>;

    if (listTanaman.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Tidak ada data tanaman individual untuk ditampilkan.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            'Rincian Status per Tanaman',
            style: bold16.copyWith(color: dark1),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listTanaman.length,
          itemBuilder: (context, index) {
            final tanaman = listTanaman[index] as Map<String, dynamic>;
            final String nama = tanaman['namaId'] as String? ?? 'Tanpa Nama';
            final String status =
                tanaman['statusKlasifikasi'] as String? ?? 'N/A';
            final String alasan =
                tanaman['alasanStatusKlasifikasi'] as String? ??
                    'Tidak diketahui';

            Color statusColor = dark2;
            if (status == 'Sehat') {
              statusColor = green1;
            }
            if (status == 'Perlu Perhatian') statusColor = Colors.orange;
            if (status == 'Kritis') {
              statusColor = red;
            }

            String subtitleText = 'Status: $status';
            if (alasan.isNotEmpty) {
              subtitleText += '\nAlasan: \n$alasan';
            }

            return Tooltip(
              message: alasan,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: ListTile(
                    title: Text(nama, style: medium14),
                    subtitle: Text(subtitleText,
                        style: regular12.copyWith(color: statusColor)),
                    onTap: () {
                      print("Tanaman ${tanaman['id']} - $nama di-tap");
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _generateStatistikRangkumanText() {
    if (_selectedChartDateRange == null) {
      return "Silakan pilih rentang tanggal untuk melihat rangkuman statistik.";
    }

    // Format tanggal untuk rentang utama
    final DateFormat rangeFormatter = DateFormat('d MMM yyyy');
    final String startDateFormatted =
        rangeFormatter.format(_selectedChartDateRange!.start);
    final String endDateFormatted =
        rangeFormatter.format(_selectedChartDateRange!.end);
    String rangkuman =
        "Berdasarkan statistik pelaporan pada periode $startDateFormatted hingga $endDateFormatted:\n\n";

    // 1. Rangkuman Laporan Harian
    if (_isLoadingLaporanHarianChart) {
      rangkuman += "Statistik laporan harian sedang dimuat...\n\n";
    } else if (_errorLaporanHarianChart != null) {
      rangkuman +=
          "Tidak dapat memuat statistik laporan harian: $_errorLaporanHarianChart\n\n";
    } else if (_laporanHarianChartDataPoints.isEmpty) {
      rangkuman += "Tidak ada data laporan harian untuk periode ini.\n\n";
    } else {
      num totalLaporan = 0;
      for (var dataPoint in _laporanHarianChartDataPoints) {
        totalLaporan += (dataPoint['jumlahLaporan'] as num?) ?? 0;
      }

      rangkuman += "Telah diterima total $totalLaporan laporan harian. ";

      if (_selectedChartFilterType == ChartFilterType.weekly ||
          _selectedChartFilterType == ChartFilterType.custom) {
        if (_laporanHarianChartDataPoints.isNotEmpty) {
          double rataRataLaporan =
              totalLaporan / _laporanHarianChartDataPoints.length;
          rangkuman +=
              "Dengan rata-rata ${rataRataLaporan.toStringAsFixed(1)} laporan per hari. ";

          // Cari hari min & max laporan
          Map<String, dynamic> minLaporanItem =
              _laporanHarianChartDataPoints.reduce((curr, next) =>
                  ((curr['jumlahLaporan'] as num?) ?? double.infinity) <
                          ((next['jumlahLaporan'] as num?) ?? double.infinity)
                      ? curr
                      : next);
          Map<String, dynamic> maxLaporanItem =
              _laporanHarianChartDataPoints.reduce((curr, next) =>
                  ((curr['jumlahLaporan'] as num?) ?? double.negativeInfinity) >
                          ((next['jumlahLaporan'] as num?) ??
                              double.negativeInfinity)
                      ? curr
                      : next);

          try {
            final DateFormat dayMonthFormatter = DateFormat('d MMMM');
            String minDayFormatted = dayMonthFormatter
                .format(DateTime.parse(minLaporanItem['period']));
            String maxDayFormatted = dayMonthFormatter
                .format(DateTime.parse(maxLaporanItem['period']));

            rangkuman +=
                "Pelaporan terendah pada tanggal $minDayFormatted (${minLaporanItem['jumlahLaporan']}) dan tertinggi pada tanggal $maxDayFormatted (${maxLaporanItem['jumlahLaporan']}).";
          } catch (e) {
            rangkuman +=
                "Detail hari terendah/tertinggi tidak dapat ditampilkan.";
          }
        }
      }
      rangkuman += "\n\n";
    }

    // 2. Rangkuman Penyiraman
    if (_isLoadingPenyiramanChart) {
      rangkuman += "Statistik penyiraman sedang dimuat...\n\n";
    } else if (_errorPenyiramanChart != null) {
      rangkuman +=
          "Tidak dapat memuat statistik penyiraman: $_errorPenyiramanChart\n\n";
    } else if (_penyiramanChartDataPoints.isEmpty) {
      rangkuman += "Tidak ada data penyiraman untuk periode ini.\n\n";
    } else {
      num totalPenyiraman = 0;
      for (var dataPoint in _penyiramanChartDataPoints) {
        totalPenyiraman += (dataPoint['jumlahPenyiraman'] as num?) ?? 0;
      }
      rangkuman +=
          "Total frekuensi penyiraman tanaman adalah $totalPenyiraman kali. ";
      if ((_selectedChartFilterType == ChartFilterType.weekly ||
              _selectedChartFilterType == ChartFilterType.custom) &&
          _penyiramanChartDataPoints.isNotEmpty) {
        double rataRataPenyiraman =
            totalPenyiraman / _penyiramanChartDataPoints.length;
        rangkuman +=
            "Rata-rata ${rataRataPenyiraman.toStringAsFixed(1)} kali per hari.";
      }
      rangkuman += "\n\n";
    }

    // 3. Rangkuman Pemberian Nutrisi (Pupuk)
    if (_isLoadingNutrisiChart) {
      rangkuman += "Statistik pemberian nutrisi sedang dimuat...\n\n";
    } else if (_errorNutrisiChart != null) {
      rangkuman +=
          "Tidak dapat memuat statistik pemberian nutrisi: $_errorNutrisiChart\n\n";
    } else if (_nutrisiChartDataPoints.isEmpty) {
      rangkuman += "Tidak ada data pemberian pupuk untuk periode ini.\n\n";
    } else {
      num totalNutrisi = 0;
      for (var dataPoint in _nutrisiChartDataPoints) {
        totalNutrisi +=
            (dataPoint['jumlahKejadianPemberianPupuk'] as num?) ?? 0;
      }
      rangkuman +=
          "Total frekuensi pemberian pupuk adalah $totalNutrisi kali. ";
      if ((_selectedChartFilterType == ChartFilterType.weekly ||
              _selectedChartFilterType == ChartFilterType.custom) &&
          _nutrisiChartDataPoints.isNotEmpty) {
        double rataRataNutrisi = totalNutrisi / _nutrisiChartDataPoints.length;
        rangkuman +=
            "Rata-rata ${rataRataNutrisi.toStringAsFixed(1)} kali per hari.";
      }
      rangkuman += "\n\n";
    }

    rangkuman +=
        "Catatan: Statistik detail untuk item lain seperti repotting, vitamin, atau disinfektan spesifik mungkin memerlukan laporan terpisah atau sudah termasuk dalam ringkasan kesehatan tanaman secara umum (jika tersedia).";

    return rangkuman.trim();
  }

  Widget _buildHarian() {
    // Data untuk Chart Laporan Harian
    List<double> laporanHarianValues = _laporanHarianChartDataPoints
        .map<double>((e) => (e['jumlahLaporan'] as num?)?.toDouble() ?? 0.0)
        .toList();

    // Data untuk Chart Penyiraman
    List<double> penyiramanValues = _penyiramanChartDataPoints
        .map<double>((e) => (e['jumlahPenyiraman'] as num?)?.toDouble() ?? 0.0)
        .toList();

    // Data untuk Chart Nutrisi
    List<double> nutrisiValues = _nutrisiChartDataPoints
        .map<double>((e) =>
            (e['jumlahKejadianPemberianPupuk'] as num?)?.toDouble() ?? 0.0)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Chart untuk Laporan Harian
          if (_isLoadingLaporanHarianChart)
            const Center(child: CircularProgressIndicator())
          else if (_errorLaporanHarianChart != null)
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error Laporan Harian: $_errorLaporanHarianChart',
                    style: const TextStyle(color: Colors.red)))
          else if (laporanHarianValues.isNotEmpty &&
              _laporanHarianChartXLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ChartWidget(
                titleStats: 'Statistik Laporan Harian',
                data: laporanHarianValues,
                xLabels: _laporanHarianChartXLabels,
                onDateIconPressed: _showDateFilterDialog,
                showFilterControls: true,
                selectedChartFilterType: _selectedChartFilterType,
                displayedDateRangeText: formattedDisplayedDateRange,
                onChartFilterTypeChanged: (ChartFilterType? newValue) {
                  if (newValue != null &&
                      newValue != _selectedChartFilterType) {
                    setState(() {
                      _selectedChartFilterType = newValue;
                      final DateTime now = DateTime.now();
                      if (newValue == ChartFilterType.monthly) {
                        _selectedChartDateRange = DateTimeRange(
                            start: DateTime(now.year, now.month - 5,
                                1), // Contoh: 6 bulan terakhir
                            end: DateTime(now.year, now.month + 1, 0));
                      } else if (newValue == ChartFilterType.yearly) {
                        _selectedChartDateRange = DateTimeRange(
                            start: DateTime(
                                now.year - 4, 1, 1), // Contoh: 5 tahun terakhir
                            end: DateTime(now.year, 12, 31));
                      } else {
                        // weekly or custom
                        _selectedChartDateRange = DateTimeRange(
                            start: now.subtract(const Duration(days: 6)),
                            end: now);
                      }
                    });
                    _fetchAllReportChartsData(); // Panggil fetch data untuk semua chart
                  }
                },
              ),
            )
          else
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada data statistik laporan harian.'))),

          // Chart untuk Penyiraman
          if (_isLoadingPenyiramanChart)
            const Center(child: CircularProgressIndicator())
          else if (_errorPenyiramanChart != null)
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error Penyiraman: $_errorPenyiramanChart',
                    style: const TextStyle(color: Colors.red)))
          else if (penyiramanValues.isNotEmpty &&
              _penyiramanChartXLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ChartWidget(
                titleStats: 'Statistik Penyiraman Tanaman',
                data: penyiramanValues,
                xLabels: _penyiramanChartXLabels,
                showFilterControls: false,
              ),
            )
          else
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada data statistik penyiraman.'))),

          // Chart untuk Pemberian Nutrisi
          if (_isLoadingNutrisiChart)
            const Center(child: CircularProgressIndicator())
          else if (_errorNutrisiChart != null)
            Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error Nutrisi: $_errorNutrisiChart',
                    style: const TextStyle(color: Colors.red)))
          else if (nutrisiValues.isNotEmpty && _nutrisiChartXLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ChartWidget(
                titleStats: 'Statistik Pemberian Nutrisi',
                data: nutrisiValues,
                xLabels: _nutrisiChartXLabels,
                showFilterControls: false,
              ),
            )
          else
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child:
                        Text('Tidak ada data statistik pemberian nutrisi.'))),

          const SizedBox(height: 12),
          _buildStatistikHarianCard(),
          _buildDetailSkorTanamanList(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                const SizedBox(height: 12),

                // Cek jika salah satu chart sedang loading untuk menampilkan pesan loading rangkuman
                (_isLoadingLaporanHarianChart ||
                            _isLoadingPenyiramanChart ||
                            _isLoadingNutrisiChart) &&
                        (_laporanHarianChartDataPoints.isEmpty &&
                            _penyiramanChartDataPoints.isEmpty &&
                            _nutrisiChartDataPoints.isEmpty)
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Text("Memuat rangkuman statistik..."),
                      ))
                    : Text(
                        _generateStatistikRangkumanText(),
                        style: regular14.copyWith(color: dark2),
                      )
              ],
            ),
          ),
          const SizedBox(height: 16),
          // --- RIWAYAT PELAPORAN UMUM (DINAMIS) ---
          if (_isLoadingRiwayatPelaporanUmum)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_errorRiwayatPelaporanUmum != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Error Riwayat Pelaporan: $_errorRiwayatPelaporanUmum',
                  style: const TextStyle(color: Colors.red)),
            )
          else if (_riwayatPelaporanUmum.isNotEmpty)
            NewestReports(
              title: 'Riwayat Pelaporan',
              reports: _riwayatPelaporanUmum.map((item) {
                return {
                  'id': item['laporanId'] as String? ?? '',
                  'text': item['judul'] as String? ??
                      (item['text'] as String? ?? 'Laporan'),
                  'subtext': 'Oleh: ${item['petugasNama'] as String? ?? 'N/A'}',
                  'icon':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'time': item['time'],
                };
              }).toList(),
              onItemTap: (context, tappedItem) {
                final laporanId = tappedItem['id']?.toString();
                if (laporanId != null && laporanId.isNotEmpty) {
                  context.push('/detail-laporan/$laporanId');
                } else {
                  _showErrorSnackbar("Detail laporan tidak tersedia.");
                }
              },
              mode: NewestReportsMode.full,
              titleTextStyle: bold18.copyWith(color: dark1),
              reportTextStyle: medium12.copyWith(color: dark1),
              timeTextStyle: regular12.copyWith(color: dark2),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  'Tidak ada riwayat pelaporan untuk ditampilkan saat ini.'),
            ),

          const SizedBox(height: 12),

          // --- RIWAYAT PEMBERIAN PUPUK (DINAMIS) ---
          if (_isLoadingRiwayatPemberianPupuk)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_errorRiwayatPemberianPupuk != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error Riwayat Nutrisi: $_errorRiwayatPemberianPupuk',
                  style: const TextStyle(color: Colors.red)),
            )
          else if (_riwayatPemberianPupuk.isNotEmpty)
            ListItem(
              title: 'Riwayat Pemberian Pupuk',
              type: 'history',
              items: _riwayatPemberianPupuk.map((item) {
                return {
                  'id': item['laporanId'] as String? ?? '',
                  'name': "${item['name'] ?? 'Nutrisi'}",
                  'category': (item['category'] as String?) ?? 'Nutrisi',
                  'image':
                      item['gambar'] as String? ?? 'assets/images/appIcon.png',
                  'person': item['person'] as String? ?? 'N/A',
                  'date': _formatDisplayDate(item['date'] as String? ?? ''),
                  'time': _formatDisplayTime(item['time'] as String? ?? ''),
                };
              }).toList(),
              onItemTap: (context, tappedItem) {
                final laporanId = tappedItem['id']?.toString();
                if (laporanId != null && laporanId.isNotEmpty) {
                  context.push('/detail-laporan/$laporanId');
                } else {
                  _showErrorSnackbar("Detail laporan terkait tidak tersedia.");
                }
              },
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                  'Tidak ada riwayat pemberian pupuk untuk ditampilkan saat ini.'),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSakit() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ChartWidget(
          //   firstDate: firstDate,
          //   lastDate: lastDate,
          //   data: data,
          //   title: 'Total Tanaman Sakit',
          //   titleStats: 'Statistik Tanaman Sakit',
          //   showCounter: true,
          //   textCounter: 'Tanaman Sakit',
          //   counter: 2,
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, didapatkan 2 tanaman melon dengan kondisi sakit. Penyakit tanaman yang dilaporkan adalah Embun tepung.\n\nDengan deskripsi laporan sebagai berikut:\n\nTerdapat lapisan putih seperti bedak/tepung \n- Biasanya muncul di permukaan daun bagian atas.\n- Bisa meluas ke batang dan buah jika tidak segera ditangani.\n\nDaun menguning dan mengering \n- Setelah muncul bercak putih, daun akan berubah warna menjadi kuning, lalu mengering.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan',
            reports: const [
              {
                'text': 'Pak Adi telah melaporkan tanaman sakit',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              }
            ],
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
            },
            onViewAll: () {
              context.push('/');
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
        ],
      ),
    );
  }

  Widget _buildMati() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ChartWidget(
          //   firstDate: firstDate,
          //   lastDate: lastDate,
          //   data: data,
          //   title: 'Total Tanaman Mati',
          //   titleStats: 'Statistik Tanaman Mati',
          //   showCounter: true,
          //   textCounter: 'Tanaman Mati',
          //   counter: 2,
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, ditemukan 2 tanaman melon sakit dengan deskripsi kekurangan nutrisi.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan',
            reports: const [
              {
                'text': 'Pak Adi telah melaporkan tanaman mati',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              }
            ],
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
            },
            onViewAll: () {
              context.push('/');
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrisi() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ChartWidget(
          //   firstDate: firstDate,
          //   lastDate: lastDate,
          //   data: data,
          //   titleStats: 'Statistik Pemberian Nutrisi Tanaman',
          //   showCounter: true,
          //   textCounter: 'Data Pemberian Nutrisi',
          //   counter: 20,
          // ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rangkuman Statistik",
                    style: bold18.copyWith(color: dark1)),
                const SizedBox(height: 12),
                Text(
                  "Berdasarkan statistik pelaporan pada tanggal 12-17 Februari 2025, didapatkan 20 laporan pemberian nutrisi dengan rata-rata 4 laporan per hari.",
                  style: regular14.copyWith(color: dark2),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          NewestReports(
            title: 'Riwayat Pelaporan',
            reports: const [
              {
                'text': 'Pak Adi telah melaporkan pemberian nutrisi',
                'icon': 'assets/icons/goclub.svg',
                'time': 'unknown',
              }
            ],
            onItemTap: (context, item) {
              final name = item['text'] ?? '';
              context.push('/detail-laporan/$name');
            },
            onViewAll: () {
              context.push('/');
            },
            mode: NewestReportsMode.full,
            titleTextStyle: bold18.copyWith(color: dark1),
            reportTextStyle: medium12.copyWith(color: dark1),
            timeTextStyle: regular12.copyWith(color: dark2),
          ),
          const SizedBox(height: 12),
          ListItem(
            title: 'Riwayat Pemberian Nutrisi',
            type: 'history',
            items: const [
              {
                'name': 'Pupuk A - Dosis 4 Kg',
                'category': 'Pupuk',
                'image': 'assets/images/pupuk.jpg',
                'person': 'Pak Adi',
                'date': 'Senin, 22 Apr 2025',
                'time': '10:45',
              },
            ],
            onItemTap: (context, item) {
              final name = item['name'] ?? '';
              context.push('/detail-laporan/$name');
            },
          ),
        ],
      ),
    );
  }
}
