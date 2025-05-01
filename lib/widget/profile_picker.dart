import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onPickImage;

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[200],
          backgroundImage: image != null ? FileImage(image!) : null,
          child: image == null
              ? const Icon(Icons.person, size: 50, color: Colors.grey)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onPickImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: yellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
