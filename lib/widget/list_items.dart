import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

class ListItem extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final String type; // "basic" or "history"

  final String Function(BuildContext context)? navigateTo;

  final void Function(BuildContext context, Map<String, String>)? onItemTap;

  const ListItem({
    super.key,
    required this.title,
    required this.items,
    this.type = "basic",
    this.navigateTo,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: bold18.copyWith(color: dark1)),
                GestureDetector(
                  onTap: () {
                    final path = navigateTo!(context); // need care
                    context.push(path);
                  },
                  child: Text(
                    "Lihat semua",
                    style: regular14.copyWith(color: green1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: items.map((item) {
              return GestureDetector(
                onTap: () {
                  if (onItemTap != null) {
                    onItemTap!(context, item);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: type == "basic"
                      ? _buildBasicItem(item)
                      : _buildHistoryItem(item),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicItem(Map<String, String> item) {
    return Row(
      children: [
        _buildImageOrIcon(item['icon']),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] ?? 'Unknown',
                style: semibold14.copyWith(color: dark1),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: green2.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  item['category'] ?? 'Unknown',
                  style: regular12.copyWith(color: green2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, String> item) {
    return Row(
      children: [
        _buildImageOrIcon(item['image']),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] ?? 'Unknown',
                style: semibold16.copyWith(color: dark1),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Icon(Icons.circle, size: 10, color: green1),
                  // const SizedBox(width: 6),
                  Text(
                    'Pemakaian oleh: ${item['person'] ?? 'Petugas Tidak Diketahui'}',
                    style: regular12.copyWith(color: dark2),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: green2.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${item['date'] ?? 'Unknown Date'} | ${item['time'] ?? 'Unknown Time'}',
                  style: regular10.copyWith(color: dark2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageOrIcon(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      );
    }

    if (path.endsWith('.svg')) {
      return Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: green2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          path,
          colorFilter: ColorFilter.mode(white, BlendMode.srcIn),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          path,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    }
  }
}
