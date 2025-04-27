import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class ImagePickerWidget extends StatelessWidget {
  final String label;
  final File? image;
  final VoidCallback onPickImage;

  const ImagePickerWidget(
      {super.key,
      required this.label,
      required this.image,
      required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: semibold14.copyWith(color: dark1)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: image == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload,
                            size: 40, color: Colors.grey),
                        Text("Upload", style: semibold16.copyWith(color: grey)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                              "Drag a file here or click in this area to browse \nin your folder explorer",
                              style: medium14.copyWith(color: grey),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image!,
                        fit: BoxFit.cover, width: double.infinity),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
