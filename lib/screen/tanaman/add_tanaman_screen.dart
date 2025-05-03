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

  File? _imageTanaman;
  final picker = ImagePicker();

  Future<void> _pickImageTanaman(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _imageTanaman = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imageTanaman = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
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
              title: 'Manajemen Jenis Tanaman',
              greeting: 'Tambah Jenis Tanaman'),
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
                  image: _imageTanaman,
                  onPickImage: _pickImageTanaman,
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
      ),
    );
  }
}
