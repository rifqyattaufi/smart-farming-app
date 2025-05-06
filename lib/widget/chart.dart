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

  const ChartWidget({
    super.key,
    this.title = 'Statistik Laporan',
    this.titleStats = 'Statistik Laporan A',
    required this.firstDate,
    required this.lastDate,
    required this.data,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  late List<String> xLabels;

  @override
  void initState() {
    super.initState();
    generateXLabels();
  }

  void generateXLabels() {
    xLabels = [];
    DateTime currentDate = widget.firstDate;

    while (!currentDate.isAfter(widget.lastDate)) {
      xLabels.add(DateFormat('d').format(currentDate)); // "1", "2", dst
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxY = (widget.data.reduce((a, b) => a > b ? a : b) / 5).ceil() * 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            widget.titleStats,
            style: bold16.copyWith(color: dark1),
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
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: widget.data[index],
                        width: 20,
                        borderRadius: BorderRadius.circular(6),
                        color: isMax ? green1 : green2.withValues(alpha: 0.4),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY / 4,
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
                        if (index >= 0 && index < xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              xLabels[index],
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
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: grey,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
