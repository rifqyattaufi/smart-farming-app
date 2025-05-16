import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartWidget extends StatefulWidget {
  final String title;
  final String titleStats;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<double> data;
  final int counter;
  final bool showCounter;
  final String textCounter;
  final List<String> xLabels;

  const ChartWidget({
    super.key,
    this.title = 'Statistik Laporan',
    this.titleStats = 'Statistik Laporan A',
    required this.firstDate,
    required this.lastDate,
    required this.data,
    this.counter = 120,
    this.showCounter = true,
    this.textCounter = 'Hasil Panen (Kg)',
    this.xLabels = const [],
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  late List<String> xLabels;
  late bool showCounter;

  @override
  void initState() {
    super.initState();
    showCounter = widget.showCounter;
    generateXLabels();
  }

  void generateXLabels() {
    setState(() {
      if (widget.xLabels.isNotEmpty) {
        xLabels = widget.xLabels;
      } else {
        xLabels = List.generate(
            widget.data.length, (index) => (index + 1).toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxY = (widget.data.isNotEmpty
        ? (widget.data.reduce((a, b) => a > b ? a : b) / 5).ceil() * 5
        : 0);

    final interval = maxY > 0 ? maxY / 4 : 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCounter)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: bold18.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Per ${DateFormat('d MMM').format(widget.firstDate)} - ${DateFormat('d MMM yyyy').format(widget.lastDate)}',
                      style: regular14.copyWith(color: dark1),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    // open date picker
                    showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: widget.firstDate,
                        end: widget.lastDate,
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          // widget.firstDate = value.start;
                          // widget.lastDate = value.end;
                        });
                        generateXLabels();
                      }
                    });
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 40,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (showCounter) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: dark1,
                          width: 1,
                        )),
                    color: green4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Text(
                              widget.counter.toString(),
                              style: bold20.copyWith(
                                color: dark1,
                                fontSize: 60,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: green1,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  'assets/icons/other.svg',
                                  colorFilter: ColorFilter.mode(
                                    white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Text(
                              widget.textCounter,
                              style: semibold18.copyWith(
                                  color: dark1, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.titleStats,
                style: bold18.copyWith(color: dark1),
              ),
              if (!showCounter) ...[
                IconButton(
                  onPressed: () {
                    // open date picker
                    showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: widget.firstDate,
                        end: widget.lastDate,
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          // widget.firstDate = value.start;
                          // widget.lastDate = value.end;
                        });
                        generateXLabels();
                      }
                    });
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 40,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 36),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY.toDouble(),
                minY: 0,
                barGroups: List.generate(widget.data.length, (index) {
                  final isMax = widget.data[index] ==
                      widget.data.reduce((a, b) => a > b ? a : b);
                  return BarChartGroupData(
                    x: index, // Pastikan ini sinkron dengan indeks xLabels
                    barRods: [
                      BarChartRodData(
                        toY: widget.data[index],
                        width: 20,
                        borderRadius: BorderRadius.circular(6),
                        color: isMax ? green1 : green2.withOpacity(0.4),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: interval.toDouble(),
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: medium12.copyWith(color: dark1),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < widget.xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              widget.xLabels[index],
                              style: medium12.copyWith(color: dark1),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval.toDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: grey,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipColor: (group) {
                      final isMax = widget.data[group.x.toInt()] ==
                          widget.data.reduce((a, b) => a > b ? a : b);
                      return isMax ? green1 : green2.withValues(alpha: 0.4);
                    },
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(1),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
