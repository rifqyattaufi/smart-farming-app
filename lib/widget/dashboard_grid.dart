import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

enum DashboardGridType { basic, none }

class DashboardItem {
  final String title;
  final String value;
  final String icon;
  final Color bgColor;
  final Color iconColor;

  DashboardItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}

class DashboardGrid extends StatelessWidget {
  final String title;
  final List<DashboardItem> items;
  final int crossAxisCount;
  final double iconsWidth;
  final double titleFontSize;
  final double valueFontSize;
  final double detailFontSize;
  final double paddingSize;
  final DashboardGridType type;
  final VoidCallback? onViewAll;

  const DashboardGrid({
    super.key,
    required this.title,
    required this.items,
    this.crossAxisCount = 2,
    this.iconsWidth = 40,
    this.titleFontSize = 18,
    this.valueFontSize = 60,
    this.detailFontSize = 14,
    this.paddingSize = 20,
    this.onViewAll,
    this.type = DashboardGridType.none,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: bold18.copyWith(color: dark1)),
                if (type == DashboardGridType.basic) ...[
                  GestureDetector(
                    onTap: onViewAll,
                    child: Text(
                      'Lihat Laporan',
                      style: regular14.copyWith(color: green1),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: items.map((item) {
              return SizedBox(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: dark1,
                        width: 1,
                      )),
                  color: item.bgColor,
                  child: Padding(
                    padding: EdgeInsets.all(paddingSize),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                            item.value,
                            style: bold20.copyWith(
                              color: dark1,
                              fontSize: valueFontSize,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: iconsWidth,
                            height: iconsWidth,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.iconColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                'assets/icons/${item.icon}.svg',
                                colorFilter: ColorFilter.mode(
                                  white,
                                  BlendMode.srcIn,
                                ),
                                width: 24,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          child: Text(
                            item.title,
                            style: semibold18.copyWith(
                                color: dark1, fontSize: titleFontSize),
                          ),
                        ),
                        // Positioned(
                        //   bottom: 0,
                        //   left: 0,
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => const DetailScreen(),
                        //         ),
                        //       );
                        //     },
                        //     child: Text(
                        //       'Lihat detail',
                        //       style: regular14.copyWith(
                        //           color: blue1, fontSize: detailFontSize),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
