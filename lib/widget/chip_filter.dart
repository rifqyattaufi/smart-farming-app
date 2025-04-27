import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class ChipFilter extends StatefulWidget {
  final ValueChanged<String> onCategorySelected;
  final List<String> categories;
  final String selectedCategory;

  const ChipFilter({
    super.key,
    required this.onCategorySelected,
    required this.categories,
    required this.selectedCategory,
  });

  @override
  State<ChipFilter> createState() => _ChipFilterState();
}

class _ChipFilterState extends State<ChipFilter> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.categories.map((category) {
          final bool isSelected = category == widget.selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                widget.onCategorySelected(category);
              },
              selectedColor: green1,
              backgroundColor: Colors.transparent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : green1,
              ),
              side: BorderSide(
                color: green1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

