import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:flutter_svg/svg.dart';

enum HeaderType { basic, menu, back }

enum IconType { svg, image }

class Header extends StatelessWidget {
  final HeaderType headerType;
  final String? title;
  final String? greeting;
  final String? leadingIconPath;
  final IconType? leadingIconType;

  const Header({
    super.key,
    required this.headerType,
    this.title,
    this.greeting,
    this.leadingIconPath,
    this.leadingIconType,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildLeadingIcon() {
      final iconPath = leadingIconPath ?? 'assets/icons/goclub.svg';
      final iconType = leadingIconType ?? IconType.svg;

      if (iconType == IconType.svg) {
        return SvgPicture.asset(iconPath);
      } else {
        return Image.asset(iconPath);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (headerType == HeaderType.basic) ...[
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: green2,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: buildLeadingIcon(),
                ),
                const SizedBox(width: 12),
              ],
              if (headerType == HeaderType.back) ...[
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: dark1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                padding: EdgeInsets.only(
                  left: headerType == HeaderType.back ? 0 : 16,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Penanggung Jawab RFC',
                      style: regular12.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      greeting ?? 'Halo, Pak Dwi 👋',
                      style: semibold20.copyWith(color: dark1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (headerType == HeaderType.basic) ...[
            Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/notifikasi');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: green3,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/bell.svg',
                          colorFilter:
                              ColorFilter.mode(green1, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
