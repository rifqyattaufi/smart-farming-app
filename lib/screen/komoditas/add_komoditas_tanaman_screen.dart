import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddKomoditasTanamanScreen extends StatefulWidget {
  const AddKomoditasTanamanScreen({super.key});

  @override
  _AddKomoditasTanamanScreenState createState() =>
      _AddKomoditasTanamanScreenState();
}

class _AddKomoditasTanamanScreenState extends State<AddKomoditasTanamanScreen> {
  String? selectedLocation;
  String? selectedSatuan;

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
              title: 'Manajemen Komoditas',
              greeting: 'Tambah Komoditas'),
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
                    label: "Nama komoditas",
                    hint: "Contoh: Buah Melon",
                    controller: _nameController),
                DropdownFieldWidget(
                  label: "Pilih jenis tanaman",
                  hint: "Pilih jenis tanaman",
                  items: const ["Melon", "Anggur", "Pakcoy"],
                  selectedValue: selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                DropdownFieldWidget(
                  label: "Satuan",
                  hint: "Pilih satuan",
                  items: const ["Kg", "Pack", "Ml", "Unit"],
                  selectedValue: selectedSatuan,
                  onChanged: (value) {
                    setState(() {
                      selectedSatuan = value;
                    });
                  },
                ),
                ImagePickerWidget(
                  label: "Unggah gambar komoditas",
                  image: _image,
                  onPickImage: _pickImage,
                ),
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
