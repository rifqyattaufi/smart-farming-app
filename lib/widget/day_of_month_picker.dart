import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DayOfMonthPicker extends StatefulWidget {
  final int? initialSelectedDay;
  final ValueChanged<int> onDaySelected;
  final Color selectedColor = green1;
  final Color unselectedColor;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  DayOfMonthPicker({
    super.key,
    this.initialSelectedDay,
    required this.onDaySelected,
    this.unselectedColor = Colors.transparent,
    this.selectedTextColor = Colors.white,
    this.unselectedTextColor = Colors.black87,
  });

  @override
  State<DayOfMonthPicker> createState() => _DayOfMonthPickerState();
}

class _DayOfMonthPickerState extends State<DayOfMonthPicker> {
  late int? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 31,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.2,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemBuilder: (context, index) {
          int day = index + 1;
          bool isSelected = _selectedDay == day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = day;
              });
              widget.onDaySelected(day);
            },
            child: Container(
              alignment: Alignment.center,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? widget.selectedColor : widget.unselectedColor,
                border: Border.all(
                  color: isSelected
                      ? widget.selectedColor
                      : widget.unselectedColor,
                  width: 1,
                ),
              ),
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected
                      ? widget.selectedTextColor
                      : widget.unselectedTextColor,
                  fontSize: 16.0,
                ),
              ),
            ),
          );
        });
  }
}
