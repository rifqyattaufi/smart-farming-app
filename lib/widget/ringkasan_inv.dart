import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';

class RingkasanInv extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM y').format(tanggal);
    final timeStr = DateFormat('HH.mm').format(tanggal);

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
                  // Kiri: Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow("Total Item", "$totalItem item"),
                        _buildRow(
                            "Kategori Inventaris", "$kategoriInventaris item"),
                        _buildRow("Sering Digunakan", "$seringDigunakan item"),
                        _buildRow("Jarang Digunakan", "$jarangDigunakan item"),
                        _buildRow("Item Tersedia", "$itemTersedia item"),
                        _buildRow("Stok Rendah", "$stokRendah item"),
                        _buildRow("Item Baru", "$itemBaru item"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Kanan: Chart
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 35,
                            sections: [
                              _pieSection(green2, itemTersedia),
                              _pieSection(
                                  const Color(0xFFFFD233), seringDigunakan),
                              _pieSection(
                                  const Color(0xFFFF9F0A), jarangDigunakan),
                              _pieSection(const Color(0xFFE84BE5), stokRendah),
                              _pieSection(const Color(0xFF2C6CFF), itemBaru),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Total Item",
                                style: regular10.copyWith(color: dark2)),
                            const SizedBox(height: 2),
                            Text("$totalItem",
                                style: bold20.copyWith(color: dark1)),
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
          Text(label, style: regular14.copyWith(color: dark2)),
          Text(value, style: semibold14.copyWith(color: dark1)),
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(Color color, int value) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      radius: 12,
      showTitle: false,
    );
  }
}
