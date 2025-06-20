import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/radio_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanHarianTernakScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanHarianTernakScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanHarianTernakScreen> createState() =>
      _PelaporanHarianTernakScreenState();
}

class _PelaporanHarianTernakScreenState
    extends State<PelaporanHarianTernakScreen> {
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();

  String statusPakan = '';
  String statusKandang = '';

  bool isLoading = false;
  File? _imageTernak;
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

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
              key: const Key('camera'),
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
              key: const Key('gallery'),
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

  Future<void> _submitForm() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      if (!formKey.currentState!.validate()) return;

      if (_imageTernak == null) {
        showAppToast(context,
            'Silakan unggah bukti kondisi ternak terlebih dahulu');
        return;
      }

      formKey.currentState!.save();

      final imageUrl = await _imageService.uploadImage(_imageTernak!);

      // Prepare data
      final data = {
        'unitBudidayaId': widget.data?['unitBudidaya']['id'],
        "judul": "Laporan Harian ${widget.data?['unitBudidaya']['name']}",
        "tipe": widget.tipe,
        "gambar": imageUrl['data'],
        "catatan": _catatanController.text,
        "harianTernak": {
          "pakan": statusPakan == 'Ya',
          "cekKandang": statusKandang == 'Ya',
        }
      };

      final response = await _laporanService.createLaporanHarianTernak(data);

      if (response['status']) {
        showAppToast(
          context,
          'Berhasil mengirim laporan harian ternak',
          isError: false,
        );
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }

      for (int i = 0; i < widget.step; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BannerWidget(
                  title: 'Step ${widget.step} - Isi Form Pelaporan',
                  subtitle:
                      'Harap mengisi form dengan data yang benar sesuai kondisi lapangan!',
                  showDate: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Ternak',
                        style: semibold16.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.data?['unitBudidaya']['category'] ?? 'unknown',
                        style: bold20.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.data?['unitBudidaya']['name'] ?? 'unknown',
                        style: semibold16.copyWith(color: dark1),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioField(
                          key: const Key('status_pakan'),
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
                          key: const Key('status_kandang'),
                          label: 'Dilakukan pengecekan kandang?',
                          selectedValue: statusKandang,
                          options: const ['Ya', 'Tidak'],
                          onChanged: (value) {
                            setState(() {
                              statusKandang = value;
                            });
                          },
                        ),
                        ImagePickerWidget(
                          key: const Key('image_picker_ternak'),
                          label: "Unggah bukti kondisi ternak",
                          image: _imageTernak,
                          onPickImage: (context) {
                            _pickImage(context, (file) {
                              setState(() {
                                _imageTernak = file;
                              });
                            });
                          },
                        ),
                        InputFieldWidget(
                            key: const Key('catatan_jurnal'),
                            label: "Catatan/jurnal pelaporan",
                            hint: "Keterangan",
                            controller: _catatanController,
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Catatan tidak boleh kosong';
                              }
                              return null;
                            }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            onPressed: () {
              _submitForm();
            },
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: isLoading,
            key: const Key('submit_pelaporan_harian_ternak_button'),
          ),
        ),
      ),
    );
  }
}
