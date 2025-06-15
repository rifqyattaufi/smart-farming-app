import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class Tabs extends StatefulWidget {
  final Function(int) onTabChanged;
  final int selectedIndex;
  final List<String> tabTitles;

  const Tabs({
    super.key,
    required this.onTabChanged,
    required this.selectedIndex,
    required this.tabTitles,
  });

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(widget.tabTitles.length, (index) {
          return _tabItem(title: widget.tabTitles[index], index: index);
        }),
      ),
    );
  }

  Widget _tabItem({required String title, required int index}) {
    bool isActive = widget.selectedIndex == index;

    return GestureDetector(
      key: Key('tabItem_$index'),
      onTap: () => widget.onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? green1 : white,
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
            color: isActive ? white : green1,
          ),
        ),
      ),
    );
  }
}
