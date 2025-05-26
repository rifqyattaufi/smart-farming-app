import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

class MenuItem {
  final String title;
  final dynamic icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });
}

class MenuGrid extends StatelessWidget {
  final String title;
  final List<MenuItem> menuItems;
  final int crossAxisCount;
  final int mainAxisSpacing;

  const MenuGrid({
    super.key,
    required this.title,
    required this.menuItems,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 6, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: bold18.copyWith(color: dark1)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing.toDouble(),
              shrinkWrap: false,
              physics: const NeverScrollableScrollPhysics(),
              children: menuItems
                  .map(
                    (item) => GestureDetector(
                      onTap: item.onTap,
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: item.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: item.icon is IconData
                                ? Icon(
                                    item.icon,
                                    color: item.iconColor,
                                    size: 32,
                                  )
                                : SvgPicture.asset(
                                    'assets/icons/${item.icon}.svg',
                                    colorFilter: ColorFilter.mode(
                                        item.iconColor, BlendMode.srcIn),
                                    width: 24,
                                  ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            item.title,
                            style: semibold12.copyWith(color: dark2),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
