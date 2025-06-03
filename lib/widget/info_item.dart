import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class InfoItemWidget extends StatelessWidget {
  final String label;
  final String value;

  const InfoItemWidget(
    this.label, {
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }
}
