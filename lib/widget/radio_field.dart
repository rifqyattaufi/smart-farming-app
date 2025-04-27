import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class RadioField extends StatelessWidget {
  final String label;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final List<String> options;

  const RadioField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: semibold14.copyWith(color: dark1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                    value: option,
                    groupValue: selectedValue,
                    onChanged: (value) {
                      if (value != null) onChanged(value);
                    },
                    activeColor: green1),
                Text(
                  option,
                  style: medium14.copyWith(color: dark1),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
