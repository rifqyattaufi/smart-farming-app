import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';

class BannerWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool showDate;

  const BannerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showDate = true,
  });

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan timer saat widget dihapus
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: green4,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: semibold20.copyWith(color: dark1),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: regular16.copyWith(color: dark1),
          ),
          if (widget.showDate) ...[
            const SizedBox(height: 20),
            Text(
              DateFormat('EEEE, dd MMMM yyyy HH:mm').format(_currentTime),
              style: regular14.copyWith(color: dark1),
            ),
          ]
        ],
      ),
    );
  }
}
