import 'package:flutter/material.dart';
import 'package:smart_farming_app/model/chart_data_state.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/chart.dart';

class ChartSection extends StatelessWidget {
  final String title;
  final ChartDataState chartState;
  final String valueKeyForMapping;
  final bool showFilterControls;
  final Future<void> Function()? onDateIconPressed;
  final ChartFilterType? selectedChartFilterType;
  final String? displayedDateRangeText;
  final void Function(ChartFilterType?)? onChartFilterTypeChanged;

  const ChartSection({
    super.key,
    required this.title,
    required this.chartState,
    required this.valueKeyForMapping,
    this.showFilterControls = false,
    this.onDateIconPressed,
    this.selectedChartFilterType,
    this.displayedDateRangeText,
    this.onChartFilterTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (chartState.isLoading) {
      content = const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(strokeWidth: 2)));
    } else if (chartState.error != null) {
      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error $title: ${chartState.error}',
            style: const TextStyle(color: Colors.red)),
      );
    } else {
      final List<double> values = chartState.dataPoints
          .map<double>(
              (e) => (e[valueKeyForMapping] as num?)?.toDouble() ?? 0.0)
          .toList();

      if (values.isEmpty || chartState.xLabels.isEmpty) {
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Tidak ada data statistik $title untuk ditampilkan.'),
          ),
        );
      } else {
        content = ChartWidget(
          titleStats: title,
          data: values,
          xLabels: chartState.xLabels,
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
