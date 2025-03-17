import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddGardenScreen extends StatefulWidget {
  const AddGardenScreen({super.key});

  @override
  _AddGardenScreenState createState() => _AddGardenScreenState();
}

class _AddGardenScreenState extends State<AddGardenScreen> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Kebun"),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImagePickerWidget(
              label: "Gambar Kebun",
              image: _image,
              onPickImage: _pickImage,
            ),
            InputFieldWidget(
              label: "Nama Kebun",
              hint: "Contoh: Kebun A",
              controller: _nameController,
            ),
            InputFieldWidget(
                label: "Lokasi Kebun",
                hint: "Contoh: Rooftop",
                controller: _locationController),
            InputFieldWidget(
                label: "Luas Kebun",
                hint: "Contoh: 30m²",
                controller: _sizeController),
            InputFieldWidget(
                label: "Deskripsi Kebun",
                hint: "Keterangan",
                controller: _descriptionController,
                maxLines: 3),
            const SizedBox(height: 16),
            SubmitButton(onPressed: () {
              // Handle Submit
            }),
          ],
        ),
      ),
    );
  }
}
