import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:intl/intl.dart';

class RiwayatPemakaianScreen extends StatefulWidget {
  const RiwayatPemakaianScreen({super.key});

  @override
  State<RiwayatPemakaianScreen> createState() => _RiwayatPemakaianScreenState();
}

class _RiwayatPemakaianScreenState extends State<RiwayatPemakaianScreen> {
  final InventarisService _inventarisService = InventarisService();

  List<dynamic> _allPemakaianData = [];
  bool _isLoading = true;

  // Filter states
  String _selectedSourceTable = 'semua'; // 'semua', 'penggunaan', 'vitamin'
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchInventarisData();
  }

  Future<void> _fetchInventarisData({bool reset = false}) async {
    if (reset) {
      setState(() {
        _allPemakaianData.clear();
        _isLoading = true;
      });
    }

    try {
      final data = await _inventarisService.getRiwayatPenggunaanInventaris();

      // Combine both lists and add timestamps for sorting
      List<dynamic> combinedData = [];

      if (data['daftarPemakaian'] != null) {
        combinedData.addAll(data['daftarPemakaian']);
      }

      if (data['daftarPemakaianTerbaru'] != null) {
        combinedData.addAll(data['daftarPemakaianTerbaru']);
      }

      // Remove duplicates based on id and sourceTable combination
      final Map<String, dynamic> uniqueItems = {};
      for (var item in combinedData) {
        final key = '${item['id']}_${item['sourceTable']}';
        if (!uniqueItems.containsKey(key)) {
          uniqueItems[key] = item;
        }
      }

      // Sort by createdAt date (newest first)
      final sortedData = uniqueItems.values.toList();
      sortedData.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['createdAt']);
          final dateB = DateTime.parse(b['createdAt']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _allPemakaianData = _applyCurrentFilters(sortedData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> _applyCurrentFilters(List<dynamic> data) {
    List<dynamic> filtered = List<dynamic>.from(data);

    // Filter by source table
    if (_selectedSourceTable != 'semua') {
      filtered = filtered
          .where((item) => item['sourceTable'] == _selectedSourceTable)
          .toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((item) {
        try {
          final itemDate = DateTime.parse(item['createdAt']);
          final itemDateOnly =
              DateTime(itemDate.year, itemDate.month, itemDate.day);
          final startDateOnly = DateTime(_selectedDateRange!.start.year,
              _selectedDateRange!.start.month, _selectedDateRange!.start.day);
          final endDateOnly = DateTime(_selectedDateRange!.end.year,
              _selectedDateRange!.end.month, _selectedDateRange!.end.day);

          return itemDateOnly
                  .isAfter(startDateOnly.subtract(const Duration(days: 1))) &&
              itemDateOnly.isBefore(endDateOnly.add(const Duration(days: 1)));
        } catch (e) {
          return true;
        }
      }).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _selectedSourceTable = 'semua';
      _selectedDateRange = null;
    });
    _fetchInventarisData(reset: true);
  }

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();

    // Select start date
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateRange?.start ?? now.subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Pilih Tanggal Mulai',
    );

    if (pickedStartDate != null) {
      // Select end date
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _selectedDateRange?.end ?? now,
        firstDate: pickedStartDate,
        lastDate: now,
        helpText: 'Pilih Tanggal Akhir',
      );

      if (pickedEndDate != null) {
        setState(() {
          _selectedDateRange = DateTimeRange(
            start: pickedStartDate,
            end: pickedEndDate,
          );
        });
        _fetchInventarisData(reset: true);
      }
    }
  }

  Future<void> _selectSourceTable() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Tipe Pemakaian',
                      style: bold16.copyWith(color: dark1),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, size: 20, color: dark2),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: 3,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 0.5,
                    ),
                    itemBuilder: (context, index) {
                      final options = [
                        {'value': 'semua', 'name': 'Semua Pemakaian'},
                        {'value': 'penggunaan', 'name': 'Pemakaian Inventaris'},
                        {'value': 'vitamin', 'name': 'Pemakaian Nutrisi'},
                      ];

                      final option = options[index];
                      final isSelected =
                          _selectedSourceTable == option['value'];

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop(option['value']);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option['name']!,
                                  style: medium14.copyWith(
                                    color: isSelected ? green1 : dark1,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check, size: 18, color: green1),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedSourceTable = selected;
      });
      _fetchInventarisData(reset: true);
    }
  }

  String _getSourceTableDisplayName() {
    switch (_selectedSourceTable) {
      case 'penggunaan':
        return 'Inventaris';
      case 'vitamin':
        return 'Nutrisi';
      default:
        return 'Semua Pemakaian';
    }
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: dark1.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Data', style: bold18.copyWith(color: dark1)),
              if (_hasActiveFilters)
                TextButton(
                  onPressed: _clearFilters,
                  child: Text('Hapus Filter',
                      style: medium14.copyWith(color: red)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: _selectSourceTable,
                  buttonText: _getSourceTableDisplayName(),
                  backgroundColor:
                      _selectedSourceTable != 'semua' ? green1 : grey,
                  textColor: _selectedSourceTable != 'semua' ? white : dark1,
                  textStyle: semibold14.copyWith(
                      color: _selectedSourceTable != 'semua' ? white : dark1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: _selectDateRange,
                  buttonText: _selectedDateRange != null
                      ? '${DateFormat('d MMM yy').format(_selectedDateRange!.start)} - ${DateFormat('d MMM yy').format(_selectedDateRange!.end)}'
                      : 'Pilih Tanggal',
                  backgroundColor: _selectedDateRange != null ? green1 : grey,
                  textColor: _selectedDateRange != null ? white : dark1,
                  textStyle: semibold14.copyWith(
                      color: _selectedDateRange != null ? white : dark1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedSourceTable != 'semua' || _selectedDateRange != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              greeting: 'Riwayat Pemakaian Inventaris'),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          key: const Key('add_pemakaian_inventaris'),
          onPressed: () {
            context.push('/tambah-pemakaian-inventaris');
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchInventarisData(reset: true),
        color: green1,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildFilterSection(),
                  Expanded(
                    child: _allPemakaianData.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/set/history.png',
                                        width: 64,
                                        height: 64,
                                        color: grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tidak ada data riwayat pemakaian',
                                        style: medium14.copyWith(color: dark2),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Coba ubah filter atau tambah pemakaian baru',
                                        style: regular12.copyWith(color: dark2),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ListItem(
                                key: const Key('riwayat_pemakaian_list'),
                                title: 'Riwayat Pemakaian',
                                type: 'history',
                                items: _allPemakaianData
                                    .map((item) => {
                                          'id': item['id'],
                                          'name': item['inventarisNama'],
                                          'image': item['laporanGambar'],
                                          'person': item['petugasNama'],
                                          'date': item['laporanTanggal'],
                                          'time': item['laporanWaktu'],
                                          'laporanId': item['laporanId'],
                                          'sourceTable': item['sourceTable'],
                                        })
                                    .toList(),
                                onItemTap: (context, item) {
                                  final id = item['id'] ?? '';
                                  final laporanId = item['laporanId'] ?? '';
                                  if (item['sourceTable'] == 'vitamin') {
                                    context.push(
                                        '/detail-laporan-nutrisi/$laporanId');
                                  } else {
                                    context.push(
                                        '/detail-pemakaian-inventaris/$id');
                                  }
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
