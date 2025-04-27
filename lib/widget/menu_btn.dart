import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:popover/popover.dart';

class MenuButton extends StatelessWidget {
  final String title;
  final String subtext;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTapNavigate;

  const MenuButton({
    super.key,
    required this.title,
    required this.subtext,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTapNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapNavigate,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: semibold16.copyWith(color: dark1),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      showPopover(
                        context: context,
                        bodyBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            subtext,
                            style: regular14.copyWith(color: dark1),
                          ),
                        ),
                        direction: PopoverDirection.bottom,
                        width: 220,
                        height: 100,
                        arrowHeight: 10,
                        arrowWidth: 20,
                        barrierColor: Colors.transparent,
                      );
                    },
                    child: Transform.translate(
                      offset: const Offset(0, -4), // Move up a little
                      child: Icon(
                        Icons.info_outline,
                        color: iconColor,
                        size: 16, // Smaller icon
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
