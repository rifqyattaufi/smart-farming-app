import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddLaporanHamaScreen extends StatefulWidget {
  const AddLaporanHamaScreen({super.key});

  @override
  _AddLaporanHamaScreenState createState() => _AddLaporanHamaScreenState();
}

class _AddLaporanHamaScreenState extends State<AddLaporanHamaScreen> {
  String? selectedHama;
  String? selectedLocation;
  String hamaStatus = 'Ada';

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

  final TextEditingController _namaHamaController = TextEditingController();
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
              title: 'Pelaporan Khusus',
              greeting: 'Pelaporan Hama'),
        ),
      ),
      body: SafeArea(
        child: ListView(children: [
          const BannerWidget(
            title: 'Isi Form Pelaporan Hama Tanaman',
            subtitle:
                'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
            showDate: true,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioField(
                  label: 'Status hama',
                  selectedValue: hamaStatus,
                  options: const ['Ada', 'Tidak ada'],
                  onChanged: (value) {
                    setState(() {
                      hamaStatus = value;
                    });
                  },
                ),
                DropdownFieldWidget(
                  label: "Jenis hama",
                  hint: "Pilih jenis hama",
                  items: const ["Tikus", "Ulat Bulu", "Lainnya"],
                  selectedValue: selectedHama,
                  onChanged: (value) {
                    setState(() {
                      selectedHama = value;
                    });
                  },
                ),
                if (selectedHama == "Lainnya")
                  InputFieldWidget(
                    label: "Nama hama",
                    hint: "Masukkan nama hama",
                    controller: _namaHamaController,
                  ),
                DropdownFieldWidget(
                  label: "Terlihat di",
                  hint: "Pilih lokasi",
                  items: const ["Kebun A", "Kebun B"],
                  selectedValue: selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                InputFieldWidget(
                    label: "Jumlah hama",
                    hint: "Contoh: 5 (ekor)",
                    controller: _sizeController),
                ImagePickerWidget(
                  label: "Unggah bukti adanya hama",
                  image: _image,
                  onPickImage: _pickImage,
                ),
                InputFieldWidget(
                    label: "Catatan/jurnal pelaporan",
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
