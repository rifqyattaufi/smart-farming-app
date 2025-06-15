import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';
import 'package:smart_farming_app/widget/info_item.dart';

class InfoTab extends StatefulWidget {
  final bool isLoadingInitialData;
  final Map<String, dynamic>? ternakReport;
  final List<dynamic> kandangList;
  final int jumlahTernak;
  final ScrollController scrollController;
  final String Function(String?) formatDisplayDate;
  final String Function(String?) formatDisplayTime;

  const InfoTab({
    super.key,
    required this.isLoadingInitialData,
    required this.ternakReport,
    required this.kandangList,
    required this.jumlahTernak,
    required this.scrollController,
    required this.formatDisplayDate,
    required this.formatDisplayTime,
  });

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  static const int _increment = 3; // Jumlah item yang dimuat setiap kali
  int _displayedKandangCount = _increment;
  // Map untuk menyimpan jumlah objek budidaya yang ditampilkan per ID kandang
  final Map<String, int> _displayedObjekBudidayaCountPerKandang = {};

  @override
  void initState() {
    super.initState();
    // Inisialisasi count untuk setiap kandang jika kandangList sudah ada
    // (meskipun saat initState, widget.kandangList mungkin belum terisi penuh jika ada loading)
    _initializeObjekBudidayaCounts();
  }

  @override
  void didUpdateWidget(covariant InfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika kandangList berubah (misalnya setelah loading selesai), re-inisialisasi counts
    if (widget.kandangList != oldWidget.kandangList) {
      _initializeObjekBudidayaCounts();
    }
  }

  void _initializeObjekBudidayaCounts() {
    for (var kandangData in widget.kandangList) {
      final kandangItem = kandangData as Map<String, dynamic>;
      final kandangId = kandangItem['id'] as String? ?? UniqueKey().toString();
      // Hanya inisialisasi jika belum ada, atau reset jika diinginkan
      _displayedObjekBudidayaCountPerKandang.putIfAbsent(
          kandangId, () => _increment);
    }
  }

  void _loadMoreKandang() {
    setState(() {
      _displayedKandangCount = (_displayedKandangCount + _increment)
          .clamp(0, widget.kandangList.length);
    });
  }

  void _loadMoreObjekBudidaya(String kandangId, int totalObjekBudidaya) {
    setState(() {
      int currentCount = _displayedObjekBudidayaCountPerKandang[kandangId] ?? 0;
      _displayedObjekBudidayaCountPerKandang[kandangId] =
          (currentCount + _increment).clamp(0, totalObjekBudidaya);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingInitialData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.ternakReport == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            key: const Key('no_ternak_report'),
            "Laporan informasi peternakan tidak ditemukan atau gagal dimuat.",
            textAlign: TextAlign.center,
            style: regular12.copyWith(color: dark2),
          ),
        ),
      );
    }

    final String namaTernak =
        widget.ternakReport!['nama'] as String? ?? 'Tidak diketahui';
    final String namaLatin =
        widget.ternakReport!['latin'] as String? ?? 'Tidak diketahui';
    final String gambarUtama = widget.ternakReport!['gambar'] as String? ?? '';
    final bool isTernak = (widget.ternakReport!['status'] == true ||
        widget.ternakReport!['status'] == 1);
    final String statusTernakText = isTernak ? 'Ternak' : 'Tidak Ternak';
    final Color statusColor = isTernak ? green2 : red;
    final String tanggalDidaftarkan =
        widget.formatDisplayDate(widget.ternakReport!['createdAt'] as String?);
    final String waktuDidaftarkan =
        widget.formatDisplayTime(widget.ternakReport!['createdAt'] as String?);
    final String deskripsiTernak = widget.ternakReport!['detail'] as String? ??
        'Tidak ada deskripsi yang tersedia.';
    final String lokasiTernakDisplay = widget.kandangList.isNotEmpty
        ? ((widget.kandangList.first as Map<String, dynamic>)['lokasi']
                as String? ??
            'Beberapa Lokasi')
        : 'Lokasi tidak spesifik';

    List<Widget> listChildren = [];

    // Bagian 1: Gambar Utama
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

    // Bagian 2: Informasi Jenis Ternak
    listChildren.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informasi Jenis Ternak",
                style: bold18.copyWith(color: dark1)),
            const SizedBox(height: 12),
            InfoItemWidget("Nama jenis ternak", value: namaTernak),
            InfoItemWidget("Nama latin", value: namaLatin),
            InfoItemWidget("Lokasi ternak", value: lokasiTernakDisplay),
            InfoItemWidget("Jumlah ternak",
                value: "${widget.jumlahTernak} ekor"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Status ternak", style: medium14.copyWith(color: dark1)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusTernakText,
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
            Text("Deskripsi ternak:", style: medium14.copyWith(color: dark1)),
            const SizedBox(height: 6),
            Text(
              deskripsiTernak,
              style: regular14.copyWith(color: dark2, height: 1.4),
            ),
          ],
        ),
      ),
    );

    // Bagian 3: Daftar Kandang Budidaya
    if (widget.kandangList.isNotEmpty) {
      final kandangToShow =
          widget.kandangList.take(_displayedKandangCount).toList();
      listChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListItem(
            key: const Key('list_kandang'),
            title: 'Daftar Kandang',
            type: 'basic',
            items: kandangToShow.map((kandang) {
              final kandangItem = kandang as Map<String, dynamic>;
              return {
                'name': kandangItem['nama'] as String? ?? 'Kandang Tanpa Nama',
                'icon': kandangItem['gambar'] as String? ??
                    'assets/images/default_kandang.png',
                'category':
                    '${kandangItem['lokasi'] ?? 'Lokasi Tidak Ada'} - ${(kandangItem['jumlah'] ?? 0)} ekor',
                'id': kandangItem['id'] as String? ?? UniqueKey().toString(),
              };
            }).toList(),
          ),
        ),
      );

      if (_displayedKandangCount < widget.kandangList.length) {
        listChildren.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextButton(
            onPressed: _loadMoreKandang,
            child: Text("Muat lagi...",
                key: const Key('load_more_kandang'),
                style: regular12.copyWith(color: dark2)),
          ),
        ));
      }
    } else {
      listChildren.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text("Tidak ditemukan daftar kandang untuk jenis ternak ini.",
              style: regular14.copyWith(color: dark2),
              key: const Key('no_kandang_info')),
        ),
      );
    }

    // Bagian 4: Daftar Ternak per Kandang (Objek Budidaya)
    // Menampilkan objek budidaya hanya untuk kandang yang sudah ditampilkan
    final displayedKandangData =
        widget.kandangList.take(_displayedKandangCount);

    for (var kandangData in displayedKandangData) {
      final kandangItem = kandangData as Map<String, dynamic>;
      final String kandangId = kandangItem['id'] as String? ??
          'unknown_kandang_${kandangItem.hashCode}';
      final List<dynamic> semuaObjekBudidayaDiKandangIni =
          (kandangItem['ObjekBudidayas'] as List<dynamic>?) ?? [];

      // Pastikan count untuk kandang ini sudah diinisialisasi
      _displayedObjekBudidayaCountPerKandang.putIfAbsent(
          kandangId, () => _increment);
      final int currentDisplayLimit =
          _displayedObjekBudidayaCountPerKandang[kandangId]!;
      final objekBudidayaToShow =
          semuaObjekBudidayaDiKandangIni.take(currentDisplayLimit).toList();

      if (semuaObjekBudidayaDiKandangIni.isNotEmpty) {
        listChildren.add(Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          child: ListItem(
            key: Key('list_ternak_${kandangItem['id'] ?? 'unknown'}'),
            title:
                'Detail Ternak di ${kandangItem['nama'] ?? 'Kandang Tanpa Nama'}',
            type: 'basic',
            items: objekBudidayaToShow.map((item) {
              final plantItem = item as Map<String, dynamic>;
              return {
                'name': plantItem['namaId'] as String? ??
                    'Ternak (ID: ${plantItem['id']?.substring(0, 6) ?? 'N/A'})',
                'icon': gambarUtama,
                'category': '$namaTernak - ${kandangItem['nama']}',
                'id': plantItem['id'] as String? ?? UniqueKey().toString(),
              };
            }).toList(),
          ),
        ));

        if (currentDisplayLimit < semuaObjekBudidayaDiKandangIni.length) {
          listChildren.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
              child: InkWell(
                onTap: () => _loadMoreObjekBudidaya(
                    kandangId, semuaObjekBudidayaDiKandangIni.length),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        key: Key('load_more_ternak_${kandangItem['id'] ?? 'unknown'}'),
                        "Muat lagi ternak di ${kandangItem['nama'] ?? ''}",
                        style: regular14.copyWith(color: green1),
                      ),
                      const SizedBox(width: 8),
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
