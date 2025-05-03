import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class SearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;

  const SearchField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) {
        setState(() {}); // Update the UI when the text changes
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
      decoration: InputDecoration(
        hintText: 'Pencarian...',
        hintStyle: medium14.copyWith(color: dark1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close, color: dark1),
                onPressed: () {
                  widget.controller.clear(); // Clear the text
                  setState(() {}); // Update the UI
                  if (widget.onChanged != null) {
                    widget.onChanged!(
                        ''); // Trigger onChanged with an empty string
                  }
                },
              )
            : Icon(Icons.search, color: dark1),
      ),
    );
  }
}
