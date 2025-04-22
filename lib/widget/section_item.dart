import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class SectionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String? tag;
  final Color? iconColor;
  final Color? titleColor;

  const SectionItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.tag,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? green1),
      title: Text(
        title,
        style: semibold16.copyWith(color: titleColor ?? dark1),
      ),
      trailing: tag != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tag!, style: medium14.copyWith(color: Colors.white)),
            )
          : null,
      onTap: onTap,
    );
  }
}
