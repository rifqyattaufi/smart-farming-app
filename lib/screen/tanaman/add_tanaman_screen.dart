import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddTanamanScreen extends StatefulWidget {
  const AddTanamanScreen({super.key});

  @override
  _AddTanamanScreenState createState() => _AddTanamanScreenState();
}

class _AddTanamanScreenState extends State<AddTanamanScreen> {
  String? selectedLocation;
  String statusBudidaya = 'Budidaya';

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
  final TextEditingController _latinController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(
            headerType: HeaderType.menu,
            title: 'Manajemen Jenis Tanaman',
            greeting: 'Tambah Jenis Tanaman'),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFieldWidget(
                label: "Nama jenis tanaman",
                hint: "Contoh: Melon",
                controller: _nameController,
              ),
              InputFieldWidget(
                  label: "Nama latin",
                  hint: "Contoh: Melo melo",
                  controller: _latinController),
              RadioField(
                label: 'Status budidaya',
                selectedValue: statusBudidaya,
                options: const ['Budidaya', 'Tidak budidaya'],
                onChanged: (value) {
                  setState(() {
                    statusBudidaya = value;
                  });
                },
              ),
              ImagePickerWidget(
                label: "Unggah gambar tanaman",
                image: _image,
                onPickImage: _pickImage,
              ),
              InputFieldWidget(
                  label: "Deskripsi tanaman",
                  hint: "Keterangan",
                  controller: _descriptionController,
                  maxLines: 10),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () {
                  // Your action here
                },
                backgroundColor: green1,
                textStyle: semibold16,
                textColor: white,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ]),
    );
  }
}
