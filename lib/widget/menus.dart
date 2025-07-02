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
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const MenuGrid({
    super.key,
    required this.title,
    required this.menuItems,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (menuItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, top: 6, right: 15, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: bold18.copyWith(color: dark1)),
            const SizedBox(height: 10),
            Center(
                child: Text("Tidak ada menu tersedia.",
                    style: regular14.copyWith(color: dark2))),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 6, right: 15, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: bold18.copyWith(color: dark1)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: menuItems.map((item) {
              return GestureDetector(
                key: Key(
                    'menu_item_${item.title.toLowerCase().replaceAll(" ", "_")}'),
                onTap: item.onTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: item.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: item.icon is IconData
                          ? Icon(
                              item.icon,
                              color: item.iconColor,
                              size: 30,
                            )
                          : item.icon is String && item.icon.contains('.')
                              ? Image.asset(
                                  'assets/icons/${item.icon}',
                                  width: 30,
                                  height: 30,
                                  color: item.iconColor,
                                )
                              : SvgPicture.asset(
                                  'assets/icons/${item.icon}.svg',
                                  colorFilter: ColorFilter.mode(
                                      item.iconColor, BlendMode.srcIn),
                                  width: 30,
                                  height: 30,
                                ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          item.title,
                          style: semibold12.copyWith(color: dark2),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
