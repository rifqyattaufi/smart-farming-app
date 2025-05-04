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

class AddKomoditasTernakScreen extends StatefulWidget {
  final bool isEdit;
  final VoidCallback? onKomoditasAdded;

  const AddKomoditasTernakScreen(
      {super.key, this.onKomoditasAdded, this.isEdit = false});

  @override
  _AddKomoditasTernakScreenState createState() =>
      _AddKomoditasTernakScreenState();
}

class _AddKomoditasTernakScreenState extends State<AddKomoditasTernakScreen> {
  final SatuanService _satuanService = SatuanService();
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ImageService _imageService = ImageService();
  final KomoditasService _komoditasService = KomoditasService();

  List<Map<String, dynamic>> satuanList = [];
  List<Map<String, dynamic>> jenisHewanList = [];
  String? selectedTernak;
  String? selectedSatuan;

  File? _image;
  final picker = ImagePicker();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _fetchData() async {
    try {
      final satuanResponse = await _satuanService.getSatuan();
      if (satuanResponse['status']) {
        setState(() {
          satuanList = List<Map<String, dynamic>>.from(
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

      final jenisBudidayaResponse =
          await _jenisBudidayaService.getJenisBudidayaByTipe('hewan');
      if (jenisBudidayaResponse['status']) {
        setState(() {
          jenisHewanList = List<Map<String, dynamic>>.from(
              jenisBudidayaResponse['data'].map((item) {
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
                'Error fetching jenis budidaya data: ${jenisBudidayaResponse['message']}'),
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
            content: Text('Silakan pilih gambar komoditas'),
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
          'jenisBudidayaId': selectedTernak,
          'gambar': imageUrl['data'],
          'jumlah': 0,
        };

        final response = await _komoditasService.createKomoditas(data);

        if (response['status']) {
          if (widget.onKomoditasAdded != null) {
            widget.onKomoditasAdded!();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Komoditas berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding komoditas: ${response['message']}'),
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
                      hint: "Contoh: Telur Ayam",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama komoditas tidak boleh kosong';
                        }
                        return null;
                      }),
                  DropdownFieldWidget(
                    label: "Pilih jenis ternak",
                    hint: "Pilih jenis ternak",
                    items: jenisHewanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: jenisHewanList.firstWhere(
                        (item) => item['id'] == selectedTernak,
                        orElse: () => {'nama': null})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedTernak = jenisHewanList.firstWhere(
                            (item) => item['nama'] == value,
                            orElse: () => {'id': null})['id'];
                      });
                    },
                  ),
                  DropdownFieldWidget(
                    label: "Satuan",
                    hint: "Pilih satuan",
                    items: satuanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: satuanList.firstWhere(
                        (item) => item['id'] == selectedSatuan,
                        orElse: () => {'nama': null})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedSatuan = satuanList.firstWhere(
                            (item) => item['nama'] == value,
                            orElse: () => {'id': null})['id'];
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
