import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/chart_widget.dart';

class GradeSummaryScreen extends StatefulWidget {
  final String komoditasId;

  const GradeSummaryScreen({super.key, required this.komoditasId});

  @override
  State<GradeSummaryScreen> createState() => _GradeSummaryScreenState();
}

class _GradeSummaryScreenState extends State<GradeSummaryScreen> {
  final LaporanService _laporanService = LaporanService();
  final KomoditasService _komoditasService = KomoditasService();

  Map<String, dynamic>? _summaryData;
  Map<String, dynamic>? _komoditasDetail;
  bool _isLoading = true;

  // Filter parameters
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchKomoditasDetail();
    _fetchGradeSummary();
  }

  Future<void> _fetchKomoditasDetail() async {
    try {
      final response =
          await _komoditasService.getKomoditasById(widget.komoditasId);
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _komoditasDetail = response['data'];
        });
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Gagal memuat detail komoditas: $e');
      }
    }
  }

  Future<void> _fetchGradeSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _laporanService.getGradeSummaryByKomoditas(
        komoditasId: widget.komoditasId,
        startDate: _startDate?.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
      );

      if (response['status'] == true) {
        setState(() {
          _summaryData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          showAppToast(context,
              response['message'] ?? 'Gagal memuat data summary grade');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();

    // Select start date
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now.subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Pilih Tanggal Mulai',
    );

    if (pickedStartDate != null) {
      // Select end date
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? now,
        firstDate: pickedStartDate,
        lastDate: now,
        helpText: 'Pilih Tanggal Akhir',
      );

      if (pickedEndDate != null) {
        setState(() {
          _startDate = pickedStartDate;
          _endDate = pickedEndDate;
        });
        _fetchGradeSummary();
      }
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _fetchGradeSummary();
  }

  List<ChartData> _getChartData() {
    if (_summaryData == null) return [];

    final gradeSummary = _summaryData!['gradeSummary'] as List<dynamic>? ?? [];
    final List<Color> colors = [green1, green2, yellow, yellow2, blue1, red];

    return gradeSummary.asMap().entries.map((entry) {
      final index = entry.key;
      final grade = entry.value;
      return ChartData(
        label: grade['gradeNama'] ?? 'N/A',
        value: (grade['totalJumlah'] as num?)?.toInt() ?? 0,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  Widget _buildHeaderCard() {
    if (_summaryData == null) return const SizedBox.shrink();

    final komoditas = _summaryData!['komoditas'];
    final periodeSummary = _summaryData!['periodeSummary'];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: green1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category, color: green1, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      komoditas['nama'] ?? 'N/A',
                      style: bold16.copyWith(color: dark1),
                    ),
                    Text(
                      'Satuan panen: ${komoditas['satuan']['nama']} (${komoditas['satuan']['lambang']})',
                      style: regular14.copyWith(color: dark2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: green4.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem('Total Laporan',
                        '${periodeSummary['totalHarvestCount']}'),
                    _buildSummaryItem('Total Panen',
                        '${periodeSummary['totalHarvestAmount']} ${komoditas['satuan']['lambang']}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem('Rata-rata/Panen',
                        '${periodeSummary['averagePerHarvest']} ${komoditas['satuan']['lambang']}'),
                    _buildSummaryItem(
                        'Jenis Grade', '${_summaryData!['totalGradeTypes']}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: regular12.copyWith(color: dark2)),
        const SizedBox(height: 2),
        Text(value, style: bold14.copyWith(color: dark1)),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Periode', style: bold18.copyWith(color: dark1)),
              if (_startDate != null)
                TextButton(
                  onPressed: _clearDateFilter,
                  child: Text('Hapus Filter',
                      style: medium14.copyWith(color: red)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            onPressed: _selectDateRange,
            buttonText: _startDate != null && _endDate != null
                ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
                : 'Pilih Periode Waktu',
            backgroundColor: _startDate != null ? green1 : grey,
            textColor: _startDate != null ? white : dark1,
            textStyle:
                semibold16.copyWith(color: _startDate != null ? white : dark1),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeDetailList() {
    if (_summaryData == null) return const SizedBox.shrink();

    final gradeSummary = _summaryData!['gradeSummary'] as List<dynamic>? ?? [];
    final komoditas = _summaryData!['komoditas'];

    if (gradeSummary.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/icons/set/fruitbag-filled.png',
                width: 48,
                height: 48,
                color: grey,
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada data grade',
                style: medium14.copyWith(color: dark2),
              ),
              Text(
                'Belum ada laporan panen dengan grade untuk periode ini',
                style: regular12.copyWith(color: dark2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Detail Grade', style: bold18.copyWith(color: dark1)),
        ),
        ...gradeSummary.asMap().entries.map((entry) {
          final index = entry.key;
          final grade = entry.value;
          final isLast = index == gradeSummary.length - 1;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                          color: dark4.withValues(alpha: 0.3), width: 0.5),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: [
                      green1,
                      green2,
                      yellow,
                      yellow2,
                      blue1,
                      red
                    ][index % 6],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        grade['gradeNama'] ?? 'N/A',
                        style: bold14.copyWith(color: dark1),
                      ),
                      if (grade['gradeDeskripsi'] != null &&
                          grade['gradeDeskripsi'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: _buildExpandableText(grade['gradeDeskripsi']),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${grade['totalJumlah'] ?? 0} ${komoditas['satuan']?['lambang'] ?? ''}',
                      style: bold14.copyWith(color: green1),
                    ),
                    Text(
                      '${grade['persentaseTotal'] ?? 0}% dari total',
                      style: regular12.copyWith(color: dark2),
                    ),
                    Text(
                      'Rata-rata: ${grade['averagePerHarvest'] ?? 0} ${komoditas['satuan']?['lambang'] ?? ''}/panen',
                      style: regular12.copyWith(color: dark2),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExpandableText(String text) {
    const int maxLength = 50;

    if (text.length <= maxLength) {
      return Text(
        text,
        style: regular12.copyWith(color: dark2),
      );
    }

    return _ExpandableText(text: text);
  }

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
          title: Header(
            headerType: HeaderType.back,
            title: 'Detail Grade',
            greeting: _komoditasDetail?['nama'] ?? 'Loading...',
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchGradeSummary,
        color: green1,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    _buildFilterSection(),
                    if (_summaryData != null) ...[
                      ChartWidget(
                        title: 'Distribusi Grade',
                        data: _getChartData(),
                        height: 200,
                      ),
                      _buildGradeDetailList(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool isExpanded = false;
  static const int maxLength = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded
              ? widget.text
              : '${widget.text.substring(0, maxLength)}...',
          style: regular12.copyWith(color: dark2),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? 'Tampilkan lebih sedikit' : 'Tampilkan lebih banyak',
            style: medium10.copyWith(color: green1),
          ),
        ),
      ],
    );
  }
}
