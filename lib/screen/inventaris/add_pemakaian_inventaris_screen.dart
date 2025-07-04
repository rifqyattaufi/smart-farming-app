import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class AddPemakaianInventarisScreen extends StatefulWidget {
  const AddPemakaianInventarisScreen({super.key});

  @override
  _AddPemakaianInventarisScreenState createState() =>
      _AddPemakaianInventarisScreenState();
}

class _AddPemakaianInventarisScreenState
    extends State<AddPemakaianInventarisScreen> {
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();
  final InventarisService _inventarisService = InventarisService();
  final KategoriInvService _kategoriInvService = KategoriInvService();
  final SatuanService _satuanService = SatuanService();

  String? selectedKategoriId;
  String? selectedKategoriNama;
  String? selectedInvId;
  String? selectedInvNama;
  String? selectedInvSatuanId;

  bool _isLoading = false;

  File? _image;
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _kategoriList = [];
  List<Map<String, dynamic>> _inventarisList = [];

  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _catatanController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

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
                  if (mounted) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
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
                  if (mounted) {
                    setState(() {
                      _image = File(pickedFile.path);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchKategori() async {
    try {
      final kategoriResponse =
          await _kategoriInvService.getKategoriInventarisOnly();
      if (kategoriResponse['status'] && kategoriResponse['data'] != null) {
        setState(() {
          _kategoriList =
              List<Map<String, dynamic>>.from(kategoriResponse['data']);
        });
      } else {
        showAppToast(
            context, kategoriResponse['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _fetchInventarisByKategori(String kategoriId) async {
    setState(() {
      _inventarisList = [];
      selectedInvId = null;
      selectedInvNama = null;
      selectedInvSatuanId = null;
      _satuanController.clear();
    });
    try {
      final inventarisResponse =
          await _inventarisService.getInventarisByKategoriId(kategoriId);
      if (inventarisResponse['status'] && inventarisResponse['data'] != null) {
        setState(() {
          final today = DateTime.now();
          _inventarisList = List<Map<String, dynamic>>.from(
            (inventarisResponse['data'] as List).where((item) {
              final jumlah = item['jumlah'] ?? 0;
              final tanggalKadaluwarsaStr = item['tanggalKadaluwarsa'];
              if (tanggalKadaluwarsaStr == null) return false;
              final tanggalKadaluwarsa =
                  DateTime.tryParse(tanggalKadaluwarsaStr);
              if (tanggalKadaluwarsa == null) return false;
              return jumlah > 0 &&
                  !tanggalKadaluwarsa
                      .isBefore(DateTime(today.year, today.month, today.day));
            }).map((item) => {
                  'id': item['id'],
                  'nama': item['nama'],
                  'satuanId': item['SatuanId'],
                  'jumlah': item['jumlah'],
                  'tanggalKadaluwarsa': item['tanggalKadaluwarsa'],
                }),
          );
        });
      } else {
        showAppToast(
            context, inventarisResponse['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (_image == null) {
      showAppToast(context, 'Silakan unggah bukti pemakaian inventaris');
      return;
    }

    if (selectedInvId == null) {
      showAppToast(context, 'Silakan pilih inventaris terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      formKey.currentState!.save();

      final imageUrlResponse = await _imageService.uploadImage(_image!);
      if (!(imageUrlResponse['status'] ?? false) ||
          imageUrlResponse['data'] == null) {
        showAppToast(context,
            'Gagal mengunggah gambar: ${imageUrlResponse['message'] ?? 'URL tidak valid'}');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final imageUrl = imageUrlResponse['data'];

      final inventarisYangDipilih = _inventarisList.firstWhere(
        (item) => item['id'] == selectedInvId,
        orElse: () => {'nama': 'Tidak Diketahui'},
      );
      final inventarisNama = inventarisYangDipilih['nama'];

      final data = {
        "judul": "Laporan Pemakaian Inventaris $inventarisNama",
        "tipe": "inventaris",
        "gambar": imageUrl,
        "catatan": _catatanController.text,
        "penggunaanInv": {
          "inventarisId": selectedInvId,
          "jumlah": double.tryParse(_sizeController.text) ?? 0.0,
        }
      };

      final response =
          await _laporanService.createLaporanPenggunaanInventaris(data);

      if (response['status']) {
        showAppToast(
            context, 'Berhasil menambahkan laporan pemakaian inventaris',
            isError: false);
        _resetForm();
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        showAppToast(
            context,
            response['message'] ??
                'Gagal menambahkan laporan pemakaian inventaris');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _image = null;
      selectedKategoriId = null;
      selectedKategoriNama = null;
      selectedInvId = null;
      selectedInvNama = null;
      selectedInvSatuanId = null;
      _inventarisList = [];
      _sizeController.clear();
      _catatanController.clear();
      _satuanController.clear();
      formKey.currentState?.reset();
    });
  }

  Future<void> _changeSatuan() async {
    if (selectedInvSatuanId != null) {
      try {
        final response =
            await _satuanService.getSatuanById(selectedInvSatuanId!);
        if (response['status']) {
          setState(() {
            _satuanController.text =
                "${response['data']['nama']} - ${response['data']['lambang']}";
          });
        } else {
          setState(() {
            _satuanController.text = "Satuan tidak ditemukan";
          });
          showAppToast(
              context, 'Error fetching satuan data: ${response['message']}',
              title: 'Error Tidak Terduga 😢');
        }
      } catch (e) {
        setState(() {
          _satuanController.text = "Error memuat satuan";
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } else {
      setState(() {
        _satuanController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownFieldWidget(
                    key: const Key('kategori_inventaris'),
                    label: "Kategori Inventaris",
                    hint: "Pilih kategori",
                    items: _kategoriList
                        .map((item) => item['nama']?.toString() ?? '')
                        .toList(),
                    selectedValue: selectedKategoriNama,
                    onChanged: (value) {
                      if (value == null) return;
                      final selected = _kategoriList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {});

                      if (selected.isNotEmpty && selected['id'] != null) {
                        setState(() {
                          selectedKategoriId = selected['id'].toString();
                          selectedKategoriNama = selected['nama'].toString();

                          selectedInvId = null;
                          selectedInvNama = null;
                          selectedInvSatuanId = null;
                          _inventarisList = [];
                          _satuanController.clear();
                        });
                        _fetchInventarisByKategori(selectedKategoriId!);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Silakan pilih kategori';
                      }
                      return null;
                    },
                  ),
                  DropdownFieldWidget(
                    key: const Key('nama_inventaris'),
                    label: "Nama inventaris",
                    hint: selectedKategoriId == null
                        ? "Pilih kategori terlebih dahulu"
                        : (_inventarisList.isEmpty && selectedKategoriId != null
                            ? "Tidak ada inventaris pada kategori ini"
                            : "Pilih inventaris"),
                    items: _inventarisList
                        .map((item) => item['nama']?.toString() ?? '')
                        .toList(),
                    selectedValue: selectedInvNama,
                    onChanged: (selectedKategoriId == null ||
                            _inventarisList.isEmpty)
                        ? null
                        : (value) {
                            if (value == null) {
                              setState(() {
                                selectedInvId = null;
                                selectedInvNama = null;
                                selectedInvSatuanId = null;
                                _satuanController.clear();
                              });
                              return;
                            }
                            final selected = _inventarisList.firstWhere(
                                (item) => item['nama'] == value,
                                orElse: () => {});
                            if (selected.isNotEmpty && selected['id'] != null) {
                              setState(() {
                                selectedInvId = selected['id'].toString();
                                selectedInvNama = value;
                                selectedInvSatuanId =
                                    selected['satuanId']?.toString();
                              });
                              _changeSatuan();
                            }
                          },
                    validator: (value) {
                      if (selectedKategoriId != null &&
                          _inventarisList.isNotEmpty &&
                          (value == null || value.isEmpty)) {
                        return 'Silakan pilih inventaris';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      key: const Key('jumlah_digunakan_input'),
                      label: "Jumlah digunakan",
                      hint: "Contoh: 20.5",
                      controller: _sizeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Jumlah harus berupa angka';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Jumlah harus lebih dari 0';
                        }
                        return null;
                      }),
                  InputFieldWidget(
                    key: const Key('satuan_input'),
                    label: "Satuan",
                    hint: "Satuan akan tampil otomatis",
                    controller: _satuanController,
                    isDisabled: true,
                    validator: (value) {
                      if (selectedInvId != null &&
                          (value == null || value.isEmpty)) {
                        return 'Satuan tidak tersedia untuk inventaris ini';
                      }
                      return null;
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah bukti pemakaian",
                    key: const Key('bukti_pemakaian_input'),
                    image: _image,
                    onPickImage: (BuildContext imagePickerContext) {
                      _pickImage(context);
                    },
                  ),
                  InputFieldWidget(
                      key: const Key('catatan_input'),
                      label: "Deskripsi keperluan pemakaian",
                      hint: "Keterangan",
                      controller: _catatanController,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      }),
                ],
              ),
            ),
          ),
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
            key: const Key('submit_pemakaian_inventaris_button'),
          ),
        ),
      ),
    );
  }
}
