import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final String label;
  final File? image;
  final String? imageUrl;
  final void Function(BuildContext context) onPickImage;

  const ImagePickerWidget({
    super.key,
    required this.label,
    required this.image,
    this.imageUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageDisplay;

    if (image != null) {
      imageDisplay = Image.file(
        image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageDisplay = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey));
        },
      );
    } else {
      imageDisplay = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload,
            size: 40,
            color: green1,
          ),
          const SizedBox(height: 8),
          Text(
            "Unggah file atau ambil foto langsung",
            style: semibold16.copyWith(color: green1),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Ketuk di sini untuk memilih file dari perangkat Anda atau buka kamera.",
              style: medium14.copyWith(color: green1.withValues(alpha: .6)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: semibold14.copyWith(color: dark1),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => onPickImage(context),
          child: DottedBorder(
            color: green1,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageDisplay,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
