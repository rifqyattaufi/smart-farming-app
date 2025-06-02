import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';

class RingkasanInv extends StatefulWidget {
  final int totalItem;
  final int kategoriInventaris;
  final int seringDigunakan;
  final int jarangDigunakan;
  final int itemTersedia;
  final int stokRendah;
  final int itemBaru;
  final DateTime tanggal;

  const RingkasanInv({
    super.key,
    required this.totalItem,
    required this.kategoriInventaris,
    required this.seringDigunakan,
    required this.jarangDigunakan,
    required this.itemTersedia,
    required this.stokRendah,
    required this.itemBaru,
    required this.tanggal,
  });

  @override
  State<RingkasanInv> createState() => _RingkasanInvState();
}

class _RingkasanInvState extends State<RingkasanInv> {
  int? _touchedIndex;

  late List<Map<String, dynamic>> _pieData;

  @override
  void initState() {
    super.initState();
    _pieData = [
      {'color': green2, 'value': widget.itemTersedia, 'title': 'Item Tersedia'},
      {
        'color': const Color(0xFFFFD233),
        'value': widget.seringDigunakan,
        'title': 'Sering Digunakan'
      },
      {
        'color': const Color(0xFFFF9F0A),
        'value': widget.jarangDigunakan,
        'title': 'Jarang Digunakan'
      },
      {
        'color': const Color(0xFFE84BE5),
        'value': widget.stokRendah,
        'title': 'Stok Rendah'
      },
      {
        'color': const Color(0xFF2C6CFF),
        'value': widget.itemBaru,
        'title': 'Item Baru'
      },
    ];
  }

  @override
  void didUpdateWidget(covariant RingkasanInv oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemTersedia != oldWidget.itemTersedia ||
        widget.seringDigunakan != oldWidget.seringDigunakan ||
        false) {
      _pieData = [
        {
          'color': green2,
          'value': widget.itemTersedia,
          'title': 'Item Tersedia'
        },
        {
          'color': const Color(0xFFFFD233),
          'value': widget.seringDigunakan,
          'title': 'Sering Digunakan'
        },
        {
          'color': const Color(0xFFFF9F0A),
          'value': widget.jarangDigunakan,
          'title': 'Jarang Digunakan'
        },
        {
          'color': const Color(0xFFE84BE5),
          'value': widget.stokRendah,
          'title': 'Stok Rendah'
        },
        {
          'color': const Color(0xFF2C6CFF),
          'value': widget.itemBaru,
          'title': 'Item Baru'
        },
      ];
    }
  }

  PieChartSectionData _pieSection(Color color, int value, String title,
      {bool isTouched = false}) {
    final double radius = isTouched ? 18 : 12;
    final double fontSize = isTouched ? 10 : 8;
    final double chartValue = value == 0 ? 0.1 : value.toDouble();

    return PieChartSectionData(
      color: color,
      value: chartValue,
      radius: radius,
      showTitle: false,
      title: '$value',
      titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)]),
      titlePositionPercentageOffset: 0.55,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM y').format(widget.tanggal);
    final timeStr = DateFormat('HH.mm').format(widget.tanggal);

    List<PieChartSectionData> sections = [];
    for (int i = 0; i < _pieData.length; i++) {
      sections.add(
        _pieSection(
          _pieData[i]['color'] as Color,
          _pieData[i]['value'] as int,
          _pieData[i]['title'] as String,
          isTouched: i == _touchedIndex,
        ),
      );
    }

    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detail Laporan",
                      style: semibold16.copyWith(color: dark1)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF3EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$dateStr | $timeStr',
                      style: regular12.copyWith(color: green1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Total Item", "${widget.totalItem} item"),
                        _buildRow("Kategori Inventaris",
                            "${widget.kategoriInventaris} item"),
                        _buildRow("Sering Digunakan",
                            "${widget.seringDigunakan} item"),
                        _buildRow("Jarang Digunakan",
                            "${widget.jarangDigunakan} item"),
                        _buildRow(
                            "Item Tersedia", "${widget.itemTersedia} item"),
                        _buildRow("Stok Rendah", "${widget.stokRendah} item"),
                        _buildRow("Item Baru", "${widget.itemBaru} item"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              // TAMBAHKAN INI
                              touchCallback: (FlTouchEvent event,
                                  PieTouchResponse? pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex =
                                        -1; // Tidak ada yang disentuh
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sectionsSpace: 2,
                            centerSpaceRadius: 60,
                            sections: sections,
                          ),
                        ),
                        _touchedIndex != null &&
                                _touchedIndex != -1 &&
                                _touchedIndex! < _pieData.length
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _pieData[_touchedIndex!]['title'] as String,
                                    style: regular14.copyWith(color: dark2),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (_pieData[_touchedIndex!]['value'] as int)
                                        .toString(),
                                    style: bold18.copyWith(color: dark1),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Total Item",
                                      style: regular14.copyWith(color: dark2)),
                                  const SizedBox(height: 2),
                                  Text("${widget.totalItem}",
                                      style: bold18.copyWith(color: dark1)),
                                ],
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: regular14.copyWith(color: dark2))),
          const SizedBox(width: 8),
          Text(value, style: semibold14.copyWith(color: dark1)),
        ],
      ),
    );
  }
}
