import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_kandang_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
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

  final _step = 1;
  Map<String, dynamic>? _inventarisDetails;
  List<dynamic> _chartDataPoints = [];
  List<String> _chartXLabels = [];

  List<dynamic> _riwayatPemakaianList = [];
  int _riwayatCurrentPage = 1;
  int _riwayatTotalPages = 1;
  bool _isLoadingRiwayat = false;
  bool _isLoadingInitialData = true;
  bool _isLoadingChart = false;
  bool _isUpdatingStock = false;
  bool _isDeleting = false;

  ChartFilterType _selectedChartFilterType = ChartFilterType.weekly;
  DateTimeRange? _selectedChartDateRange;

  @override
  void initState() {
    super.initState();

    if (widget.idInventaris == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(context, 'ID Inventaris tidak ditemukan.');
          context.pop();
        }
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
      if (!mounted) return;
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
        showAppToast(context, response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  Future<void> _handleDeleteConfirmation() async {
    if (_isDeleting || !mounted) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus data inventaris ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              key: const Key('cancelButton'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              key: const Key('deleteButton'),
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteData();
    }
  }

  void _updateChartDisplayData(
      List<dynamic> rawBackendData, ChartFilterType filterType) {
    if (_selectedChartDateRange == null) {
      if (mounted) {
        setState(() {
          _chartDataPoints = [];
          _chartXLabels = [];
        });
      }
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
    if (mounted) setState(() => _isLoadingChart = true);

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
      if (!mounted) return;

      if (response['status']) {
        final List<dynamic> newChartRawData = response['data'] ?? [];
        _updateChartDisplayData(newChartRawData, _selectedChartFilterType);
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal memuat data statistik');
        _updateChartDisplayData([], _selectedChartFilterType);
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
      _updateChartDisplayData([], _selectedChartFilterType);
    } finally {
      if (mounted) setState(() => _isLoadingChart = false);
    }
  }

  Future<void> _fetchRiwayatPemakaian(
      {required int page, bool isRefresh = false}) async {
    if (widget.idInventaris == null || _isLoadingRiwayat) return;
    if (!isRefresh && page > _riwayatTotalPages) return;

    if (mounted) setState(() => _isLoadingRiwayat = true);

    try {
      final response =
          await _inventarisService.getRiwayatPemakaianInventarisPaginated(
        inventarisId: widget.idInventaris!,
        page: page,
        limit: 10,
      );
      if (!mounted) return;

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
        showAppToast(context, response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _showHewanTumbuhanDialog(String categoryName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        String greeting = 'Pelaporan Pemakaian $categoryName';
        if (categoryName == 'Vitamin' ||
            categoryName == 'Vaksin' ||
            categoryName == 'Disinfektan') {
          greeting = 'Pelaporan Pemberian $categoryName';
        } else if (categoryName == 'Pupuk') {
          greeting = 'Pelaporan Pemupukan';
        }

        return AlertDialog(
          title: const Text('Pilih Target Pemakaian'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Pemakaian "$categoryName" ini akan ditujukan untuk hewan atau tumbuhan?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              key: const Key('tumbuhanButton'),
              child: const Text('TUMBUHAN'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push('/pilih-kebun',
                    extra: PilihKebunScreen(
                      step: _step + 1,
                      tipe: 'vitamin',
                      greeting: greeting,
                    ));
              },
            ),
            TextButton(
              key: const Key('hewanButton'),
              child: const Text('HEWAN'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.push('/pilih-kandang',
                    extra: PilihKandangScreen(
                      step: _step + 1,
                      tipe: 'vitamin',
                      greeting: greeting,
                    ));
              },
            ),
            TextButton(
              key: const Key('cancelButtons'),
              child: Text('BATAL', style: TextStyle(color: red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStock(int change) async {
    if (_inventarisDetails == null || widget.idInventaris == null) return;
    num currentStockNum = _inventarisDetails!['jumlah'] ?? 0;
    num newStockNum = currentStockNum + change;

    if (newStockNum < 0) {
      showAppToast(context, 'Jumlah stok tidak bisa kurang dari 0.');
      return;
    }

    if (change > 0) {
      // Cek apakah stok saat ini TIDAK NOL
      if (currentStockNum > 0) {
        if (mounted) {
          showAppToast(
            context,
            'Habiskan dulu stok inventaris ini (stok saat ini: $currentStockNum). Stok baru hanya bisa ditambahkan jika stok sudah 0.',
            title: 'Stok Masih Tersedia',
          );
        }
        return; // Hentikan proses penambahan stok
      }
      // Jika stok saat ini adalah 0 dan change > 0, maka penambahan diizinkan dan akan dilanjutkan.
    }

    if (mounted) {
      setState(() {
        _isUpdatingStock = true;
      });
    }

    try {
      final Map<String, dynamic> payload = {
        'id': widget.idInventaris!,
        'jumlah': newStockNum,
      };

      final response = await _inventarisService.updateInventaris(payload);
      if (!mounted) return;

      if (response['status'] == true) {
        setState(() {
          if (response['data'] != null && response['data']['jumlah'] != null) {
            _inventarisDetails!['jumlah'] = response['data']['jumlah'];
            newStockNum = response['data']['jumlah'] is num
                ? response['data']['jumlah']
                : num.tryParse(response['data']['jumlah'].toString()) ??
                    newStockNum;
          } else {
            _inventarisDetails!['jumlah'] = newStockNum;
          }

          if (newStockNum == 0) {
            _inventarisDetails!['ketersediaan'] = 'Tidak Tersedia';
          } else if (currentStockNum == 0 && newStockNum > 0) {
            _inventarisDetails!['ketersediaan'] = 'Tersedia';
          }

          _fetchFilteredChartData();
          _fetchRiwayatPemakaian(page: 1, isRefresh: true);

          showAppToast(context, 'Stok berhasil diperbarui.', isError: false);
        });
      } else {
        showAppToast(context, response['message'] ?? 'Gagal memperbarui stok');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStock = false;
        });
      }
    }
  }

  Future<void> _deleteData() async {
    if (widget.idInventaris == null || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      final response =
          await _inventarisService.deleteInventaris(widget.idInventaris!);
      if (!mounted) return;

      if (response['status']) {
        showAppToast(context, 'Data inventaris berhasil dihapus.',
            isError: false);
        context.pop();
      } else {
        showAppToast(context, response['message'] ?? 'Gagal menghapus data');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
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
      if (mounted) {
        setState(() {
          _selectedChartDateRange = newRange;
        });
      }
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

        if (_selectedChartFilterType == ChartFilterType.custom &&
            range.start.year == range.end.year &&
            range.start.month == range.end.month &&
            range.start.day == range.end.day) {
          return "Penggunaan Inventaris $formattedStart";
        }

        return "Penggunaan Per $formattedStart - $formattedEnd";

      case ChartFilterType.monthly:
        formattedStart = dfMonthYear.format(range.start);
        formattedEnd = dfMonthYear.format(range.end);
        if (range.start.year == range.end.year &&
            range.start.month == range.end.month) {
          return "Penggunaan Bulan ${dfMonthYear.format(range.start)}";
        }
        return "Penggunaan $formattedStart - $formattedEnd";

      case ChartFilterType.yearly:
        formattedStart = dfYear.format(range.start);
        formattedEnd = dfYear.format(range.end);
        if (range.start.year == range.end.year) {
          return "Penggunaan Tahun ${dfYear.format(range.start)}";
        }
        return "Penggunaan $formattedStart - $formattedEnd";
    }
  }

  DateTime? get _parsedExpiryDate {
    final dateString = _inventarisDetails?['tanggalKadaluwarsa'];
    if (dateString == null) return null;
    try {
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime == null || dateTime.year < 1900) {
        return null;
      }
      return dateTime;
    } catch (e) {
      return null;
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
    final String satuanNama = satuan?['nama'] ?? '';
    final String satuanLambang = satuan?['lambang'] ?? '';
    final num jumlah = _inventarisDetails?['jumlah'] ?? 0;

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

    final DateTime? expiryDateTime = _parsedExpiryDate;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    bool showExpiryInfo = expiryDateTime?.isAfter(today) ?? false;

    bool isExpiredOrTodayOrNotSet =
        expiryDateTime != null && !(expiryDateTime.isAfter(today));

    String expiryDateString = _inventarisDetails?['tanggalKadaluwarsa'] ?? '';

    bool isKadaluwarsaTidakDiatur = expiryDateString.isNotEmpty &&
        _formatDisplayDate(expiryDateString) == 'Tidak diatur';

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
            title: 'Manajemen Inventaris',
            greeting: 'Detail Inventaris',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoadingInitialData
            ? const Center(child: CircularProgressIndicator())
            : _inventarisDetails == null
                ? Center(
                    child: Text("Data inventaris tidak ditemukan.",
                        style: regular12.copyWith(color: dark2),
                        key: const Key('noDataText')))
                : SingleChildScrollView(
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
                              infoItem("Kategori inventaris",
                                  kategori?['nama'] ?? 'Unknown'),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Jumlah Stok",
                                      style: medium14.copyWith(color: dark1)),
                                  _isUpdatingStock
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              key: const Key('removeStockButton'),
                                              icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color: (_inventarisDetails?[
                                                                  'jumlah'] ??
                                                              0) >
                                                          0
                                                      ? red
                                                      : grey,
                                                  size: 28),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                if (_inventarisDetails ==
                                                        null ||
                                                    widget.idInventaris ==
                                                        null) {
                                                  showAppToast(context,
                                                      "Data inventaris tidak ditemukan.");
                                                  return;
                                                }
                                                num currentStock =
                                                    _inventarisDetails![
                                                            'jumlah'] ??
                                                        0;
                                                final String? categoryName =
                                                    _inventarisDetails![
                                                            'kategoriInventaris']
                                                        ?['nama'];

                                                if (currentStock > 0) {
                                                  const List<String>
                                                      specialCategories = [
                                                    'Vitamin',
                                                    'Pupuk',
                                                    'Disinfektan',
                                                    'Vaksin'
                                                  ];
                                                  // Stok masih ada, arahkan ke halaman pemakaian inventaris
                                                  if (categoryName != null &&
                                                      specialCategories
                                                          .contains(
                                                              categoryName)) {
                                                    // Kategori spesial, tampilkan dialog Hewan/Tumbuhan
                                                    _showHewanTumbuhanDialog(
                                                        categoryName);
                                                  } else {
                                                    // Kategori lain, langsung ke halaman tambah pemakaian
                                                    context.push(
                                                        '/tambah-pemakaian-inventaris');
                                                  }
                                                } else {
                                                  // Stok sudah 0, tidak bisa dikurangi lagi
                                                  showAppToast(context,
                                                      'Stok sudah habis, tidak bisa dikurangi.');
                                                }
                                              },
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(
                                                jumlah is int
                                                    ? jumlah.toString()
                                                    : jumlah.toStringAsFixed(
                                                        jumlah.truncateToDouble() ==
                                                                jumlah
                                                            ? 0
                                                            : 1),
                                                style: semibold16.copyWith(
                                                    color: dark2),
                                              ),
                                            ),
                                            IconButton(
                                              key: const Key('addStockButton'),
                                              icon: Icon(
                                                  Icons.add_circle_outline,
                                                  color: green1,
                                                  size: 28),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () => _updateStock(1),
                                            ),
                                            if (satuanLambang.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Text(satuanLambang,
                                                  style: regular14.copyWith(
                                                      color: dark2)),
                                            ]
                                          ],
                                        ),
                                ],
                              ),
                              infoItem("Satuan",
                                  satuanNama.isNotEmpty ? satuanNama : ""),
                              _buildKetersediaan(
                                  "Ketersediaan inventaris", ketersediaan),
                              if (showExpiryInfo) ...[
                                infoItem("Tanggal kadaluwarsa",
                                    _formatDisplayDate(expiryDateString)),
                                if (_formatDisplayTime(expiryDateString)
                                    .isNotEmpty)
                                  infoItem("Waktu kadaluwarsa",
                                      _formatDisplayTime(expiryDateString)),
                              ] else if (isExpiredOrTodayOrNotSet) ...[
                                _buildKetersediaan(
                                    "Status Kadaluwarsa", 'kadaluwarsa'),
                                infoItem("Tanggal kadaluwarsa",
                                    _formatDisplayDate(expiryDateString)),
                                if (_formatDisplayTime(expiryDateString)
                                    .isNotEmpty)
                                  infoItem("Waktu kadaluwarsa",
                                      _formatDisplayTime(expiryDateString)),
                              ] else if (isKadaluwarsaTidakDiatur) ...[
                                infoItem("Tanggal kadaluwarsa", "Tidak diatur"),
                              ],
                              infoItem(
                                  "Tanggal didaftarkan",
                                  _formatDisplayDate(
                                      _inventarisDetails?['createdAt'])),
                              if (_formatDisplayTime(
                                      _inventarisDetails?['createdAt'])
                                  .isNotEmpty)
                                infoItem(
                                    "Waktu didaftarkan",
                                    _formatDisplayTime(
                                        _inventarisDetails?['createdAt'])),
                              const SizedBox(height: 8),
                              Text("Deskripsi inventaris",
                                  style: medium14.copyWith(color: dark1)),
                              const SizedBox(height: 8),
                              Text(
                                  _inventarisDetails?['detail'] ??
                                      'Tidak ada deskripsi',
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
                              else if (chartValues.isNotEmpty &&
                                  _chartXLabels.isNotEmpty)
                                ChartWidget(
                                  titleStats: 'Statistik Pemakaian Inventaris',
                                  data: chartValues,
                                  xLabels: _chartXLabels,
                                  onDateIconPressed: _showDateFilterDialog,
                                  showFilterControls: true,
                                  selectedChartFilterType:
                                      _selectedChartFilterType,
                                  displayedDateRangeText:
                                      formattedDisplayedDateRange,
                                  onChartFilterTypeChanged:
                                      (ChartFilterType? newValue) {
                                    if (newValue != null &&
                                        newValue != _selectedChartFilterType) {
                                      if (mounted) {
                                        setState(() {
                                          _selectedChartFilterType = newValue;
                                          final DateTime now = DateTime.now();
                                          if (newValue ==
                                              ChartFilterType.monthly) {
                                            final DateTime endDateDefault =
                                                DateTime(
                                                    now.year, now.month + 1, 0);
                                            final DateTime startDateDefault =
                                                DateTime(
                                                    now.year, now.month - 5, 1);
                                            _selectedChartDateRange =
                                                DateTimeRange(
                                                    start: startDateDefault,
                                                    end: endDateDefault);
                                          } else if (newValue ==
                                              ChartFilterType.yearly) {
                                            final DateTime endDateDefault =
                                                DateTime(now.year, 12, 31);
                                            final DateTime startDateDefault =
                                                DateTime(now.year - 2, 1, 1);
                                            _selectedChartDateRange =
                                                DateTimeRange(
                                                    start: startDateDefault,
                                                    end: endDateDefault);
                                          } else if (newValue ==
                                              ChartFilterType.weekly) {
                                            _selectedChartDateRange =
                                                DateTimeRange(
                                                    start: now.subtract(
                                                        const Duration(
                                                            days: 6)),
                                                    end: now);
                                          }
                                        });
                                      }
                                      _fetchFilteredChartData();
                                    }
                                  },
                                )
                              else
                                Center(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
                                  child: Text(
                                    key: const Key('noStatsText'),
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
                        else if (_riwayatPemakaianList.isEmpty &&
                            !_isLoadingRiwayat)
                          Center(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              key: const Key('noHistoryText'),
                              'Tidak ada riwayat pemakaian.',
                              style: medium14.copyWith(color: dark2),
                              textAlign: TextAlign.center,
                            ),
                          ))
                        else
                          ListItem(
                            key: const Key('riwayatPemakaianListItem'),
                            title: 'Riwayat Pemakaian Inventaris',
                            items: historyItemsForListItem,
                            type: "history",
                            onItemTap: (context, tappedItem) {
                              final id = tappedItem['id']?.toString();
                              if (id != null && id.isNotEmpty) {
                                context
                                    .push('/detail-pemakaian-inventaris/$id');
                              } else {
                                showAppToast(
                                    context, 'Detail riwayat tidak ditemukan.');
                              }
                            },
                          ),
                        if (_isLoadingRiwayat &&
                            _riwayatPemakaianList.isNotEmpty)
                          const Padding(
                              padding: EdgeInsets.all(16.0),
                              child:
                                  Center(child: CircularProgressIndicator())),
                        if (!_isLoadingRiwayat &&
                            _riwayatCurrentPage < _riwayatTotalPages)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomButton(
                              key: const Key('loadMoreHistoryButton'),
                              buttonText: "Muat Lebih Banyak Riwayat",
                              onPressed: () => _fetchRiwayatPemakaian(
                                  page: _riwayatCurrentPage + 1),
                              backgroundColor: green1,
                              textColor: white,
                            ),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                key: const Key('ubahDataButton'),
                onPressed: () {
                  if (_inventarisDetails != null) {
                    context.push('/tambah-inventaris',
                        extra: AddInventarisScreen(
                          onInventarisAdded: () => _fetchInitialData(),
                          isEdit: true,
                          idInventaris: widget.idInventaris,
                          inventarisData: _inventarisDetails,
                        ));
                  } else {
                    showAppToast(context, 'Data inventaris tidak ditemukan');
                  }
                },
                buttonText: 'Ubah Data',
                backgroundColor: yellow2,
                textStyle: semibold16,
                textColor: white,
              ),
              const SizedBox(height: 12),
              CustomButton(
                key: const Key('hapusDataButton'),
                onPressed: _isDeleting
                    ? null
                    : () {
                        _handleDeleteConfirmation();
                      },
                buttonText: _isDeleting ? 'Menghapus...' : 'Hapus Data',
                backgroundColor: red,
                textStyle: semibold16,
                textColor: white,
              ),
            ],
          ),
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
    if (!mounted) return;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(child: Text(label, style: medium14.copyWith(color: dark1))),
          const SizedBox(width: 10),
          Flexible(
              child: Text(
            value.isEmpty ? "-" : value,
            style: regular14.copyWith(color: dark2),
            textAlign: TextAlign.end,
          )),
        ],
      ),
    );
  }

  String _formatDisplayDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown date';
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

      if (dateTime.year < 1900) {
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
      case 'kadaluwarsa':
        backgroundColor = red.withValues(alpha: 0.1);
        textColor = red;
        displayText = 'Kadaluwarsa';
        break;
      default:
        backgroundColor = red.withValues(alpha: 0.1);
        textColor = red;
        displayText = 'Tidak Tersedia';
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
}
