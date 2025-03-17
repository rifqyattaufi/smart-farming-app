import 'dart:io';
import 'package:flutter/material.dart';

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
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[100],
            ),
            child: image == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
                        Text("Upload", style: TextStyle(color: Colors.grey)),
                        Text("Drag a file here or click to browse",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
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
