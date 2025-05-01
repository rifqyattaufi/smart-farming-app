import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/radio_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanHarianTanamanScreen extends StatefulWidget {
  const PelaporanHarianTanamanScreen({super.key});

  @override
  State<PelaporanHarianTanamanScreen> createState() =>
      _PelaporanHarianTanamanScreenState();
}

class _PelaporanHarianTanamanScreenState
    extends State<PelaporanHarianTanamanScreen> {
  String statusPenyiraman = '';
  String statusPruning = '';
  String statusNutrisi = '';
  String statusRepotting = '';
  String statusPemberian = '';
  String? selectedBahan;
  String? selectedSatuan;

  File? _imageTanaman;
  File? _imageDosis;
  final picker = ImagePicker();

  Future<void> _pickImage(
      BuildContext context, Function(File) onImagePicked) async {
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
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  onImagePicked(File(pickedFile.path));
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
                  onImagePicked(File(pickedFile.path));
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
            title: 'Menu Pelaporan',
            greeting: 'Pelaporan Harian',
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
                    'Data Tanaman',
                    style: semibold16.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Melon #1',
                    style: bold20.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Melon Fujisawa - Kebun A',
                    style: semibold16.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tanggal dan waktu tanam: ',
                    style: regular14.copyWith(color: dark1),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy HH:mm')
                        .format(DateTime.now()),
                    style: regular14.copyWith(color: dark1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioField(
                    label: 'Dilakukan penyiraman?',
                    selectedValue: statusPenyiraman,
                    options: const ['Ya', 'Belum'],
                    onChanged: (value) {
                      setState(() {
                        statusPenyiraman = value;
                      });
                    },
                  ),
                  RadioField(
                    label: 'Dilakukan pruning?',
                    selectedValue: statusPruning,
                    options: const ['Ya', 'Tidak'],
                    onChanged: (value) {
                      setState(() {
                        statusPruning = value;
                      });
                    },
                  ),
                  RadioField(
                    label: 'Dilakukan pemberian pupuk/vitamin/disinfektan?',
                    selectedValue: statusNutrisi,
                    options: const ['Ya', 'Tidak'],
                    onChanged: (value) {
                      setState(() {
                        statusNutrisi = value;
                      });
                    },
                  ),
                  RadioField(
                    label:
                        'Dilakukan repotting (pemindahan pot/mengganti media tanam)?',
                    selectedValue: statusRepotting,
                    options: const ['Ya', 'Tidak'],
                    onChanged: (value) {
                      setState(() {
                        statusRepotting = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah bukti kondisi tanaman",
                    image: _imageTanaman,
                    onPickImage: (context) {
                      _pickImage(context, (file) {
                        setState(() {
                          _imageTanaman = file;
                        });
                      });
                    },
                  ),
                  InputFieldWidget(
                      label: "Catatan/jurnal pelaporan",
                      hint: "Keterangan",
                      controller: _catatanController,
                      maxLines: 10),
                  if (statusNutrisi == 'Ya') ...[
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
                      onPickImage: (context) {
                        _pickImage(context, (file) {
                          setState(() {
                            _imageDosis = file;
                          });
                        });
                      },
                    ),
                  ],
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
