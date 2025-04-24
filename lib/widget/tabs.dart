import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class Tabs extends StatefulWidget {
  final Function(int) onTabChanged;
  final int selectedIndex;

  const Tabs(
      {super.key, required this.onTabChanged, required this.selectedIndex});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          _tabItem(title: 'Perkebunan', index: 0),
          _tabItem(title: 'Peternakan', index: 1),
        ],
      ),
    );
  }

  Widget _tabItem({required String title, required int index}) {
    bool isActive = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: isActive ? green1 : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: isActive
              ? null
              : Border.all(
                  color: green1,
                  width: 1.5,
                ),
        ),
        child: Text(
          title,
          style: semibold14.copyWith(
            color: isActive ? Colors.white : green1,
          ),
        ),
      ),
    );
  }
}
