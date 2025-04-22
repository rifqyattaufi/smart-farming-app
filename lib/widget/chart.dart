import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartWidget extends StatefulWidget {
  const ChartWidget({super.key});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  late DateTime firstDate;
  late DateTime lastDate;
  List<double> weeklyData = [];

  @override
  void initState() {
    super.initState();
    firstDate = DateTime.now().subtract(const Duration(days: 6));
    lastDate = DateTime.now();
    fetchData();
  }

  void fetchData() {
    setState(() {
      weeklyData = [10, 20, 15, 25, 30, 12, 18]; // Dummy data for 'Hasil Panen'
    });
  }

  @override
  Widget build(BuildContext context) {
    List<int> dates = [];
    DateTime currentDate = firstDate;
    while (!currentDate.isAfter(lastDate)) {
      dates.add(int.parse(DateFormat('dd').format(currentDate)));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return Container(
        padding: const EdgeInsets.only(left: 15, top: 16, right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grafik', style: bold18.copyWith(color: dark1)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 40,
                  barGroups: List.generate(weeklyData.length, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyData[index],
                          color: Colors.green,
                          width: 20,
                        ),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dates.length) {
                            return Text('${dates[value.toInt()]}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
