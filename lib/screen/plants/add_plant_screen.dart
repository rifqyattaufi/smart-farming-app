import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
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
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Tanaman"),
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
              label: "Gambar Tanaman",
              image: _image,
              onPickImage: _pickImage,
            ),
            InputFieldWidget(
              label: "Nama Tanaman",
              hint: "Contoh: Melon",
              controller: _nameController,
            ),
            DropdownFieldWidget(
              label: "Lokasi Kebun",
              hint: "Pilih lokasi",
              items: ["Kebun A", "Kebun B", "Kebun C"],
              selectedValue: selectedLocation,
              onChanged: (newValue) {
                setState(() {
                  selectedLocation = newValue;
                });
              },
            ),
            InputFieldWidget(
              label: "Jumlah Tanaman",
              hint: "Contoh: 20",
              controller: _sizeController,
            ),
            InputFieldWidget(
              label: "Deskripsi Tanaman",
              hint: "Keterangan",
              controller: _descriptionController,
              maxLines: 3,
            ),
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
