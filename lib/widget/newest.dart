import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

class NewestReports extends StatelessWidget {
  final String title;
  final List<Map<String, String>> reports;
  final VoidCallback onViewAll;

  const NewestReports({
    super.key,
    required this.title,
    required this.reports,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 16, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: bold18.copyWith(color: dark1)),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'Lihat semua',
                  style: regular14.copyWith(color: blue1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              children: List.generate(reports.length, (index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: green2,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: SvgPicture.asset(
                              reports[index]['icon'] ??
                                  'assets/icons/goclub.svg',
                              color: Colors.white,
                              width: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reports[index]['text'] ?? 'Unknown Report',
                              style: regular14.copyWith(color: dark1),
                            ),
                          ),
                          const SizedBox(width: 24),
                          SvgPicture.asset(
                            'assets/icons/left.svg',
                            height: 24,
                            color: dark1,
                          ),
                        ],
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
