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
      margin: const EdgeInsets.only(top: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? green1 : Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          title,
          style: semibold14.copyWith(color: isActive ? Colors.white : green1),
        ),
      ),
    );
  }
}
