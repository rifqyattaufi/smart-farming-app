import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

enum NewestReportsMode { full, simple }

class NewestReports extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> reports;
  final VoidCallback? onViewAll;
  final Function(BuildContext, Map<String, dynamic>) onItemTap;
  final NewestReportsMode mode;
  final bool showIcon;
  final TextStyle titleTextStyle;
  final TextStyle reportTextStyle;
  final TextStyle timeTextStyle;

  const NewestReports({
    super.key,
    required this.title,
    required this.reports,
    required this.onItemTap,
    this.onViewAll,
    this.mode = NewestReportsMode.full,
    this.showIcon = true,
    this.titleTextStyle = const TextStyle(),
    this.reportTextStyle = const TextStyle(),
    this.timeTextStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: titleTextStyle),
              if (mode == NewestReportsMode.full && onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'Lihat semua',
                    style: regular14.copyWith(color: green1),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Content
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              children: List.generate(reports.length, (index) {
                final report = reports[index];
                final customTap = report['onTap'] as Function()?;

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (customTap != null) {
                          customTap();
                        } else {
                          onItemTap(context, report);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if (showIcon)
                              Container(
                                width: 36,
                                height: 36,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: green2,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: SvgPicture.asset(
                                  report['icon'] ?? 'assets/icons/goclub.svg',
                                  colorFilter:
                                      ColorFilter.mode(white, BlendMode.srcIn),
                                  width: 24,
                                ),
                              ),
                            if (showIcon) const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report['text'] ?? 'Unknown Report',
                                    style: reportTextStyle,
                                  ),
                                  if (mode == NewestReportsMode.full)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        report['time'] ?? 'Unknown Time',
                                        style: timeTextStyle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            SvgPicture.asset(
                              'assets/icons/left.svg',
                              height: 24,
                              colorFilter:
                                  ColorFilter.mode(dark1, BlendMode.srcIn),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index != reports.length - 1)
                      const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
