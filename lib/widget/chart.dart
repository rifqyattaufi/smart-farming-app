import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/utils/app_enums.dart';

class ChartWidget extends StatelessWidget {
  final String? titleStats;
  final List<double> data;
  final List<String> xLabels;
  final VoidCallback? onDateIconPressed;

  final bool showFilterControls;
  final ChartFilterType? selectedChartFilterType;
  final String? displayedDateRangeText;
  final ValueChanged<ChartFilterType?>? onChartFilterTypeChanged;

  // final String title;
  // final DateTime firstDate;
  // final DateTime lastDate;
  // final int counter;
  // final bool showCounter;
  // final String textCounter;

  const ChartWidget({
    super.key,
    this.titleStats,
    required this.data,
    required this.xLabels,
    this.onDateIconPressed,
    this.showFilterControls = false,
    this.selectedChartFilterType,
    this.displayedDateRangeText,
    this.onChartFilterTypeChanged,

    // this.title = 'Statistik Laporan',
    // required this.firstDate,
    // required this.lastDate,
    // this.counter = 120,
    // this.showCounter = true,
    // this.textCounter = 'Hasil Panen (Kg)',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValidData =
        data.isNotEmpty && xLabels.isNotEmpty && data.length == xLabels.length;

    double currentMaxY = 0;
    if (hasValidData && data.any((d) => d > 0)) {
      currentMaxY = data.reduce((a, b) => a > b ? a : b);
    } else if (hasValidData && data.every((d) => d == 0)) {
      currentMaxY = 5; // Default maxY jika semua data 0 agar ada skala
    } else {
      currentMaxY = 20; // Default jika tidak ada data valid
    }

    // Pembulatan ke atas untuk maxY agar skala Y terlihat bagus
    final double maxY = (currentMaxY / 4).ceil() * 4.0;
    final double interval = maxY > 0 ? (maxY / 4).ceilToDouble() : 5.0;

    final bool hasTitleStats = titleStats != null && titleStats!.isNotEmpty;
    final bool hasDateIcon = onDateIconPressed != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (showCounter) ...[
        //   Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               title,
        //               style: bold18.copyWith(color: dark1),
        //             ),
        //             const SizedBox(height: 4),
        //             Text(
        //               'Per ${DateFormat('d MMM', 'id_ID').format(firstDate)} - ${DateFormat('d MMM yyyy', 'id_ID').format(lastDate)}',
        //               style: regular14.copyWith(color: dark1),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        //   const SizedBox(height: 12),
        //   SizedBox(
        //     width: double.infinity,
        //     height: 180,
        //     child: Card(
        //       elevation: 0,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(15),
        //         side: BorderSide(color: dark1.withValues(alpha: 0.5), width: 1),
        //       ),
        //       color: green4,
        //       child: Padding(
        //         padding: const EdgeInsets.all(20),
        //         child: Stack(
        //           children: [
        //             Positioned(
        //               top: 0,
        //               left: 0,
        //               child: Text(
        //                 counter.toString(),
        //                 style: bold20.copyWith(color: dark1, fontSize: 60),
        //               ),
        //             ),
        //             Positioned(
        //               top: 0,
        //               right: 0,
        //               child: Container(
        //                 width: 40,
        //                 height: 40,
        //                 decoration: BoxDecoration(
        //                     shape: BoxShape.circle, color: green1),
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(8),
        //                   child: SvgPicture.asset(
        //                     'assets/icons/other.svg',
        //                     colorFilter:
        //                         ColorFilter.mode(white, BlendMode.srcIn),
        //                     width: 24,
        //                   ),
        //                 ),
        //               ),
        //             ),
        //             Positioned(
        //               bottom: 0,
        //               left: 0,
        //               child: Text(
        //                 textCounter,
        //                 style:
        //                     semibold18.copyWith(color: dark1, fontSize: 18),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        //   const SizedBox(height: 24),
        // ],

        if (hasTitleStats || hasDateIcon) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasTitleStats)
                Expanded(
                  child: Text(
                    titleStats!,
                    style: bold18.copyWith(color: dark1),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ] else ...[
          const SizedBox(height: 12),
        ],

        if (showFilterControls &&
            selectedChartFilterType != null &&
            onChartFilterTypeChanged != null) ...[
          if (displayedDateRangeText != null &&
              displayedDateRangeText!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Text(
                displayedDateRangeText!,
                style: regular12.copyWith(color: dark2),
                textAlign: TextAlign.center,
              ),
            ),
        ],

        const SizedBox(height: 12),

        if (showFilterControls &&
            selectedChartFilterType != null &&
            onChartFilterTypeChanged != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ChartFilterType>(
                    value: selectedChartFilterType,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: dark2),
                    items: ChartFilterType.values
                        .where((type) => type != ChartFilterType.custom)
                        .map((ChartFilterType type) {
                      return DropdownMenuItem<ChartFilterType>(
                        value: type,
                        child: Text(
                          type.name[0].toUpperCase() + type.name.substring(1),
                          style: regular14.copyWith(color: dark1),
                        ),
                      );
                    }).toList(),
                    onChanged: onChartFilterTypeChanged,
                  ),
                ),
              ),
              if (hasDateIcon)
                IconButton(
                  onPressed: onDateIconPressed,
                  icon: SvgPicture.asset(
                    'assets/icons/calendar.svg',
                    width: 32,
                    height: 32,
                  ),
                  tooltip: "Filter Tanggal",
                ),
            ],
          ),
        ],

        SizedBox(
          height: 200,
          child: !hasValidData
              ? Center(
                  child: Text(
                    "Data tidak tersedia atau tidak valid untuk menampilkan chart.",
                    style: regular14.copyWith(color: dark2),
                    textAlign: TextAlign.center,
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    barGroups: List.generate(data.length, (index) {
                      final isMax = data.isNotEmpty &&
                          data[index] == data.reduce((a, b) => a > b ? a : b);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data[index],
                            width: xLabels.length > 7
                                ? (xLabels.length > 15 ? 10 : 15)
                                : 20, // Lebar bar dinamis
                            borderRadius: BorderRadius.circular(
                                xLabels.length > 15 ? 3 : 6),
                            color:
                                isMax ? green1 : green2.withValues(alpha: 0.6),
                          ),
                        ],
                      );
                    }),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: interval == 0 ? 1 : interval,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                NumberFormat.compact().format(value.toInt()),
                                style: medium12.copyWith(
                                    color: dark1.withValues(alpha: .8)),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < xLabels.length) {
                              bool shouldShow = true;
                              if (xLabels.length > 10 && xLabels.length <= 20) {
                                shouldShow =
                                    index % 2 == 0; // tampilkan setiap 2 bar
                              } else if (xLabels.length > 20) {
                                shouldShow = index % (xLabels.length ~/ 7) == 0;
                              }

                              if (shouldShow) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    xLabels[index],
                                    style: medium12.copyWith(color: dark1),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval == 0 ? 1 : interval,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: grey.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                              color: grey.withValues(alpha: 0.5), width: 1),
                          left: BorderSide(
                              color: grey.withValues(alpha: 0.5), width: 1),
                        )),
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        tooltipMargin: 8,
                        getTooltipColor: (group) {
                          return dark1.withValues(alpha: 0.9);
                        },
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String dataLabel = "";
                          if (group.x.toInt() >= 0 &&
                              group.x.toInt() < xLabels.length) {
                            dataLabel = xLabels[group.x
                                .toInt()]; // Mengambil label dari widget.xLabels (misal: "26 May", "May 25", "2025")
                          }

                          String jumlahValue = rod.toY.toInt().toString();

                          final String text =
                              'Data: $dataLabel\nJumlah: $jumlahValue';

                          return BarTooltipItem(
                            text,
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.start,
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
