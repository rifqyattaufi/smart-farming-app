import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_farming_app/theme.dart';

class HarvestStatsScreen extends StatefulWidget {
  const HarvestStatsScreen({super.key});

  @override
  State<HarvestStatsScreen> createState() => _HarvestStatsScreenState();
}

class _HarvestStatsScreenState extends State<HarvestStatsScreen> {
  DateTimeRange? _selectedRange;

  void _openDatePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  List<ChartData> telurData = [
    ChartData('Apr', 18),
    ChartData('Juni', 18),
    ChartData('Agu', 20),
    ChartData('Okt', 18),
    ChartData('Des', 18),
    ChartData('Feb', 20),
  ];

  List<ChartData> dagingData = [
    ChartData('Feb', 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          elevation: 0,
          titleSpacing: 0,title: const Text('Panen'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Hasil Panen\nPer Apr 2024 - Feb 2025'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _openDatePicker,
                  )
                ],
              ),
              const SizedBox(height: 12),
              const CustomStatCard(
                value: '20',
                label: 'Hasil Panen (Kg)',
                icon: Icons.egg,
              ),
              const SizedBox(height: 24),
              const Text('Statistik Hasil Panen Ayam - Komoditas Telur'),
              CustomBarChart(data: telurData),
              const SizedBox(height: 24),
              const Text('Statistik Hasil Panen Ayam - Komoditas Daging'),
              CustomBarChart(data: dagingData),
              const SizedBox(height: 24),
              const Text(
                'Rangkuman Statistik',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Berdasarkan statistik pelaporan panen ayam komoditas telur menghasilkan rata-rata 18 butir telur yang ...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const CustomStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.displaySmall),
                  Text(label),
                ],
              ),
            ),
            Icon(icon, size: 32, color: Colors.green[800])
          ],
        ),
      ),
    );
  }
}

class CustomBarChart extends StatelessWidget {
  final List<ChartData> data;

  const CustomBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 25,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Text(data[index].month);
                  } else {
                    return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 5),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: data.asMap().entries.map((entry) {
            int index = entry.key;
            ChartData d = entry.value;
            return BarChartGroupData(x: index, barRods: [
              BarChartRodData(
                  toY: d.value,
                  color: Colors.green[700],
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class ChartData {
  final String month;
  final double value;

  ChartData(this.month, this.value);
}
