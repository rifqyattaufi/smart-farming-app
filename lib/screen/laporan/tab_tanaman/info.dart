import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/info_item.dart';

class InfoTab extends StatefulWidget {
  // Diubah menjadi StatefulWidget
  final bool isLoadingInitialData;
  final Map<String, dynamic>? tanamanReport;
  final List<dynamic> kebunList;
  final int jumlahTanaman;
  final ScrollController scrollController;
  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;

  const InfoTab({
    super.key,
    required this.isLoadingInitialData,
    required this.tanamanReport,
    required this.kebunList,
    required this.jumlahTanaman,
    required this.scrollController,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
  });

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  // State class
  static const int _increment = 3; // Jumlah item yang dimuat setiap kali
  int _displayedKebunCount = _increment;
  // Map untuk menyimpan jumlah objek budidaya yang ditampilkan per ID kebun
  final Map<String, int> _displayedObjekBudidayaCountPerKebun = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi count untuk setiap kebun jika kebunList sudah ada
    // (meskipun saat initState, widget.kebunList mungkin belum terisi penuh jika ada loading)
    _initializeObjekBudidayaCounts();
  }

  @override
  void didUpdateWidget(covariant InfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika kebunList berubah (misalnya setelah loading selesai), re-inisialisasi counts
    if (widget.kebunList != oldWidget.kebunList) {
      _initializeObjekBudidayaCounts();
    }
  }

  void _initializeObjekBudidayaCounts() {
    for (var kebunData in widget.kebunList) {
      final kebunItem = kebunData as Map<String, dynamic>;
      final kebunId = kebunItem['id'] as String? ?? UniqueKey().toString();
      // Hanya inisialisasi jika belum ada, atau reset jika diinginkan
      _displayedObjekBudidayaCountPerKebun.putIfAbsent(
          kebunId, () => _increment);
    }
  }

  void _loadMoreKebun() {
    setState(() {
      _displayedKebunCount =
          (_displayedKebunCount + _increment).clamp(0, widget.kebunList.length);
    });
  }

  void _loadMoreObjekBudidaya(String kebunId, int totalObjekBudidaya) {
    setState(() {
      int currentCount = _displayedObjekBudidayaCountPerKebun[kebunId] ?? 0;
      _displayedObjekBudidayaCountPerKebun[kebunId] =
          (currentCount + _increment).clamp(0, totalObjekBudidaya);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingInitialData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.tanamanReport == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Laporan informasi perkebunan tidak ditemukan atau gagal dimuat.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final String namaTanaman =
        widget.tanamanReport!['nama'] as String? ?? 'Tidak diketahui';
    final String namaLatin =
        widget.tanamanReport!['latin'] as String? ?? 'Tidak diketahui';
    final String gambarUtama = widget.tanamanReport!['gambar'] as String? ?? '';
    final bool isBudidaya = (widget.tanamanReport!['status'] == true ||
        widget.tanamanReport!['status'] == 1);
    final String statusBudidayaText =
        isBudidaya ? 'Budidaya' : 'Tidak Budidaya';
    final Color statusColor = isBudidaya ? green2 : red;
    final String tanggalDidaftarkan =
        widget.formatDisplayDate(widget.tanamanReport!['createdAt'] as String?);
    final String waktuDidaftarkan =
        widget.formatDisplayTime(widget.tanamanReport!['createdAt'] as String?);
    final String deskripsiTanaman =
        widget.tanamanReport!['detail'] as String? ??
            'Tidak ada deskripsi yang tersedia.';
    final String lokasiTanamanDisplay = widget.kebunList.isNotEmpty
        ? ((widget.kebunList.first as Map<String, dynamic>)['lokasi']
                as String? ??
            'Beberapa Lokasi')
        : 'Lokasi tidak spesifik';

    List<Widget> listChildren = [];

    // Bagian 1: Gambar Utama (Sama seperti sebelumnya)
    listChildren.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: DottedBorder(
          color: green1,
          strokeWidth: 1.5,
          dashPattern: const [6, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ImageBuilder(
              url: gambarUtama,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );

    // Bagian 2: Informasi Jenis Tanaman (Sama seperti sebelumnya)
    listChildren.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informasi Jenis Tanaman 🌱",
                style: bold18.copyWith(color: dark1)),
            const SizedBox(height: 12),
            InfoItemWidget("Nama jenis tanaman", value: namaTanaman),
            InfoItemWidget("Nama latin", value: namaLatin),
            InfoItemWidget("Lokasi tanaman", value: lokasiTanamanDisplay),
            InfoItemWidget("Jumlah tanaman",
                value: "${widget.jumlahTanaman} bibit"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status tanaman",
                      style: medium14.copyWith(color: dark1)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusBudidayaText,
                      style: regular12.copyWith(
                          color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            InfoItemWidget("Tanggal didaftarkan", value: tanggalDidaftarkan),
            InfoItemWidget("Waktu didaftarkan", value: waktuDidaftarkan),
            const SizedBox(height: 10),
            Text("Deskripsi tanaman:", style: medium14.copyWith(color: dark1)),
            const SizedBox(height: 6),
            Text(
              deskripsiTanaman,
              style: regular14.copyWith(color: dark2, height: 1.4),
            ),
          ],
        ),
      ),
    );

    // Bagian 3: Daftar Kebun Budidaya (Dengan "Muat Lagi")
    if (widget.kebunList.isNotEmpty) {
      final kebunToShow = widget.kebunList.take(_displayedKebunCount).toList();
      listChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListItem(
            title: 'Daftar Kebun Budidaya 🏞️',
            type: 'basic',
            items: kebunToShow.map((kebun) {
              // Menggunakan kebunToShow
              final kebunItem = kebun as Map<String, dynamic>;
              final jumlahObjekDiKebun =
                  (kebunItem['ObjekBudidayas'] as List<dynamic>?)?.length ??
                      (kebunItem['jumlah'] as int?) ??
                      0;
              return {
                'name': kebunItem['nama'] as String? ?? 'Kebun Tanpa Nama',
                'icon': kebunItem['gambar'] as String? ??
                    'assets/images/default_kebun.png',
                'category':
                    kebunItem['lokasi'] as String? ?? 'Lokasi Tidak Ada',
                'id': kebunItem['id'] as String? ?? UniqueKey().toString(),
                'subtitle': 'Jumlah Tanaman: $jumlahObjekDiKebun bibit',
                'description': kebunItem['deskripsi'] as String? ??
                    'Tidak ada deskripsi kebun.',
              };
            }).toList(),
            onItemTap: (ctx, selectedKebun) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    content: Text('Kebun dipilih: ${selectedKebun['name']}')),
              );
            },
          ),
        ),
      );

      if (_displayedKebunCount < widget.kebunList.length) {
        listChildren.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextButton(
            onPressed: _loadMoreKebun,
            child: Text("Muat lagi...",
                style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ));
      }
    } else {
      listChildren.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("Tidak ditemukan daftar kebun untuk jenis tanaman ini.",
              style: regular14.copyWith(color: dark2)),
        ),
      );
    }

    // Bagian 4: Daftar Tanaman per Kebun (Objek Budidaya - Dengan "Muat Lagi")
    // Menampilkan objek budidaya hanya untuk kebun yang sudah ditampilkan
    final displayedKebunData = widget.kebunList.take(_displayedKebunCount);

    for (var kebunData in displayedKebunData) {
      final kebunItem = kebunData as Map<String, dynamic>;
      final String kebunId = kebunItem['id'] as String? ??
          'unknown_kebun_${kebunItem.hashCode}'; // ID unik jika null
      final List<dynamic> semuaObjekBudidayaDiKebunIni =
          (kebunItem['ObjekBudidayas'] as List<dynamic>?) ?? [];

      // Pastikan count untuk kebun ini sudah diinisialisasi
      _displayedObjekBudidayaCountPerKebun.putIfAbsent(
          kebunId, () => _increment);
      final int currentDisplayLimit =
          _displayedObjekBudidayaCountPerKebun[kebunId]!;
      final objekBudidayaToShow =
          semuaObjekBudidayaDiKebunIni.take(currentDisplayLimit).toList();

      if (semuaObjekBudidayaDiKebunIni.isNotEmpty) {
        listChildren.add(Padding(
          padding: const EdgeInsets.only(
              top: 0, bottom: 0), // Mengurangi bottom padding di sini
          child: ListItem(
            title:
                'Detail Tanaman di ${kebunItem['nama'] ?? 'Kebun Tanpa Nama'}',
            type: 'detailed',
            items: objekBudidayaToShow.map((item) {
              // Menggunakan objekBudidayaToShow
              final plantItem = item as Map<String, dynamic>;
              return {
                'name': plantItem['namaId'] as String? ??
                    'Tanaman (ID: ${plantItem['id']?.substring(0, 6) ?? 'N/A'})',
                'icon': gambarUtama,
                'category': '$namaTanaman (${kebunItem['nama']})',
                'id': plantItem['id'] as String? ?? UniqueKey().toString(),
                'subtitle':
                    'Kode: ${plantItem['kode'] as String? ?? '-'} | Status: ${plantItem['statusKondisi'] as String? ?? 'Baik'}',
                'description': plantItem['deskripsi'] as String? ??
                    'Deskripsi objek budidaya tidak tersedia.',
                'tanggalTanam': widget
                    .formatDisplayDate(plantItem['tanggalTanam'] as String?),
              };
            }).toList(),
            onItemTap: (ctx, selectedPlant) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                    content: Text(
                        'Objek budidaya dipilih: ${selectedPlant['name']}')),
              );
            },
          ),
        ));

        if (currentDisplayLimit < semuaObjekBudidayaDiKebunIni.length) {
          listChildren.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: InkWell(
                // Membuat area yang bisa di-tap
                onTap: () => _loadMoreObjekBudidaya(
                    kebunId, semuaObjekBudidayaDiKebunIni.length),
                borderRadius:
                    BorderRadius.circular(8), // Untuk efek ripple yang bagus
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 12.0), // Padding di dalam InkWell
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Menengahkan konten
                    mainAxisSize: MainAxisSize
                        .min, // Membuat Row sekecil kontennya jika di Center
                    children: [
                      Text(
                        "Muat lagi tanaman di ${kebunItem['nama'] ?? ''}",
                        style: regular14.copyWith(color: green1),
                      ),
                      const SizedBox(width: 8), // Jarak antara teks dan ikon
                      Icon(Icons.keyboard_arrow_down, color: green1),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    listChildren.add(const SizedBox(height: 60));

    return ListView.builder(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: listChildren.length,
      itemBuilder: (BuildContext context, int index) {
        return listChildren[index];
      },
    );
  }
}
