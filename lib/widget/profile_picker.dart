import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? image;
  final String? imageUrl;
  final bool isDisabled;
  final void Function(BuildContext context) onPickImage;

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onPickImage,
    this.imageUrl,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: image != null ? FileImage(image!) : null,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipOval(
                    child: ImageBuilder(
                        height: 100,
                        width: 100,
                        url: imageUrl!,
                        fit: BoxFit.cover))
                : image == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null),
        if (!isDisabled)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onPickImage(context),
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
