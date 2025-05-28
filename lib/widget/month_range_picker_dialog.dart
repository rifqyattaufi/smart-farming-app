import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';

class MonthRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialRange;
  final DateTime? firstAllowedDate;
  final DateTime? lastAllowedDate;

  const MonthRangePickerDialog({
    super.key,
    required this.initialRange,
    this.firstAllowedDate,
    this.lastAllowedDate,
  });

  @override
  State<MonthRangePickerDialog> createState() => _MonthRangePickerDialogState();
}

class _MonthRangePickerDialogState extends State<MonthRangePickerDialog> {
  late int _startYear;
  late int _startMonth;
  late int _endYear;
  late int _endMonth;

  late List<int> _years;
  final List<Map<String, dynamic>> _months = List.generate(12, (index) {
    return {
      'value': index + 1,
      'name': DateFormat.MMMM().format(DateTime(2000, index + 1, 2))
    };
  });

  @override
  void initState() {
    super.initState();
    _startYear = widget.initialRange.start.year;
    _startMonth = widget.initialRange.start.month;
    _endYear = widget.initialRange.end.year;
    _endMonth = widget.initialRange.end.month;

    final int currentYear = DateTime.now().year;
    final int firstYear = widget.firstAllowedDate?.year ??
        currentYear - 10; // Batas 10 tahun ke belakang
    final int lastYear = widget.lastAllowedDate?.year ??
        currentYear + 5; // Batas 5 tahun ke depan
    _years =
        List.generate(lastYear - firstYear + 1, (index) => firstYear + index);

    if (!_years.contains(_startYear)) {
      _startYear = _years.isNotEmpty ? _years.first : currentYear;
    }
    if (!_years.contains(_endYear)) {
      _endYear = _years.isNotEmpty ? _years.last : currentYear;
    }
  }

  bool _isValidRange() {
    if (_startYear > _endYear) return false;
    if (_startYear == _endYear && _startMonth > _endMonth) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Rentang Bulan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Dari:', style: semibold14.copyWith(color: dark2)),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Bulan'),
                    value: _startMonth,
                    items: _months
                        .map((month) => DropdownMenuItem(
                              value: month['value'] as int,
                              child: Text(month['name'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _startMonth = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Tahun'),
                    value: _startYear,
                    items: _years
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _startYear = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Sampai:', style: semibold14.copyWith(color: dark2)),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Bulan'),
                    value: _endMonth,
                    items: _months
                        .map((month) => DropdownMenuItem(
                              value: month['value'] as int,
                              child: Text(month['name'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _endMonth = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Tahun'),
                    value: _endYear,
                    items: _years
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _endYear = value);
                    },
                  ),
                ),
              ],
            ),
            if (!_isValidRange())
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Rentang akhir tidak boleh sebelum rentang awal.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          onPressed: _isValidRange()
              ? () {
                  final startDate = DateTime(_startYear, _startMonth, 1);
                  final endDate = DateTime(_endYear, _endMonth + 1,
                      0); // Hari terakhir dari _endMonth
                  Navigator.of(context)
                      .pop(DateTimeRange(start: startDate, end: endDate));
                }
              : null,
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}
