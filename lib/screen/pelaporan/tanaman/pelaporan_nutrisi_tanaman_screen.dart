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
import 'package:smart_farming_app/widget/radio_field.dart';

class PelaporanNutrisiTanamanScreen extends StatefulWidget {
  const PelaporanNutrisiTanamanScreen({super.key});

  @override
  State<PelaporanNutrisiTanamanScreen> createState() =>
      _PelaporanNutrisiTanamanScreenState();
}

class _PelaporanNutrisiTanamanScreenState
    extends State<PelaporanNutrisiTanamanScreen> {
  String statusPemberian = '';
  String? selectedBahan;
  String? selectedSatuan;

  File? _imageDosis;
  final picker = ImagePicker();

  Future<void> _pickImageDosis(BuildContext context) async {
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
                    _imageDosis = File(pickedFile.path);
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
                    _imageDosis = File(pickedFile.path);
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
            greeting: 'Pelaporan Nutrisi Tanaman',
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
                  RadioField(
                    label: 'Jenis Pemberian',
                    selectedValue: statusPemberian,
                    options: const [
                      'Vitamin',
                      'Pupuk',
                      'Vaksin',
                      'Disinfektan'
                    ],
                    onChanged: (value) {
                      setState(() {
                        statusPemberian = value;
                      });
                    },
                  ),
                  DropdownFieldWidget(
                    label: "Nama bahan",
                    hint: "Pilih jenis bahan",
                    items: const ["Pupuk A", "Pupuk B", "Pupuk C"],
                    selectedValue: selectedBahan,
                    onChanged: (value) {
                      setState(() {
                        selectedBahan = value;
                      });
                    },
                  ),
                  InputFieldWidget(
                    label: "Jumlah/dosis",
                    hint: "Contoh: 10",
                    controller: _sizeController,
                  ),
                  DropdownFieldWidget(
                    label: "Satuan dosis",
                    hint: "Pilih satuan dosis",
                    items: const ["ml", "gram", "liter"],
                    selectedValue: selectedSatuan,
                    onChanged: (value) {
                      setState(() {
                        selectedSatuan = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah bukti pemberian dosis ke tanaman",
                    image: _imageDosis,
                    onPickImage: _pickImageDosis,
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
