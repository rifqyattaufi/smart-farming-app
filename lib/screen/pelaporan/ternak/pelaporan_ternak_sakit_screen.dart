import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanTernakSakitScreen extends StatefulWidget {
  final String greeting;
  final String tipe;
  final int step;
  final Map<String, dynamic> data;

  const PelaporanTernakSakitScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanTernakSakitScreen> createState() =>
      _PelaporanTernakSakitScreenState();
}

class _PelaporanTernakSakitScreenState
    extends State<PelaporanTernakSakitScreen> {
  final LaporanService _laporanService = LaporanService();
  final ImageService _imageService = ImageService();
  bool _isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _catatanController = [];
  List<TextEditingController> _nameController = [];
  List<File?> _imageList = [];

  Future<void> _pickImageTernak(BuildContext context, int index) async {
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
              key: const Key('open_camera'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _imageList[index] = _image;
                  });
                }
              },
            ),
            ListTile(
              key: const Key('open_gallery'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _imageList[index] = _image;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final objekBudidayaList = widget.data['objekBudidaya'] ?? [null];
    final list = (objekBudidayaList == null ||
            (objekBudidayaList is List && objekBudidayaList.isEmpty))
        ? [null]
        : objekBudidayaList;

    bool allValid = true;
    for (int i = 0; i < list.length; i++) {
      if (!_formKeys[i].currentState!.validate()) {
        allValid = false;
      }

      if (_imageList[i] == null && allValid == true) {
        allValid = false;
        showAppToast(context,
            'Gambar bukti sakit ${(list[i]?['name'] ?? widget.data['komoditas']?['name'] ?? '')} belum dipilih',
            isError: true);
      }
    }
    if (!allValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      for (var i = 0; i < list.length; i++) {
        final imageUrl = await _imageService.uploadImage(_imageList[i]!);

        final data = {
          'unitBudidayaId': widget.data['unitBudidaya']?['id'],
          'objekBudidayaId': list[i]?['id'],
          'tipe': widget.tipe,
          'judul': (list[i]?['name'] != null &&
                  (list[i]?['name'] as String).isNotEmpty)
              ? "Laporan Sakit ${widget.data['unitBudidaya']?['name'] ?? ''} - ${list[i]?['name']}"
              : "Laporan Sakit ${widget.data['unitBudidaya']?['name'] ?? ''}",
          'gambar': imageUrl['data'],
          'catatan': _catatanController[i].text,
          'sakit': {
            'penyakit': _nameController[i].text,
          }
        };

        final response = await _laporanService.createLaporanSakit(data);

        if (response['status']) {
          showAppToast(
            context,
            'Berhasil mengirim laporan sakit ${(list[i]?['name'] ?? widget.data['komoditas']?['name'] ?? '')}',
            isError: false,
          );
        } else {
          showAppToast(context,
              'Gagal mengirim laporan sakit ${(list[i]?['name'] ?? widget.data['komoditas']?['name'] ?? '')}: ${response['message']}');
        }
      }

      for (int i = 0; i < widget.step; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final objekBudidayaList = widget.data['objekBudidaya'] ?? [null];
    final length = objekBudidayaList.length;
    _catatanController = List.generate(length, (_) => TextEditingController());
    _nameController = List.generate(length, (_) => TextEditingController());
    _imageList = List.generate(length, (_) => null);
    _formKeys.clear();
    _formKeys.addAll(List.generate(length, (_) => GlobalKey<FormState>()));
  }

  @override
  Widget build(BuildContext context) {
    final objekBudidayaList = widget.data['objekBudidaya'] ?? [null];

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
            greeting: 'Pelaporan Ternak Sakit',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                BannerWidget(
                  title: 'Step ${widget.step} - Isi Form Pelaporan',
                  subtitle:
                      'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
                  showDate: true,
                ),
                ...List.generate(objekBudidayaList.length, (i) {
                  final objek = objekBudidayaList[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKeys[i],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Ternak',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ((objek?['name'] != null &&
                                        (objek?['name'] as String).isNotEmpty)
                                    ? '${objek?['name']} - '
                                    : '') +
                                (widget.data['unitBudidaya']?['category'] ??
                                    '-'),
                            style: bold20.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.data['unitBudidaya']['latin']} - ${widget.data['unitBudidaya']['name']}',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          InputFieldWidget(
                            key: Key('nama_penyakit_ternak_$i'),
                            label: "Nama penyakit ternak",
                            hint: "Contoh: Cacingan",
                            controller: _nameController[i],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama penyakit tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          ImagePickerWidget(
                              key: Key('image_picker_ternak_$i'),
                              label: "Unggah bukti kondisi ternak",
                              image: _imageList[i],
                              onPickImage: (ctx) async {
                                _pickImageTernak(context, i);
                              }),
                          InputFieldWidget(
                            key: Key('catatan_ternak_$i'),
                            label: "Catatan/jurnal pelaporan",
                            hint: "Keterangan",
                            controller: _catatanController[i],
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Catatan tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const Divider()
                        ],
                      ),
                    ),
                  );
                }),
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
            onPressed: _submitForm,
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: _isLoading,
            key: const Key('submit_pelaporan_ternak_sakit_button')
          ),
        ),
      ),
    );
  }
}
