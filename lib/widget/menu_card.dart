import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class MenuCard extends StatelessWidget {
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: iconColor,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(title, style: semibold16.copyWith(color: dark1)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: regular12.copyWith(color: dark1, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
