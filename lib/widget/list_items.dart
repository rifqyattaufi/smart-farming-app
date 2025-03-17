import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_farming_app/theme.dart';

class ListItem extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final String type; // "basic" or "history"

  final Widget Function(BuildContext context)?
      navigateTo; // Custom navigation for "Lihat semua"
  
  final void Function(BuildContext context, Map<String, String>)?
      onItemTap; // Item click event

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
      padding: const EdgeInsets.only(left: 15, top: 16, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: bold18.copyWith(color: dark1)),
              if (type == "history" && navigateTo != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => navigateTo!(context)),
                    );
                  },
                  child: Text(
                    "Lihat semua",
                    style: regular14.copyWith(color: blue1),
                  ),
                ),
            ],
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
                  color: green2.withOpacity(0.1),
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
                style: semibold14.copyWith(color: dark1),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.circle, size: 10, color: blue2),
                  const SizedBox(width: 6),
                  Text(
                    item['person'] ?? 'Petugas Tidak Diketahui',
                    style: regular12.copyWith(color: dark2),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${item['date'] ?? 'Unknown Date'} | ${item['time'] ?? 'Unknown Time'}',
                style: regular12.copyWith(color: dark2),
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
          color: Colors.white,
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
