import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
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
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();
  final InventarisService _inventarisService = InventarisService();
  final KategoriInvService _kategoriInvService = KategoriInvService();

  String? selectedKategoriId;
  String? selectedKategoriNama;
  String? selectedInvId;
  String? selectedInvNama;

  bool _isLoading = false;

  File? _image;
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _kategoriList = [];
  List<Map<String, dynamic>> _inventarisList = [];

  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _catatanController.dispose();
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
        _showErrorSnackbar(
            'Gagal memuat kategori: ${kategoriResponse['message'] ?? 'Data tidak valid'}');
      }
    } catch (e) {
      _showErrorSnackbar('Error memuat kategori: $e');
    }
  }

  Future<void> _fetchInventarisByKategori(String kategoriId) async {
    setState(() {
      _inventarisList = [];
      selectedInvId = null;
      selectedInvNama = null;
    });
    try {
      final inventarisResponse =
          await _inventarisService.getInventarisByKategoriId(kategoriId);
      if (inventarisResponse['status'] && inventarisResponse['data'] != null) {
        setState(() {
          _inventarisList =
              List<Map<String, dynamic>>.from(inventarisResponse['data']);
        });
      } else {
        _showErrorSnackbar(
            'Gagal memuat inventaris: ${inventarisResponse['message'] ?? 'Data tidak valid'}');
      }
    } catch (e) {
      _showErrorSnackbar('Error memuat inventaris: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
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
      _showErrorSnackbar('Silakan unggah bukti pemakaian inventaris');
      return;
    }

    if (selectedInvId == null) {
      _showErrorSnackbar('Silakan pilih inventaris terlebih dahulu');
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
        _showErrorSnackbar(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pelaporan pemakaian inventaris berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showErrorSnackbar(
            'Gagal mengirim laporan: ${response['message'] ?? 'Kesalahan tidak diketahui'}');
      }
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan saat menambahkan: $e');
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
      _inventarisList = [];
      _sizeController.clear();
      _catatanController.clear();
      formKey.currentState?.reset();
    });
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
                          _inventarisList = [];
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
                              });
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
                      label: "Jumlah digunakan",
                      hint: "Contoh: 20",
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
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
                  ImagePickerWidget(
                    label: "Unggah bukti pemakaian",
                    image: _image,
                    onPickImage: _pickImage,
                  ),
                  InputFieldWidget(
                      label: "Deskripsi keperluan pemakaian",
                      hint: "Keterangan",
                      controller: _catatanController,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      }),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: _submitForm,
                    backgroundColor: green1,
                    textStyle: semibold16,
                    textColor: white,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
