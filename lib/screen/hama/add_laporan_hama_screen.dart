import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class AddLaporanHamaScreen extends StatefulWidget {
  final Map<String, dynamic>? data;

  const AddLaporanHamaScreen({super.key, this.data = const {}});

  @override
  AddLaporanHamaScreenState createState() => AddLaporanHamaScreenState();
}

class AddLaporanHamaScreenState extends State<AddLaporanHamaScreen> {
  final HamaService _hamaService = HamaService();
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> hamaList = [];
  List<Map<String, dynamic>> unitList = [];

  String? selectedHama;
  String? selectedLocation;
  String hamaStatus = '';

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
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getJenisHama() async {
    final response = await _hamaService.getDaftarHama();
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        hamaList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();

        hamaList.add({'id': 'lainnya', 'nama': 'Lainnya'});
      });
    } else {
      showAppToast(context, response['message'] ?? 'Gagal memuat data');
    }
  }

  Future<void> _getUnitBudidaya() async {
    final response =
        await _unitBudidayaService.getUnitBudidayaByTipe('tumbuhan');
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        unitList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();
      });
    } else {
      showAppToast(context, response['message'] ?? 'Gagal memuat data');
    }
  }

  final TextEditingController _namaHamaController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  Map<String, dynamic> imageUrl = {};

  @override
  void initState() {
    super.initState();
    _getJenisHama();
    _getUnitBudidaya();
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      if (_image == null) {
        showAppToast(context, 'Silakan unggah bukti adanya hama');
        return;
      }

      _formKey.currentState!.save();

      String? newCreatedHamaId;

      if (selectedHama == 'lainnya') {
        final newHamaResponse = await _hamaService.createJenisHama({
          'nama': _namaHamaController.text,
        });

        if (newHamaResponse['status'] == true) {
          newCreatedHamaId = newHamaResponse['data']['id'];
        } else {
          showAppToast(
              context,
              newHamaResponse['message'] ??
                  'Gagal menambahkan jenis hama baru');
          return;
        }
      }

      // Menggunakan id baru jika ada
      final selectedNamaHama = hamaList.firstWhere(
        (item) => item['id'] == selectedHama,
        orElse: () => {'nama': ''},
      )['nama'];

      final imageUrl = await _imageService.uploadImage(_image!);

      final data = {
        'unitBudidayaId': selectedLocation,
        'tipe': 'hama',
        'judul':
            "Laporan Hama ${selectedHama == 'lainnya' ? _namaHamaController.text : selectedNamaHama}",
        'gambar': imageUrl.isNotEmpty ? imageUrl['data'] : '',
        'catatan': _catatanController.text,
        'hama': {
          'jenisHamaId':
              newCreatedHamaId ?? selectedHama, // Gunakan id baru jika ada
          'jumlah': int.parse(_sizeController.text),
          'status': 1
        }
      };

      final response = await _laporanService.createLaporanHama(data);

      if (response['status'] == true) {
        showAppToast(context,
            'Pelaporan Hama Tanaman ${selectedHama == 'lainnya' ? _namaHamaController.text : selectedNamaHama} berhasil ditambahkan',
            isError: false);

        // Navigate back to hama screen
        context.go('/laporan-hama');
      } else {
        setState(() => _isLoading = false);
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
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
              title: 'Pelaporan Khusus',
              greeting: 'Pelaporan Hama'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const BannerWidget(
              title: 'Isi Form Pelaporan Hama Tanaman',
              subtitle:
                  'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
              showDate: true,
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownFieldWidget(
                      key: const Key('jenis_hama'),
                      label: "Jenis hama",
                      hint: "Pilih jenis hama",
                      items: hamaList
                          .map((item) => item['nama'].toString())
                          .toList(),
                      selectedValue: hamaList.firstWhere(
                        (item) => item['id'] == selectedHama,
                        orElse: () => {'nama': ''},
                      )['nama'],
                      onChanged: (value) {
                        setState(() {
                          selectedHama = hamaList.firstWhere(
                            (item) => item['nama'] == value,
                            orElse: () => {'id': null},
                          )['id'];
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenis hama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    if (selectedHama == "lainnya")
                      InputFieldWidget(
                        key: const Key('nama_hama_lainnya'),
                        label: "Nama hama",
                        hint: "Masukkan nama hama",
                        controller: _namaHamaController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Hama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    DropdownFieldWidget(
                      key: const Key('lokasi_hama'),
                      label: "Terlihat di",
                      hint: "Pilih lokasi",
                      items: unitList
                          .map((item) => item['nama'].toString())
                          .toList(),
                      selectedValue: unitList.firstWhere(
                        (item) => item['id'] == selectedLocation,
                        orElse: () => {'nama': ''},
                      )['nama'],
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = unitList.firstWhere(
                            (item) => item['nama'] == value,
                            orElse: () => {'id': null},
                          )['id'];
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    InputFieldWidget(
                        key: const Key('jumlah_hama_input'),
                        label: "Jumlah hama",
                        hint: "Contoh: 5 (ekor)",
                        controller: _sizeController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah hama tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Jumlah hama harus berupa angka';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Jumlah hama harus lebih dari 0';
                          }
                          return null;
                        }),
                    ImagePickerWidget(
                      key: const Key('bukti_hama_image_picker'),
                      label: "Unggah bukti adanya hama",
                      image: _image,
                      onPickImage: _pickImage,
                    ),
                    InputFieldWidget(
                        key: const Key('catatan_pelaporan'),
                        label: "Catatan/jurnal pelaporan",
                        hint: "Keterangan",
                        controller: _catatanController,
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkkan catatan pelaporan';
                          }
                          return null;
                        }),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            onPressed: _submitForm,
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: _isLoading,
            key: const Key('submit_laporan_hama_button'),
          ),
        ),
      ),
    );
  }
}
