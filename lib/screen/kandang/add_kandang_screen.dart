import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddKandangScreen extends StatefulWidget {
  const AddKandangScreen({super.key});

  @override
  _AddKandangScreenState createState() => _AddKandangScreenState();
}

class _AddKandangScreenState extends State<AddKandangScreen> {
  String? selectedLocation;
  String statusKandang = 'Aktif';

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
  final TextEditingController _jumlahController = TextEditingController();
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
            title: 'Manajemen Kandang',
            greeting: 'Tambah Kandang'),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFieldWidget(
                label: "Nama kandang",
                hint: "Contoh: kandang A",
                controller: _nameController,
              ),
              InputFieldWidget(
                  label: "Lokasi kandang",
                  hint: "Contoh: Rooftop",
                  controller: _locationController),
              InputFieldWidget(
                  label: "Luas kandang",
                  hint: "Contoh: 30m²",
                  controller: _sizeController),
              DropdownFieldWidget(
                label: "Pilih jenis hewan ternak yang diternak",
                hint: "Pilih jenis hewan ternak",
                items: const ["Ayam", "Lele", "Kepiting"],
                selectedValue: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),
              InputFieldWidget(
                  label: "Jumlah hewan ternak",
                  hint: "Contoh: 20 (satuan ekor)",
                  controller: _jumlahController),
              RadioField(
                label: 'Status kandang',
                selectedValue: statusKandang,
                options: const ['Aktif', 'Tidak aktif'], // bebas mau apa aja
                onChanged: (value) {
                  setState(() {
                    statusKandang = value;
                  });
                },
              ),
              ImagePickerWidget(
                label: "Unggah gambar kandang",
                image: _image,
                onPickImage: _pickImage,
              ),
              InputFieldWidget(
                  label: "Deskripsi kandang",
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
