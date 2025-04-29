import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/radio_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanHarianTernakScreen extends StatefulWidget {
  const PelaporanHarianTernakScreen({super.key});

  @override
  State<PelaporanHarianTernakScreen> createState() =>
      _PelaporanHarianTernakScreenState();
}

class _PelaporanHarianTernakScreenState
    extends State<PelaporanHarianTernakScreen> {
  String statusPakan = '';
  String statusKandang = '';
  String statusNutrisi = '';
  String statusPemberian = '';
  String? selectedBahan;
  String? selectedSatuan;

  File? _imageTernak;
  File? _imageDosis;
  final picker = ImagePicker();

  Future<void> _pickImageTernak() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageTernak = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageDosis() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageDosis = File(pickedFile.path);
      });
    }
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
            title: 'Menu Pelaporan',
            greeting: 'Pelaporan Harian',
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
              bottom: 100), // kasih space bawah biar gak ketutupan tombol
          children: [
            const BannerWidget(
              title: 'Step 3 - Isi Form Pelaporan',
              subtitle:
                  'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
              showDate: true,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioField(
                    label: 'Dilakukan pemberian pakan?',
                    selectedValue: statusPakan,
                    options: const ['Ya', 'Belum'],
                    onChanged: (value) {
                      setState(() {
                        statusPakan = value;
                      });
                    },
                  ),
                  RadioField(
                    label: 'Dilakukan pengecekan kandang?',
                    selectedValue: statusKandang,
                    options: const ['Ya', 'Tidak'],
                    onChanged: (value) {
                      setState(() {
                        statusKandang = value;
                      });
                    },
                  ),
                  RadioField(
                    label: 'Dilakukan pemberian vaksin/vitamin/disinfektan?',
                    selectedValue: statusNutrisi,
                    options: const ['Ya', 'Tidak'],
                    onChanged: (value) {
                      setState(() {
                        statusNutrisi = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah bukti kondisi ternak",
                    image: _imageTernak,
                    onPickImage: _pickImageTernak,
                  ),
                  InputFieldWidget(
                      label: "Catatan/jurnal pelaporan",
                      hint: "Keterangan",
                      controller: _catatanController,
                      maxLines: 10),
                  if (statusNutrisi == 'Ya')
                    RadioField(
                      label: 'Jenis Pemberian',
                      selectedValue: statusPemberian,
                      options: const [
                        'Vitamin',
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
                    items: const ["Vaksin A", "Vaksin B", "Vaksin C"],
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
                    label: "Unggah bukti pemberian dosis ke ternak",
                    image: _imageDosis,
                    onPickImage: _pickImageDosis,
                  ),
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
          onPressed: () {
            // Your action here
          },
          backgroundColor: green1,
          textStyle: semibold16,
          textColor: white,
        ),
      ),
    );
  }
}
