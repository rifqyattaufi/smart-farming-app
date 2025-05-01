import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Pencarian...',
        hintStyle: medium14.copyWith(color: dark1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: Icon(Icons.search, color: dark1),
      ),
    );
  }
}
