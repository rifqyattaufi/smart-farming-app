import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class ChartData {
  final String label;
  final int value;
  final Color color;

  ChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class ChartWidget extends StatelessWidget {
  final String title;
  final List<ChartData> data;
  final double height;

  const ChartWidget({
    super.key,
    required this.title,
    required this.data,
    this.height = 200,
  });

  // Method untuk membuat sumbu Y
  List<int> _generateYAxisLabels(int maxValue) {
    if (maxValue == 0) return [0];

    // Tentukan jumlah label (maksimal 5)
    const labelCount = 5;
    final step = (maxValue / (labelCount - 1)).ceil();

    List<int> labels = [];
    for (int i = 0; i < labelCount; i++) {
      final value = step * i;
      if (value <= maxValue) {
        labels.add(value);
      }
    }

    // Pastikan nilai maksimum ada di label
    if (!labels.contains(maxValue)) {
      labels.add(maxValue);
    }

    return labels.reversed.toList(); // Urutkan dari atas ke bawah
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: height + 80,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: bold18.copyWith(color: dark1),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Tidak ada data',
                  style: regular14.copyWith(color: dark2),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Cari nilai maksimum untuk scaling
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final yAxisLabels = _generateYAxisLabels(maxValue);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: bold18.copyWith(color: dark1),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Reserve space for value text (18px), spacing (4px), label (32px), spacing (6px)
                const reservedHeight = 18 + 4 + 32 + 6; // 60px total
                final availableBarHeight =
                    constraints.maxHeight - reservedHeight;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Y-Axis (Sumbu Y)
                    SizedBox(
                      width: 35,
                      height: constraints.maxHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Space for value labels above bars
                          const SizedBox(height: 18),
                          // Y-axis labels area
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: yAxisLabels.map((label) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    label.toString(),
                                    style: regular12.copyWith(color: dark1),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Space for bottom labels
                          const SizedBox(height: 37),
                        ],
                      ),
                    ),
                    // Grid lines and chart area
                    Expanded(
                      child: Stack(
                        children: [
                          // Grid lines (horizontal)
                          Positioned.fill(
                            child: Column(
                              children: [
                                const SizedBox(
                                    height: 18), // Space for value labels
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: yAxisLabels.map((label) {
                                      return Container(
                                        height: 0.5,
                                        color:
                                            Colors.grey.withValues(alpha: 0.3),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(
                                    height: 37), // Space for x labels
                              ],
                            ),
                          ),
                          // Chart bars
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: data.map((item) {
                              final barHeight = maxValue > 0
                                  ? (item.value / maxValue) * availableBarHeight
                                  : 0.0;

                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Nilai di atas bar
                                      SizedBox(
                                        height: 18,
                                        child: Text(
                                          item.value.toString(),
                                          style:
                                              semibold12.copyWith(color: dark1),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Bar chart
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 800),
                                        height: barHeight.clamp(
                                            0.0, availableBarHeight),
                                        width: double.infinity,
                                        constraints:
                                            const BoxConstraints(minWidth: 20),
                                        decoration: BoxDecoration(
                                          color: item.color,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Label di bawah bar
                                      SizedBox(
                                        height: 32,
                                        child: Text(
                                          item.label,
                                          style:
                                              regular14.copyWith(color: dark1),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
