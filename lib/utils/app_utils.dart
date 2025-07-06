import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum ChartFilterType { weekly, monthly, yearly, custom }

void showAppToast(
  BuildContext context,
  String message, {
  String? title,
  bool isError = true,
  ToastificationType? type,
  AlignmentGeometry alignment = Alignment.topCenter,
  Duration autoCloseDuration = const Duration(seconds: 4),
  ToastificationStyle style = ToastificationStyle.fillColored,
  bool showProgressBar = false,
}) {
  toastification.show(
    context: context,
    title: Text(
        title ?? (isError ? 'Oops, Ada yang Salah! 👎' : 'Hore! Sukses! 👍')),
    description: Text(message),
    type: type ??
        (isError ? ToastificationType.error : ToastificationType.success),
    style: style,
    autoCloseDuration: autoCloseDuration,
    alignment: alignment,
    showProgressBar: showProgressBar,
  );
}

String formatTime(dynamic time) {
  if (time == null) return 'Tidak diketahui';
  try {
    return DateFormat('EE, d MMMM yyyy | HH:mm').format(DateTime.parse(time));
  } catch (e) {
    return 'Tidak diketahui';
  }
}

String formatDisplayDate(String? dateString) {
  if (dateString == null) return 'Tidak diketahui';
  try {
    final dateTime = DateTime.tryParse(dateString);
    if (dateTime == null) return 'Format tanggal tidak valid';

    if (dateTime.year < 1900) return 'Tidak diatur';
    return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
  } catch (e) {
    return 'Error format tanggal';
  }
}

String formatDisplayTime(String? dateString) {
  if (dateString == null) return 'Tidak diketahui';
  try {
    final dateTime = DateTime.tryParse(dateString);
    if (dateTime == null) return 'Format waktu tidak valid';

    if (dateTime.year < 1900 && dateTime.hour == 0 && dateTime.minute == 0) {
      return '';
    }
    return DateFormat('HH:mm').format(dateTime);
  } catch (e) {
    return 'Error format waktu';
  }
}

String formatTimeAgo(String? isoTimestamp) {
  if (isoTimestamp == null || isoTimestamp.isEmpty) {
    return 'Waktu tidak diketahui';
  }
  DateTime? reportTime = DateTime.tryParse(isoTimestamp.trim());

  if (reportTime == null) {
    return isoTimestamp;
  }

  final now = DateTime.now();
  final difference = now.difference(reportTime);

  if (difference.isNegative) {
    return DateFormat('dd MMM yy, HH:mm').format(reportTime);
  } else if (difference.inDays > 1) {
    return DateFormat('dd MMM yy, HH:mm').format(reportTime);
  } else if (difference.inDays == 1) {
    final yesterday = now.subtract(const Duration(days: 1));
    if (reportTime.year == yesterday.year &&
        reportTime.month == yesterday.month &&
        reportTime.day == yesterday.day) {
      return 'Kemarin, ${DateFormat('HH:mm').format(reportTime)}';
    } else {
      return DateFormat('dd MMM yy, HH:mm').format(reportTime);
    }
  } else if (difference.inHours > 0) {
    return '${difference.inHours} jam lalu';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} menit lalu';
  } else if (difference.inSeconds >= 0) {
    return 'Baru saja';
  } else {
    return DateFormat('dd MMM yy, HH:mm').format(reportTime);
  }
}

String formatNumber(dynamic number) {
  if (number == null) return '0';

  if (number is int) {
    return number.toString();
  } else if (number is double) {
    // If it's a whole number (like 5.0), display as int
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      // Format with up to 2 decimal places, removing trailing zeros
      return number.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    }
  } else {
    // Try to parse as double
    final doubleValue = double.tryParse(number.toString());
    if (doubleValue != null) {
      return formatNumber(doubleValue);
    }
    return number.toString();
  }
}
