import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:go_router/go_router.dart';

class HasilPanenWithGradesScreen extends StatefulWidget {
  const HasilPanenWithGradesScreen({super.key});

  @override
  State<HasilPanenWithGradesScreen> createState() =>
      _HasilPanenWithGradesScreenState();
}

class _HasilPanenWithGradesScreenState
    extends State<HasilPanenWithGradesScreen> {
  final LaporanService _laporanService = LaporanService();
  final KomoditasService _komoditasService = KomoditasService();

  List<dynamic> _harvestData = [];
  List<dynamic> _komoditasList = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;

  // Filter parameters
  String? _selectedKomoditasId;
  String? _selectedKomoditasName;
  DateTime? _startDate;
  DateTime? _endDate;

  // Pagination
  int _currentPage = 1;
  final int _limit = 10;
  bool _hasNextPage = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchKomoditasList();
    _fetchHarvestData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (_hasNextPage && !_isLoadingMore) {
        _loadMoreData();
      }
    }
  }

  Future<void> _fetchKomoditasList() async {
    try {
      // Fetch only plant-type commodities (tumbuhan)
      final response =
          await _komoditasService.getKomoditasByTipe(tipe: 'tumbuhan');
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          _komoditasList = response['data'];
        });

        // Debug: Print komoditas structure to see actual data
        if (_komoditasList.isNotEmpty) {
          if (_komoditasList.first['Satuan'] != null) {
          } else {}
          if (_komoditasList.first['JenisBudidaya'] != null) {}
        }
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Gagal memuat daftar komoditas: $e');
      }
    }
  }

  Future<void> _fetchHarvestData({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _harvestData.clear();
        _isLoading = true;
      });
    }

    try {
      final response = await _laporanService.getHasilPanenWithGrades(
        page: _currentPage,
        limit: _limit,
        komoditasId: _selectedKomoditasId,
        startDate: _startDate?.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
      );

      if (response['status'] == true) {
        final newData = response['data'] as List<dynamic>;
        final pagination = response['pagination'];

        setState(() {
          if (reset) {
            _harvestData = newData;
          } else {
            _harvestData.addAll(newData);
          }
          _hasNextPage = pagination['hasNextPage'];
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        if (mounted) {
          showAppToast(
              context, response['message'] ?? 'Gagal memuat data hasil panen');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e');
      }
    }
  }

  Future<void> _loadMoreData() async {
    if (_hasNextPage && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
      await _fetchHarvestData();
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
        _fetchHarvestData(reset: true);
      }
    }
  }

  Future<void> _selectKomoditas() async {
    if (_komoditasList.isEmpty) return;

    final selected = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Komoditas',
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
                    itemCount: _komoditasList.length + 1,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 0.5,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pop({'id': '', 'name': 'Semua Komoditas'});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Semua Komoditas',
                                    style: medium14.copyWith(
                                      color: _selectedKomoditasId == null
                                          ? green1
                                          : dark1,
                                    ),
                                  ),
                                ),
                                if (_selectedKomoditasId == null)
                                  Icon(Icons.check, size: 18, color: green1),
                              ],
                            ),
                          ),
                        );
                      }

                      final komoditas = _komoditasList[index - 1];

                      // Handle different API response structures for commodity type
                      final jenis = komoditas['jenis'] ??
                          komoditas['JenisBudidaya']?['nama'] ??
                          komoditas['jenisBudidaya']?['nama'] ??
                          'N/A';

                      final jumlah = komoditas['jumlah'] ?? 0;

                      // Handle different API response structures for unit symbol
                      final satuanLambang =
                          komoditas['Satuan']?['lambang'] ?? '';

                      // Build subtitle with safe null handling
                      final subtitle = satuanLambang.isNotEmpty
                          ? '$jenis • $jumlah $satuanLambang'
                          : '$jenis • $jumlah';

                      final isSelected =
                          _selectedKomoditasId == komoditas['id'];

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop({
                            'id': (komoditas['id'] ?? '').toString(),
                            'name': (komoditas['nama'] ?? 'N/A').toString()
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      komoditas['nama'] ?? 'N/A',
                                      style: medium14.copyWith(
                                        color: isSelected ? green1 : dark1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      style: regular12.copyWith(color: dark3),
                                    ),
                                  ],
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
        _selectedKomoditasId = selected['id']!.isEmpty ? null : selected['id'];
        _selectedKomoditasName = selected['name'];
      });
      _fetchHarvestData(reset: true);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedKomoditasId = null;
      _selectedKomoditasName = null;
      _startDate = null;
      _endDate = null;
    });
    _fetchHarvestData(reset: true);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.only(
        top: 16,
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
              if (_selectedKomoditasId != null || _startDate != null)
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
                  onPressed: _selectKomoditas,
                  buttonText: _selectedKomoditasName ?? 'Semua Komoditas',
                  backgroundColor: _selectedKomoditasId != null ? green1 : grey,
                  textColor: _selectedKomoditasId != null ? white : dark1,
                  textStyle: semibold14.copyWith(
                      color: _selectedKomoditasId != null ? white : dark1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: _selectDateRange,
                  buttonText: _startDate != null && _endDate != null
                      ? '${DateFormat('d MMM yy').format(_startDate!)} - ${DateFormat('d MMM yy').format(_endDate!)}'
                      : 'Pilih Tanggal',
                  backgroundColor: _startDate != null ? green1 : grey,
                  textColor: _startDate != null ? white : dark1,
                  textStyle: semibold14.copyWith(
                      color: _startDate != null ? white : dark1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestCard(Map<String, dynamic> harvest) {
    final grades = harvest['rincianGrade'] as List<dynamic>? ?? [];
    final hasilPanen = harvest['hasilPanen'];

    return Container(
      margin: const EdgeInsets.only(
        bottom: 6,
        left: 16,
        right: 16,
        top: 6,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: dark1.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan gambar dan info dasar
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageBuilder(
                  url: harvest['gambar'] ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      harvest['judul'] ?? 'Laporan Panen',
                      style: bold16.copyWith(color: dark1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Komoditas: ${harvest['komoditas']['nama'] ?? 'N/A'}',
                      style: medium14.copyWith(color: green1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanggal Panen: ${_formatDate(harvest['tanggalPanen'])}',
                      style: regular12.copyWith(color: dark2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info hasil panen
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dark4,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Estimasi Panen',
                        '${hasilPanen['estimasiPanen']} ${harvest['komoditas']['satuan']?['lambang'] ?? ''}'),
                    _buildInfoItem('Gagal Panen',
                        '${hasilPanen['gagalPanen']} ${harvest['komoditas']['satuan']?['lambang'] ?? ''}',
                        alignRight: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Hasil Panen',
                        '${hasilPanen['realisasiPanen']} ${harvest['komoditas']['satuan']?['lambang'] ?? ''}'),
                    _buildInfoItem(
                        'Efisiensi Panen', '${hasilPanen['efisiensiPanen']}%',
                        alignRight: true),
                  ],
                ),
              ],
            ),
          ),

          // Rincian Grade
          if (grades.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Rincian Grade', style: bold14.copyWith(color: dark1)),
            const SizedBox(height: 8),
            ...grades.map((grade) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: green4.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: green1.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(grade['gradeNama'],
                                style: medium14.copyWith(color: dark1)),
                            if (grade['gradeDeskripsi'] != null &&
                                grade['gradeDeskripsi'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: _buildExpandableText(
                                    grade['gradeDeskripsi']),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              '${grade['jumlah']} ${harvest['komoditas']['satuan']?['lambang'] ?? ''}',
                              style: bold16.copyWith(color: green1)),
                          Text('${grade['persentase']}%',
                              style: regular12.copyWith(color: dark2)),
                        ],
                      ),
                    ],
                  ),
                )),
          ],

          // Footer info
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pelapor: ${harvest['pelapor']['nama']}',
                style: regular12.copyWith(color: dark2),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to grade summary for this commodity
                  final komoditasId = harvest['komoditas']['id'];
                  context.push('/grade-summary/$komoditasId');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: green1,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Lihat Detail Grade',
                    style: regular14.copyWith(color: white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: regular12.copyWith(color: dark2)),
        const SizedBox(height: 2),
        Text(value, style: medium12.copyWith(color: dark1)),
      ],
    );
  }

  Widget _buildExpandableText(String text) {
    const int maxLength = 60;

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
          title: const Header(
            headerType: HeaderType.back,
            title: 'Laporan Perkebunan',
            greeting: 'Laporan Grade Panen',
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _fetchHarvestData(reset: true),
          color: green1,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildFilterSection(),
                    Expanded(
                      child: _harvestData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/set/fruitbag-filled.png',
                                    width: 64,
                                    height: 64,
                                    color: grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tidak ada data hasil panen',
                                    style: medium14.copyWith(color: dark2),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Coba ubah filter atau tambah laporan panen baru',
                                    style: regular12.copyWith(color: dark2),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _harvestData.length +
                                  (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _harvestData.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _buildHarvestCard(_harvestData[index]);
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

class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool isExpanded = false;
  static const int maxLength = 60;

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
