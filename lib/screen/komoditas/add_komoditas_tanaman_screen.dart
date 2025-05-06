import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddKomoditasTanamanScreen extends StatefulWidget {
  final VoidCallback? onKomoditasTanamanAdded;
  final bool isEdit;

  const AddKomoditasTanamanScreen(
      {super.key, this.onKomoditasTanamanAdded, this.isEdit = false});

  @override
  _AddKomoditasTanamanScreenState createState() =>
      _AddKomoditasTanamanScreenState();
}

class _AddKomoditasTanamanScreenState extends State<AddKomoditasTanamanScreen> {
  final SatuanService _satuanService = SatuanService();
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ImageService _imageService = ImageService();
  final KomoditasService _komoditasService = KomoditasService();

  List<Map<String, dynamic>> _satuanList = [];
  List<Map<String, dynamic>> _jenisTanamanList = [];

  String? selectedLocation;
  String? selectedSatuan;

  bool isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  Future<void> _fetchData() async {
    try {
      final satuanResponse = await _satuanService.getSatuan();
      if (satuanResponse['status']) {
        setState(() {
          _satuanList = List<Map<String, dynamic>>.from(
              satuanResponse['data'].map((item) {
            return {
              'id': item['id'],
              'nama': '${item['nama']} - ${item['lambang']}',
            };
          }).toList());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error fetching satuan data: ${satuanResponse['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      final jenisTanamanResponse =
          await _jenisBudidayaService.getJenisBudidayaByTipe('tumbuhan');
      if (jenisTanamanResponse['status']) {
        setState(() {
          _jenisTanamanList = List<Map<String, dynamic>>.from(
              jenisTanamanResponse['data'].map((item) {
            return {
              'id': item['id'],
              'nama': item['nama'],
            };
          }).toList());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error fetching jenis tanaman data: ${jenisTanamanResponse['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  final TextEditingController _nameController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        final imageUrl = await _imageService.uploadImage(_image!);

        final data = {
          'nama': _nameController.text,
          'satuanId': selectedSatuan,
          'jenisBudidayaId': selectedLocation,
          'gambar': imageUrl['data'],
          'jumlah': 0,
        };

        final response = await _komoditasService.createKomoditas(data);

        if (response['status']) {
          if (widget.onKomoditasTanamanAdded != null) {
            widget.onKomoditasTanamanAdded!();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Komoditas Berhasil ditambahkan'),
            ),
          );
          Navigator.pop(context);
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
            content: Text('Error adding komoditas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
              title: 'Manajemen Komoditas',
              greeting: 'Tambah Komoditas'),
        ),
      ),
      body: SafeArea(
        child: ListView(children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                      label: "Nama komoditas",
                      hint: "Contoh: Buah Melon",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama komoditas tidak boleh kosong';
                        }
                        return null;
                      }),
                  DropdownFieldWidget(
                    label: "Pilih jenis tanaman",
                    hint: "Pilih jenis tanaman",
                    items: _jenisTanamanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: _jenisTanamanList.firstWhere(
                        (item) => item['id'] == selectedLocation,
                        orElse: () => {'nama': ''})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = _jenisTanamanList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': null},
                        )['id'];
                      });
                    },
                  ),
                  DropdownFieldWidget(
                    label: "Satuan",
                    hint: "Pilih satuan",
                    items: _satuanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: _satuanList.firstWhere(
                        (item) => item['id'] == selectedSatuan,
                        orElse: () => {'nama': ''})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedSatuan = _satuanList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': null},
                        )['id'];
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah gambar komoditas",
                    image: _image,
                    onPickImage: _pickImage,
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: _submitForm,
                    backgroundColor: green1,
                    textStyle: semibold16,
                    textColor: white,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
