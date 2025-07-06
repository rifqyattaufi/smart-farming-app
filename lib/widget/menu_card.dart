import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class MenuCard extends StatefulWidget {
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
  State<MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 165),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: widget.iconColor,
                  child: Icon(widget.icon, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  style: bold18.copyWith(color: dark1),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildSubtitleWithExpandButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleWithExpandButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Deteksi ukuran layar
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 400;

        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.subtitle,
            style: medium14.copyWith(color: dark1),
          ),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        // Pada layar besar, tampilkan semua teks tanpa tombol expand
        if (isLargeScreen) {
          return Text(
            widget.subtitle,
            style: medium14.copyWith(color: dark1),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subtitle,
              style: medium14.copyWith(color: dark1),
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded
                      ? 'Tampilkan lebih sedikit'
                      : 'Tampilkan lebih banyak',
                  style: medium12.copyWith(color: widget.iconColor),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
