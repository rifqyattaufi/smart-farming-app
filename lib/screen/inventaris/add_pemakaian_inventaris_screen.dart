import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddPemakaianInventarisScreen extends StatefulWidget {
  const AddPemakaianInventarisScreen({super.key});

  @override
  _AddPemakaianInventarisScreenState createState() =>
      _AddPemakaianInventarisScreenState();
}

class _AddPemakaianInventarisScreenState
    extends State<AddPemakaianInventarisScreen> {
  String? selectedLocation;
  String? selectedInv;

  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
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
                    _image = File(pickedFile.path);
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
                    _image = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  final TextEditingController _sizeController = TextEditingController();
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
              title: 'Manajemen Inventaris',
              greeting: 'Tambah Pemakaian Inventaris'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownFieldWidget(
                  label: "Kategori inventaris",
                  hint: "Pilih kategori inventaris",
                  items: const [
                    "Bibit tanaman",
                    "Perlengkapan",
                    "Nutrisi tanaman"
                  ],
                  selectedValue: selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                DropdownFieldWidget(
                  label: "Nama inventaris",
                  hint: "Pilih inventaris",
                  items: const ["Bibit Melon", "Polybag", "Pupuk A"],
                  selectedValue: selectedInv,
                  onChanged: (value) {
                    setState(() {
                      selectedInv = value;
                    });
                  },
                ),
                InputFieldWidget(
                    label: "Jumlah digunakan",
                    hint: "Contoh: 20",
                    controller: _sizeController),
                ImagePickerWidget(
                  label: "Unggah bukti pemakaian",
                  image: _image,
                  onPickImage: _pickImage,
                ),
                InputFieldWidget(
                    label: "Deskripsi keperluan pemakaian",
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
        ),
      ),
    );
  }
}
