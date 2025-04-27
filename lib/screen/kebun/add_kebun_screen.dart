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

class AddKebunScreen extends StatefulWidget {
  const AddKebunScreen({super.key});

  @override
  _AddKebunScreenState createState() => _AddKebunScreenState();
}

class _AddKebunScreenState extends State<AddKebunScreen> {
  String? selectedLocation;
  String statusKebun = 'Aktif';

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
            title: 'Manajemen Kebun',
            greeting: 'Tambah Kebun'),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFieldWidget(
                label: "Nama kebun",
                hint: "Contoh: Kebun A",
                controller: _nameController,
              ),
              InputFieldWidget(
                  label: "Lokasi kebun",
                  hint: "Contoh: Rooftop",
                  controller: _locationController),
              InputFieldWidget(
                  label: "Luas kebun",
                  hint: "Contoh: 30m²",
                  controller: _sizeController),
              DropdownFieldWidget(
                label: "Pilih jenis tanaman yang ditanam",
                hint: "Pilih jenis tanaman",
                items: const ["Melon", "Anggur", "Pakcoy"],
                selectedValue: selectedLocation,
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
              ),
              InputFieldWidget(
                  label: "Jumlah tanaman",
                  hint: "Contoh: 20 (satuan tanaman)",
                  controller: _jumlahController),
              RadioField(
                label: 'Status kebun',
                selectedValue: statusKebun,
                options: const ['Aktif', 'Tidak aktif'], // bebas mau apa aja
                onChanged: (value) {
                  setState(() {
                    statusKebun = value;
                  });
                },
              ),
              ImagePickerWidget(
                label: "Unggah gambar kebun",
                image: _image,
                onPickImage: _pickImage,
              ),
              InputFieldWidget(
                  label: "Deskripsi kebun",
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
