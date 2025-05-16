import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class ListItem extends StatelessWidget {
  final String? title;
  final List<Map<String, dynamic>> items;
  final String type; // "basic" or "history"

  final VoidCallback? onViewAll;

  final void Function(BuildContext context, Map<String, dynamic>)? onItemTap;

  const ListItem({
    super.key,
    this.title,
    required this.items,
    this.type = "basic",
    this.onViewAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title!, style: bold18.copyWith(color: dark1)),
                  if (onViewAll != null)
                    GestureDetector(
                      onTap: onViewAll,
                      child: Text(
                        "Lihat semua",
                        style: regular14.copyWith(color: green1),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Center(
              child: Text(
                "Tidak ada data yang ditemukan",
                style: regular14.copyWith(color: dark2),
              ),
            )
          else
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

  Widget _buildBasicItem(Map<String, dynamic> item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60,
            height: 60,
            child: ImageBuilder(
              url: item['icon'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] ?? 'Unknown',
                style: semibold14.copyWith(color: dark1),
              ),
              if (item['category'] != null || item['isActive'] != null)
                const SizedBox(height: 4),
              if (item['category'] != null || item['isActive'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item['isActive'] == false
                        ? red.withOpacity(0.1)
                        : green2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: item['category'] != null
                      ? Text(
                          item['category'] ?? 'Unknown',
                          style: regular12.copyWith(color: green2),
                        )
                      : item['isActive'] != null
                          ? Text(
                              item['isActive'] == true
                                  ? 'Aktif'
                                  : 'Tidak Aktif',
                              style: regular12.copyWith(
                                color: item['isActive'] == true ? green2 : red,
                              ),
                            )
                          : const SizedBox(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 60,
            height: 60,
            child: ImageBuilder(
              url: item['image'],
              fit: BoxFit.cover,
            ),
          ),
        ),
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
                  color: green2.withOpacity(0.1),
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
}
