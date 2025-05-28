import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class YearRangePickerDialog extends StatefulWidget {
  final DateTimeRange initialRange;
  final int? firstAllowedYear;
  final int? lastAllowedYear;

  const YearRangePickerDialog({
    super.key,
    required this.initialRange,
    this.firstAllowedYear,
    this.lastAllowedYear,
  });

  @override
  State<YearRangePickerDialog> createState() => _YearRangePickerDialogState();
}

class _YearRangePickerDialogState extends State<YearRangePickerDialog> {
  late int _startYear;
  late int _endYear;

  late List<int> _years;

  @override
  void initState() {
    super.initState();
    _startYear = widget.initialRange.start.year;
    _endYear = widget.initialRange.end.year;

    final int currentYear = DateTime.now().year;
    
    final int firstYear = widget.firstAllowedYear ?? currentYear - 10;
    final int lastYear = widget.lastAllowedYear ?? currentYear + 5;
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
    return _startYear <= _endYear;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Rentang Tahun'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Dari Tahun:', style: semibold14.copyWith(color: dark2)),
          DropdownButtonFormField<int>(
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
          const SizedBox(height: 20),
          Text('Sampai Tahun:', style: semibold14.copyWith(color: dark2)),
          DropdownButtonFormField<int>(
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
          if (!_isValidRange())
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                'Tahun akhir tidak boleh sebelum tahun awal.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          onPressed: _isValidRange()
              ? () {
                  final startDate =
                      DateTime(_startYear, 1, 1); // 1 Januari tahun mulai
                  final endDate =
                      DateTime(_endYear, 12, 31); // 31 Desember tahun akhir
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
