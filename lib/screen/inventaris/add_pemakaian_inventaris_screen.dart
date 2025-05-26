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

  String? selectedKategori;
  String? selectedInv;

  bool _isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _kategoriList = [];
  List<Map<String, dynamic>> _inventarisList = [];

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
      if (kategoriResponse['status']) {
        setState(() {
          _kategoriList =
              List<Map<String, dynamic>>.from(kategoriResponse['data']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    try {
      if (!formKey.currentState!.validate()) return;

      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan unggah bukti pemakaian inventaris'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedInv == null || _inventarisList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih inventaris terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Selected Inventaris ID: $selectedInv');

      formKey.currentState!.save();

      final imageUrl = await _imageService.uploadImage(_image!);

      final inventarisNama = _inventarisList.firstWhere(
        (item) => item['id'] == selectedInv,
        orElse: () => {'nama': ''},
      )['nama'];

      // Prepare data
      final data = {
        "judul": "Laporan Pemakaian Inventaris $inventarisNama",
        "tipe": "inventaris",
        "gambar": imageUrl['data'],
        "catatan": _catatanController.text,
        "penggunaanInv": {
          "inventarisId": selectedInv,
          "jumlah": double.tryParse(_sizeController.text) ?? 0,
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat menambahkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
              title: 'Manajemen Inventaris',
              greeting: 'Tambah Pemakaian Inventaris'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownFieldWidget(
                  label: "Kategori Inventaris",
                  hint: "Pilih kategori",
                  items: _kategoriList
                      .map((item) => item['nama'].toString())
                      .toList(),
                  selectedValue: selectedKategori,
                  onChanged: (value) async {
                    setState(() {
                      selectedKategori = value;
                    });
                    // Ambil inventaris sesuai kategori yang dipilih
                    final inventarisResponse = await _inventarisService
                        .getInventarisByKategoriName(value!);
                    if (inventarisResponse['status']) {
                      setState(() {
                        _inventarisList = List<Map<String, dynamic>>.from(
                            inventarisResponse['data']);
                        selectedInv = _inventarisList.isNotEmpty
                            ? _inventarisList.first['id']
                            : null;
                      });
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
                  hint: "Pilih inventaris",
                  items: _inventarisList
                      .map((item) => item['nama'].toString())
                      .toList(),
                  selectedValue: _inventarisList.firstWhere(
                    (item) => item['id'] == selectedInv,
                    orElse: () => {'nama': ''},
                  )['nama'],
                  onChanged: (value) {
                    setState(() {
                      selectedInv = _inventarisList.firstWhere(
                        (item) => item['nama'] == value,
                        orElse: () => {'id': null},
                      )['id'];
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Silakan pilih inventaris';
                    }
                    return null;
                  },
                ),
                InputFieldWidget(
                    label: "Jumlah digunakan",
                    hint: "Contoh: 20",
                    controller: _sizeController),
                ImagePickerWidget(
                  label: "Unggah bukti pemakaian",
                  image: _image,
                  onPickImage: _pickImage,
                ),
                InputFieldWidget(
                    label: "Deskripsi keperluan pemakaian",
                    hint: "Keterangan",
                    controller: _catatanController,
                    maxLines: 10),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: _submitForm,
                  backgroundColor: green1,
                  textStyle: semibold16,
                  textColor: white,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
