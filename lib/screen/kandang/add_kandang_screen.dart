import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddKandangScreen extends StatefulWidget {
  final VoidCallback? onKandangAdded;
  final bool isEdit;
  final String? idKandang;

  const AddKandangScreen(
      {super.key, this.onKandangAdded, this.isEdit = false, this.idKandang});

  @override
  _AddKandangScreenState createState() => _AddKandangScreenState();
}

class _AddKandangScreenState extends State<AddKandangScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final ImageService _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();
  String? selectedJenisHewan;
  String statusKandang = 'Aktif';
  String jenisPencatatan = 'Individu';
  List<Map<String, dynamic>> jenisHewanList = [];

  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

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

  Future<void> _getJenisHewan() async {
    final response =
        await _jenisBudidayaService.getJenisBudidayaByTipe('hewan');
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        jenisHewanList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchKandang() async {
    final response =
        await _unitBudidayaService.getUnitBudidayaById(widget.idKandang ?? '');

    if (response['status'] == true) {
      final data = response['data']['unitBudidaya'];
      setState(() {
        _nameController.text = data['nama'] ?? '';
        _locationController.text = data['lokasi'] ?? '';
        _sizeController.text = data['luas']?.toString() ?? '';
        _jumlahController.text = data['jumlah']?.toString() ?? '';
        _descriptionController.text = data['deskripsi'] ?? '';
        statusKandang = data['status'] == true ? 'Aktif' : 'Tidak aktif';
        jenisPencatatan = data['tipe'] == 'individu' ? 'Individu' : 'Kolektif';
        selectedJenisHewan = data['JenisBudidayaId'].toString();
        imageUrl = {
          'data': data['gambar'],
        };
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic> imageUrl = {};

  @override
  void initState() {
    super.initState();
    _getJenisHewan();
    if (widget.isEdit) {
      _fetchKandang();
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_image == null && !widget.isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gambar kandang tidak boleh kosong'),
              backgroundColor: Colors.red),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_image != null) {
        imageUrl = await _imageService.uploadImage(_image!);
      }

      final data = {
        'jenisBudidayaId': selectedJenisHewan,
        'nama': _nameController.text,
        'lokasi': _locationController.text,
        'tipe': jenisPencatatan,
        'luas': _sizeController.text,
        'jumlah': _jumlahController.text,
        'status': statusKandang == 'Aktif',
        'deskripsi': _descriptionController.text,
        'gambar': imageUrl['data'],
      };

      Map<String, dynamic>? response;

      if (widget.isEdit) {
        data['id'] = widget.idKandang;
        response = await _unitBudidayaService.updateUnitBudidaya(data);
      } else {
        response = await _unitBudidayaService.createUnitBudidaya(data);
      }

      if (response['status'] == true) {
        if (widget.onKandangAdded != null) {
          widget.onKandangAdded!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Kandang berhasil diperbarui'
                  : 'Kandang berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
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
          title: Header(
              headerType: HeaderType.back,
              title: 'Manajemen Kandang',
              greeting: widget.isEdit ? 'Edit Kandang' : 'Tambah Kandang'),
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
                    label: "Nama kandang",
                    hint: "Contoh: kandang A",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama kandang tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      label: "Lokasi kandang",
                      hint: "Contoh: Rooftop",
                      controller: _locationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi kandang tidak boleh kosong';
                        }
                        return null;
                      }),
                  InputFieldWidget(
                      label: "Luas kandang",
                      hint: "Contoh: 30m²",
                      controller: _sizeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Luas kandang tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Luas kandang harus berupa angka';
                        }
                        return null;
                      }),
                  DropdownFieldWidget(
                    label: "Pilih jenis hewan yang diternak",
                    hint: "Pilih jenis hewan ternak",
                    items: jenisHewanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: jenisHewanList.firstWhere(
                        (item) => item['id'] == selectedJenisHewan,
                        orElse: () => {'nama': null})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedJenisHewan = jenisHewanList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': null},
                        )['id'];
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis hewan tidak boleh kosong';
                      }
                      return null;
                    },
                    isEdit: widget.isEdit,
                  ),
                  InputFieldWidget(
                      label: "Jumlah hewan ternak",
                      hint: "Contoh: 20 (satuan ekor)",
                      controller: _jumlahController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah hewan tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Jumlah hewan harus berupa angka';
                        }
                        return null;
                      }),
                  RadioField(
                    label: 'Status kandang',
                    selectedValue: statusKandang,
                    options: const ['Aktif', 'Tidak aktif'],
                    onChanged: (value) {
                      setState(() {
                        statusKandang = value;
                      });
                    },
                  ),
                  RadioField(
                    label: 'Jenis Pencatatan',
                    selectedValue: jenisPencatatan,
                    options: const ['Individu', 'Kolektif'],
                    onChanged: (value) {
                      setState(() {
                        jenisPencatatan = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah gambar kandang",
                    image: _image,
                    onPickImage: _pickImage,
                  ),
                  InputFieldWidget(
                      label: "Deskripsi kandang",
                      hint: "Keterangan",
                      controller: _descriptionController,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi kandang tidak boleh kosong';
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
        ]),
      ),
    );
  }
}
