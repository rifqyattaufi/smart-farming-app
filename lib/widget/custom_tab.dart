import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final Color activeColor;
  final double underlineWidth;
  final double spacing;
  final Function(int)? onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.activeColor = Colors.green,
    this.underlineWidth = 60,
    this.spacing = 40,
    this.onTabSelected,
  });

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.tabs.length, (index) {
        return Row(
          children: [
            _buildTabItem(title: widget.tabs[index], index: index),
            if (index != widget.tabs.length - 1)
              SizedBox(width: widget.spacing),
          ],
        );
      }),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        if (widget.onTabSelected != null) {
          widget.onTabSelected!(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: semibold14.copyWith(
              color: isSelected ? widget.activeColor : green1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: widget.underlineWidth,
            color: isSelected ? widget.activeColor : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
