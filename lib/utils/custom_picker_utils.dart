import 'package:flutter/material.dart';
import 'package:smart_farming_app/widget/month_range_picker_dialog.dart';
import 'package:smart_farming_app/widget/year_range_picker_dialog.dart';

Future<DateTimeRange?> showCustomMonthRangePicker(
  BuildContext context, {
  required DateTimeRange initialRange,
  DateTime? firstAllowedDate, // Untuk membatasi tanggal paling awal
  DateTime? lastAllowedDate, // Untuk membatasi tanggal paling akhir
}) async {
  return await showDialog<DateTimeRange>(
    context: context,
    builder: (BuildContext dialogContext) {
      return MonthRangePickerDialog(
        initialRange: initialRange,
        firstAllowedDate: firstAllowedDate,
        lastAllowedDate: lastAllowedDate,
      );
    },
  );
}

Future<DateTimeRange?> showCustomYearRangePicker(
  BuildContext context, {
  required DateTimeRange initialRange,
  int? firstAllowedYear, // Untuk membatasi tahun paling awal
  int? lastAllowedYear, // Untuk membatasi tahun paling akhir
}) async {
  return await showDialog<DateTimeRange>(
    context: context,
    builder: (BuildContext dialogContext) {
      return YearRangePickerDialog(
        initialRange: initialRange,
        firstAllowedYear: firstAllowedYear,
        lastAllowedYear: lastAllowedYear,
      );
    },
  );
}
