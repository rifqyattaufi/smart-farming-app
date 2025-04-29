import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddTernakScreen extends StatefulWidget {
  const AddTernakScreen({super.key});

  @override
  _AddTernakScreenState createState() => _AddTernakScreenState();
}

class _AddTernakScreenState extends State<AddTernakScreen> {
  String? selectedLocation;
  String statusTernak = 'Ternak';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Manajemen Jenis Hewan',
              greeting: 'Tambah Jenis Hewan'),
        ),
      ),
      body: SafeArea(
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputFieldWidget(
                  label: "Nama hewan ternak",
                  hint: "Contoh: Ayam",
                  controller: _nameController,
                ),
                InputFieldWidget(
                    label: "Nama latin",
                    hint: "Contoh: Gallus gallus domesticus",
                    controller: _latinController),
                RadioField(
                  label: 'Status ternak',
                  selectedValue: statusTernak,
                  options: const ['Ternak', 'Tidak ternak'],
                  onChanged: (value) {
                    setState(() {
                      statusTernak = value;
                    });
                  },
                ),
                ImagePickerWidget(
                  label: "Unggah gambar hewan ternak",
                  image: _image,
                  onPickImage: _pickImage,
                ),
                InputFieldWidget(
                    label: "Deskripsi hewan ternak",
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
      ),
    );
  }
}
