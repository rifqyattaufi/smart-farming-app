import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final Function(int) onTabSelected;
  final Color activeColor;
  final double underlineWidth;
  final double spacing;
  final int activeIndex;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.onTabSelected,
    this.activeColor = Colors.green,
    this.underlineWidth = 100,
    this.spacing = 0,
    this.activeIndex = 0,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: widget.tabs.asMap().entries.map((entry) {
        int index = entry.key;
        String tabName = entry.value;
        bool isActive = widget.activeIndex == index;

        return GestureDetector(
          onTap: () => widget.onTabSelected(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isActive ? widget.activeColor : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              tabName,
              style: TextStyle(
                color: isActive ? widget.activeColor : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
