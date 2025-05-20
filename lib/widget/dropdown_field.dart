import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DropdownFieldWidget extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final bool isEdit;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.isEdit = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    String? valueToUse = selectedValue;

    if (valueToUse != null && !items.contains(valueToUse)) {
      valueToUse = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: semibold14.copyWith(color: dark1)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: valueToUse, // Use the corrected value
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isEdit
                ? Colors.grey[300]
                : Colors.grey[100], // Change color if disabled
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          hint: Text(hint, style: medium14.copyWith(color: grey)),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: medium14.copyWith(color: dark1),
                    ),
                  ))
              .toList(),
          onChanged: isEdit ? null : onChanged,
          validator: validator, // Disable if isEdit is true
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
