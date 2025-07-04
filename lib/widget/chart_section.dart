import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/chart.dart';

class ChartSection extends StatelessWidget {
  final String title;
  final ChartDataState chartState;
  final String valueKeyForMapping;
  final String? labelKeyForMapping;
  final bool showFilterControls;
  final VoidCallback? onDateIconPressed;
  final ChartFilterType? selectedChartFilterType;
  final String? displayedDateRangeText;
  final ValueChanged<ChartFilterType?>? onChartFilterTypeChanged;

  const ChartSection({
    super.key,
    required this.title,
    required this.chartState,
    required this.valueKeyForMapping,
    this.labelKeyForMapping,
    this.showFilterControls = false,
    this.onDateIconPressed,
    this.selectedChartFilterType,
    this.displayedDateRangeText,
    this.onChartFilterTypeChanged,
  });

  // Helper function to safely extract numeric values from dynamic data
  double _safeDoubleValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (chartState.isLoading) {
      content = const Center(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: CircularProgressIndicator(strokeWidth: 2)));
    } else if (chartState.error != null) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text('Error $title: ${chartState.error}',
            style: const TextStyle(color: Colors.red)),
      );
    } else {
      List<double> finalValues;
      List<String> finalXLabels;

      if (labelKeyForMapping != null) {
        final data =
            chartState.rawData?.whereType<Map<String, dynamic>>().toList() ??
                [];
        finalValues = data
            .map<double>((e) => _safeDoubleValue(e[valueKeyForMapping]))
            .toList();
        finalXLabels = data
            .map<String>((e) => (e[labelKeyForMapping!] as String?) ?? 'N/A')
            .toList();
      } else {
        finalValues = chartState.dataPoints
            .map<double>((e) => _safeDoubleValue(e[valueKeyForMapping]))
            .toList();
        finalXLabels = chartState.xLabels;
      }

      if (finalValues.isEmpty) {
        content = Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('Tidak ada data $title untuk ditampilkan.',
                style: regular14.copyWith(color: dark2)),
          ),
        );
      } else {
        content = ChartWidget(
          titleStats: title,
          data: finalValues,
          xLabels: finalXLabels,
          showFilterControls: showFilterControls,
          onDateIconPressed: onDateIconPressed,
          selectedChartFilterType: selectedChartFilterType,
          displayedDateRangeText: displayedDateRangeText,
          onChartFilterTypeChanged: onChartFilterTypeChanged,
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: content,
    );
  }
}
