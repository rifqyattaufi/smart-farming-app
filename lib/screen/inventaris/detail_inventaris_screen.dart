import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_enums.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/utils/custom_picker_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/chart.dart';

class DetailInventarisScreen extends StatefulWidget {
  final String? idInventaris;
  const DetailInventarisScreen({super.key, this.idInventaris});

  @override
  State<DetailInventarisScreen> createState() => _DetailInventarisScreenState();
}

class _DetailInventarisScreenState extends State<DetailInventarisScreen> {
  final InventarisService _inventarisService = InventarisService();

  Map<String, dynamic>? _inventarisDetails;
  List<dynamic> _chartDataPoints = [];
  List<String> _chartXLabels = [];

  List<dynamic> _riwayatPemakaianList = [];
  int _riwayatCurrentPage = 1;
  int _riwayatTotalPages = 1;
  bool _isLoadingRiwayat = false;
  bool _isLoadingInitialData = true;
  bool _isLoadingChart = false;

  ChartFilterType _selectedChartFilterType = ChartFilterType.weekly;
  DateTimeRange? _selectedChartDateRange;

  @override
  void initState() {
    super.initState();

    if (widget.idInventaris == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('ID Inventaris tidak valid.'),
              backgroundColor: Colors.red),
        );
        context.pop();
      });
      return;
    }

    final now = DateTime.now();
    _selectedChartDateRange =
        DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now);
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    if (widget.idInventaris == null) return;
    setState(() {
      _isLoadingInitialData = true;
    });
    try {
      final response =
          await _inventarisService.getInventarisById(widget.idInventaris!);
      if (response['status']) {
        final data = response['data'];
        setState(() {
          _inventarisDetails = data['inventaris'];
          final defaultChartRawData =
              data['defaultChartData'] as List<dynamic>? ?? [];
          _updateChartDisplayData(defaultChartRawData, ChartFilterType.weekly);
        });
        await _fetchRiwayatPemakaian(page: 1, isRefresh: true);
      } else {
        _showErrorSnackbar(
            response['message'] ?? 'Gagal memuat data inventaris');
      }
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoadingInitialData = false;
      });
    }
  }

  void _updateChartDisplayData(
      List<dynamic> rawBackendData, ChartFilterType filterType) {
    if (_selectedChartDateRange == null) {
      setState(() {
        _chartDataPoints = [];
        _chartXLabels = [];
      });
      return;
    }

    List<Map<String, dynamic>> processedDataPoints = [];
    List<String> processedXLabels = [];

    DateTime startDate = _selectedChartDateRange!.start;
    DateTime endDate = _selectedChartDateRange!.end;

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
          'stokPemakaian':
              backendEntry != null ? (backendEntry['stokPemakaian'] ?? 0) : 0,
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
          'stokPemakaian':
              backendEntry != null ? (backendEntry['stokPemakaian'] ?? 0) : 0,
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
          'stokPemakaian':
              backendEntry != null ? (backendEntry['stokPemakaian'] ?? 0) : 0,
        });
        processedXLabels.add(displayLabel);
        currentDate = DateTime(currentDate.year + 1, 1, 1);
        if (processedXLabels.length > 10) break;
      }
    }

    if (mounted) {
      setState(() {
        _chartDataPoints = processedDataPoints;
        _chartXLabels = processedXLabels;
      });
    }
  }

  Future<void> _fetchFilteredChartData() async {
    if (widget.idInventaris == null || _selectedChartDateRange == null) return;
    setState(() => _isLoadingChart = true);

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
      final response = await _inventarisService.getStatistikPemakaianInventaris(
        inventarisId: widget.idInventaris!,
        startDate: _selectedChartDateRange!.start,
        endDate: _selectedChartDateRange!.end,
        groupBy: groupBy,
      );

      if (response['status']) {
        final List<dynamic> newChartRawData = response['data'] ?? [];
        _updateChartDisplayData(newChartRawData, _selectedChartFilterType);
      } else {
        _showErrorSnackbar(response['message'] ?? 'Gagal memuat statistik');
        _updateChartDisplayData([], _selectedChartFilterType);
      }
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
      _updateChartDisplayData([], _selectedChartFilterType);
    } finally {
      setState(() => _isLoadingChart = false);
    }
  }

  Future<void> _fetchRiwayatPemakaian(
      {required int page, bool isRefresh = false}) async {
    if (widget.idInventaris == null || _isLoadingRiwayat) return;
    if (!isRefresh && page > _riwayatTotalPages) return;

    setState(() => _isLoadingRiwayat = true);

    try {
      final response =
          await _inventarisService.getRiwayatPemakaianInventarisPaginated(
        inventarisId: widget.idInventaris!,
        page: page,
        limit: 10,
      );

      if (response['status']) {
        final List<dynamic> newItems = response['data'] ?? [];
        setState(() {
          if (isRefresh) {
            _riwayatPemakaianList = newItems;
          } else {
            _riwayatPemakaianList.addAll(newItems);
          }
          _riwayatCurrentPage = response['currentPage'] ?? 1;
          _riwayatTotalPages = response['totalPages'] ?? 1;
        });
      } else {
        _showErrorSnackbar(
            response['message'] ?? 'Gagal memuat riwayat pemakaian');
      }
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoadingRiwayat = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteData() async {
    if (widget.idInventaris == null) return;
    final response =
        await _inventarisService.deleteInventaris(widget.idInventaris!);
    if (response['status']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil menghapus data inventaris'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      _showErrorSnackbar(response['message'] ?? 'Gagal menghapus data');
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
        helpText: 'Pilih Tanggal Mulai (Mingguan)',
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
      await _fetchFilteredChartData();
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
        return "Penggunaan Inventaris Per $formattedStart - $formattedEnd";

      case ChartFilterType.monthly:
        formattedStart = dfMonthYear.format(range.start);
        formattedEnd = dfMonthYear.format(range.end);
        if (range.start.year == range.end.year &&
            range.start.month == range.end.month) {
          return formattedStart;
        }
        return "Penggunaan Inventaris Per $formattedStart - $formattedEnd";

      case ChartFilterType.yearly:
        formattedStart = dfYear.format(range.start);
        formattedEnd = dfYear.format(range.end);
        if (range.start.year == range.end.year) {
          return formattedStart;
        }
        return "Penggunaan Inventaris Per $formattedStart - $formattedEnd";
    }
  }

  @override
  Widget build(BuildContext context) {
    List<double> chartValues = _chartDataPoints
        .map<double>((e) => (e['stokPemakaian'] as num?)?.toDouble() ?? 0.0)
        .toList();

    final Map<String, dynamic>? kategori =
        _inventarisDetails?['kategoriInventaris'];
    final Map<String, dynamic>? satuan =
        _inventarisDetails?['Satuan'] ?? _inventarisDetails?['satuan'];
    final String ketersediaan =
        _inventarisDetails?['ketersediaan'] ?? 'Unknown';
    final String kondisi = _inventarisDetails?['kondisi'] ?? 'Unknown';
    final String satuanNama = satuan?['nama'] ?? '';
    final String satuanLambang = satuan?['lambang'] ?? '';
    final int jumlah = _inventarisDetails?['jumlah'] ?? 0;

    if (_isLoadingInitialData) {
      return Scaffold(
          appBar: AppBar(title: const Text("Detail Inventaris")),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_inventarisDetails == null) {
      return Scaffold(
          appBar: AppBar(title: const Text("Detail Inventaris")),
          body: const Center(child: Text("Data inventaris tidak ditemukan.")));
    }

    List<Map<String, dynamic>> historyItemsForListItem =
        _riwayatPemakaianList.map((item) {
      return {
        'id': item['id'],
        'image': item['laporanGambar'],
        'name': _inventarisDetails?['nama'] ?? 'Inventaris',
        'person': item['petugasNama'],
        'date': item['laporanTanggal'],
        'time': item['laporanWaktu'],
        'jumlah': item['jumlah'],
        'laporanId': item['laporanId'],
      };
    }).toList();

    return Scaffold(
      backgroundColor: white,
      appBar: PreferredSize(
        /* ... appBar remains same ... */
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Manajemen Inventaris',
            greeting: 'Detail Inventaris',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
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
                      url: _inventarisDetails?['gambar'] ?? '',
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
                    Text("Informasi Inventaris",
                        style: bold18.copyWith(color: dark1)),
                    const SizedBox(height: 12),
                    infoItem("Nama inventaris",
                        _inventarisDetails?['nama'] ?? 'Unknown'),
                    infoItem(
                        "Kategori inventaris", kategori?['nama'] ?? 'Unknown'),
                    infoItem("Jumlah Stok",
                        '$jumlah ${satuanLambang.isNotEmpty ? satuanLambang : ""}'),
                    infoItem("Satuan", satuanNama.isNotEmpty ? satuanNama : ""),
                    _buildKetersediaan("Ketersediaan inventaris", ketersediaan),
                    _buildKondisi("Kondisi inventaris", kondisi),
                    infoItem(
                        "Tanggal kadaluwarsa",
                        _formatDisplayDate(
                            _inventarisDetails?['tanggalKadaluwarsa'])),
                    infoItem(
                        "Waktu kadaluwarsa",
                        _formatDisplayTime(
                            _inventarisDetails?['tanggalKadaluwarsa'])),
                    infoItem("Tanggal didaftarkan",
                        _formatDisplayDate(_inventarisDetails?['createdAt'])),
                    infoItem("Waktu didaftarkan",
                        _formatDisplayTime(_inventarisDetails?['createdAt'])),
                    const SizedBox(height: 8),
                    Text("Deskripsi inventaris",
                        style: medium14.copyWith(color: dark1)),
                    const SizedBox(height: 8),
                    Text(_inventarisDetails?['detail'] ?? 'Tidak ada deskripsi',
                        style: regular14.copyWith(color: dark2)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isLoadingChart)
                      const Center(child: CircularProgressIndicator())
                    else if (chartValues.isNotEmpty && _chartXLabels.isNotEmpty)
                      ChartWidget(
                        titleStats: 'Statistik Pemakaian Inventaris',
                        data: chartValues,
                        xLabels: _chartXLabels,
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
                                final DateTime endDateDefault =
                                    DateTime(now.year, now.month + 1, 0);
                                final DateTime startDateDefault =
                                    DateTime(now.year, now.month - 11, 1);
                                _selectedChartDateRange = DateTimeRange(
                                    start: startDateDefault,
                                    end: endDateDefault);
                              } else if (newValue == ChartFilterType.yearly) {
                                final DateTime endDateDefault =
                                    DateTime(now.year, 12, 31);
                                final DateTime startDateDefault =
                                    DateTime(now.year - 4, 1, 1);
                                _selectedChartDateRange = DateTimeRange(
                                    start: startDateDefault,
                                    end: endDateDefault);
                              } else if (newValue == ChartFilterType.weekly) {
                                _selectedChartDateRange = DateTimeRange(
                                    start:
                                        now.subtract(const Duration(days: 6)),
                                    end: now);
                              }
                            });
                            _fetchFilteredChartData();
                          }
                        },
                      )
                    else
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Tidak ada statistik data untuk ditampilkan.',
                          style: medium14.copyWith(color: dark2),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_riwayatPemakaianList.isEmpty &&
                  _isLoadingRiwayat &&
                  _riwayatCurrentPage == 1)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator()))
              else
                ListItem(
                  title: 'Riwayat Pemakaian Inventaris',
                  items: historyItemsForListItem,
                  type: "history",
                  onItemTap: (context, tappedItem) {
                    final laporanId = tappedItem['laporanId']?.toString();
                    if (laporanId != null && laporanId.isNotEmpty) {
                      context.push('/detail-laporan/$laporanId');
                    } else {
                      _showErrorSnackbar("Detail laporan tidak tersedia.");
                    }
                  },
                ),
              if (_isLoadingRiwayat && _riwayatPemakaianList.isNotEmpty)
                const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator())),
              if (!_isLoadingRiwayat &&
                  _riwayatCurrentPage < _riwayatTotalPages)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    buttonText: "Muat Lebih Banyak Riwayat",
                    onPressed: () =>
                        _fetchRiwayatPemakaian(page: _riwayatCurrentPage + 1),
                    backgroundColor: green1,
                    textColor: white,
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: () {
                context.push('/tambah-inventaris',
                    extra: AddInventarisScreen(
                      onInventarisAdded: () => _fetchInitialData(),
                      isEdit: true,
                      idInventaris: widget.idInventaris,
                      inventarisData: _inventarisDetails,
                    ));
              },
              buttonText: 'Ubah Data',
              backgroundColor: yellow2,
              textStyle: semibold16,
              textColor: white,
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text(
                          'Apakah Anda yakin ingin menghapus data ini?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal')),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Hapus')),
                      ],
                    );
                  },
                );
                if (shouldDelete == true) await _deleteData();
              },
              buttonText: 'Hapus Data',
              backgroundColor: red,
              textStyle: semibold16,
              textColor: white,
            ),
          ],
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingRiwayat &&
        _riwayatCurrentPage < _riwayatTotalPages) {
      _fetchRiwayatPemakaian(page: _riwayatCurrentPage + 1);
    }
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(label, style: medium14.copyWith(color: dark1))),
          const SizedBox(width: 10),
          Flexible(
              child: Text(
            value,
            style: regular14.copyWith(color: dark2),
            textAlign: TextAlign.end,
          )),
        ],
      ),
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

  Widget _buildKetersediaan(String label, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'tersedia':
        backgroundColor = green2.withValues(alpha: 0.1);
        textColor = green2;
        displayText = 'Tersedia';
        break;
      case 'tidak tersedia':
        backgroundColor = red.withValues(alpha: 0.1);
        textColor = red;
        displayText = 'Tidak Tersedia';
        break;
      case 'kadaluwarsa':
      case 'expired':
        backgroundColor = yellow.withValues(alpha: 0.1);
        textColor = yellow;
        displayText = 'Kadaluwarsa';
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        displayText = status;
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                Text(displayText, style: regular12.copyWith(color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildKondisi(String label, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    if (status.toLowerCase() == 'baik') {
      backgroundColor = green2.withValues(alpha: 0.1);
      textColor = green2;
      displayText = 'Baik';
    } else if (status.toLowerCase() == 'rusak') {
      backgroundColor = yellow.withValues(alpha: 0.1);
      textColor = yellow;
      displayText = 'Rusak';
    } else {
      backgroundColor = Colors.grey.withValues(alpha: 0.1);
      textColor = Colors.grey;
      displayText = status;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child:
                Text(displayText, style: regular12.copyWith(color: textColor)),
          ),
        ],
      ),
    );
  }
}
