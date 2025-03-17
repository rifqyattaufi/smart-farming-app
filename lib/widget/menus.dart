import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

class MenuItem {
  final String title;
  final String icon;
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

  const MenuGrid({
    super.key,
    required this.title,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 16, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: bold18.copyWith(color: dark1)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
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
                            child: SvgPicture.asset(
                              'assets/icons/${item.icon}.svg',
                              color: item.iconColor,
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
