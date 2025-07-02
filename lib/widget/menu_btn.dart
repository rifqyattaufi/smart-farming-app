import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:popover/popover.dart';
import 'package:dotted_border/dotted_border.dart';

class MenuButton extends StatefulWidget {
  final String title;
  final String subtext;
  final dynamic icon; // Changed to dynamic to accept both IconData and String
  final Color backgroundColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.title,
    required this.subtext,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Handle both IconData and asset image paths
          widget.icon is IconData
              ? Icon(widget.icon, color: widget.iconColor, size: 32)
              : Image.asset(
                  widget.icon,
                  width: 32,
                  height: 32,
                  color: widget.iconColor,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(widget.title, style: semibold16.copyWith(color: dark1)),
                const SizedBox(width: 4),
                GestureDetector(
                  key: Key('menu_button_info_${widget.title}'),
                  onTap: () {
                    showPopover(
                      context: context,
                      bodyBuilder: (context) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.subtext,
                          style: regular14.copyWith(color: dark1),
                        ),
                      ),
                      direction: PopoverDirection.bottom,
                      width: 220,
                      arrowHeight: 10,
                      arrowWidth: 20,
                      barrierColor: Colors.transparent,
                    );
                  },
                  child: Transform.translate(
                    offset: const Offset(0, -4),
                    child: Icon(Icons.info_outline,
                        color: widget.iconColor, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
        ],
      ),
    );

    return GestureDetector(
      key: Key('menu_button_${widget.title}'),
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: widget.isSelected
            ? DottedBorder(
                color: green1,
                strokeWidth: 2,
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                dashPattern: const [6, 4],
                child: content,
              )
            : content,
      ),
    );
  }
}
