import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanTernakPanenScreen extends StatefulWidget {
  const PelaporanTernakPanenScreen({super.key});

  @override
  State<PelaporanTernakPanenScreen> createState() =>
      _PelaporanTernakPanenScreenState();
}

class _PelaporanTernakPanenScreenState
    extends State<PelaporanTernakPanenScreen> {
  String? selectedSatuan;
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

  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();

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
            greeting: 'Pelaporan Panen Ternak',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const BannerWidget(
              title: 'Step 3 - Isi Form Pelaporan',
              subtitle:
                  'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
              showDate: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Komoditas Ternak',
                    style: semibold16.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ayam - Telur',
                    style: bold20.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gallus gallus domesticus - Kandang A',
                    style: semibold16.copyWith(color: dark1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                    label: "Jumlah panen",
                    hint: "Contoh: 20",
                    controller: _sizeController,
                  ),
                  DropdownFieldWidget(
                    label: "Satuan panen",
                    hint: "Pilih satuan panen",
                    items: const ["Kg", "Kwintal", "Ton"],
                    selectedValue: selectedSatuan,
                    onChanged: (value) {
                      setState(() {
                        selectedSatuan = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah bukti hasil panen",
                    image: _image,
                    onPickImage: _pickImage,
                  ),
                  InputFieldWidget(
                      label: "Catatan/jurnal pelaporan",
                      hint: "Keterangan",
                      controller: _catatanController,
                      maxLines: 10),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          onPressed: () {},
          backgroundColor: green1,
          textStyle: semibold16,
          textColor: white,
        ),
      ),
    );
  }
}
