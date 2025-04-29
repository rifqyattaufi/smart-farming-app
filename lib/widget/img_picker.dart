import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onPickImage;

  const ImagePickerWidget({
    super.key,
    required this.label,
    required this.image,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: semibold14.copyWith(color: dark1),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: DottedBorder(
            color: Colors.green, // Dashed green border
            strokeWidth: 2,
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const [6, 4],
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: image == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 40,
                            color: green1,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Upload",
                            style: semibold16.copyWith(color: green1),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Drag a file here or click in this area to browse\nin your folder explorer",
                              style: medium14.copyWith(
                                  color: green1.withValues(alpha: 0.6)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
