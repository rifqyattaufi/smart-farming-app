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

class AddKebunScreen extends StatefulWidget {
  final VoidCallback? onKebunAdded;
  final bool isEdit;
  final String? idKebun;

  const AddKebunScreen(
      {super.key, this.onKebunAdded, this.isEdit = false, this.idKebun});

  @override
  _AddKebunScreenState createState() => _AddKebunScreenState();
}

class _AddKebunScreenState extends State<AddKebunScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final ImageService _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();
  String? selectedJenisTanaman;
  String statusKebun = 'Aktif';
  List<Map<String, dynamic>> jenisTanamanList = [];

  File? _image;
  final picker = ImagePicker();
  bool _isPickingImage = false;
  bool _isLoading = false;

  Future<void> _pickImage(BuildContext context) async {
    if (_isPickingImage) return;

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
                await _handleImagePick(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _handleImagePick(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(
      BuildContext context, ImageSource source) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<void> _getJenisTanaman() async {
    final response =
        await _jenisBudidayaService.getJenisBudidayaByTipe('tumbuhan');
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        jenisTanamanList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic> imageUrl = {};

  Future<void> _fetchKebun() async {
    final response =
        await _unitBudidayaService.getUnitBudidayaById(widget.idKebun!);

    if (response['status'] == true) {
      final data = response['data']['unitBudidaya'];
      setState(() {
        _nameController.text = data['nama'];
        _locationController.text = data['lokasi'];
        _sizeController.text = data['luas'].toString();
        _jumlahController.text = data['jumlah'].toString();
        statusKebun = data['status'] ? 'Aktif' : 'Tidak Aktif';
        _descriptionController.text = data['deskripsi'];
        selectedJenisTanaman = data['JenisBudidayaId'].toString();
        imageUrl = {'data': data['gambar']};
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getJenisTanaman();
    if (widget.isEdit) {
      _fetchKebun();
    }
  }

  Future<void> _submitKebun() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_image == null && !widget.isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap unggah gambar kebun')),
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
        'jenisBudidayaId': selectedJenisTanaman,
        'nama': _nameController.text,
        'lokasi': _locationController.text,
        'tipe': 'individu',
        'luas': _sizeController.text,
        'jumlah': _jumlahController.text,
        'status': statusKebun == 'Aktif',
        'deskripsi': _descriptionController.text,
        'gambar': imageUrl['data'],
      };

      Map<String, dynamic> response;

      if (widget.isEdit) {
        data['id'] = widget.idKebun;
        response = await _unitBudidayaService.updateUnitBudidaya(data);
      } else {
        response = await _unitBudidayaService.createUnitBudidaya(data);
      }

      if (response['status'] == true) {
        if (widget.onKebunAdded != null) {
          widget.onKebunAdded!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Kebun berhasil diperbarui'
                  : 'Kebun berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
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
              title: 'Manajemen Kebun',
              greeting: widget.isEdit ? 'Edit Kebun' : 'Tambah Kebun'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                    label: "Nama kebun",
                    hint: "Contoh: Kebun A",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Kebun tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      label: "Lokasi kebun",
                      hint: "Contoh: Rooftop",
                      controller: _locationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi Kebun tidak boleh kosong';
                        }
                        return null;
                      }),
                  InputFieldWidget(
                    label: "Luas kebun",
                    hint: "Contoh: 30 m²",
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Luas Kebun tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Luas Kebun harus berupa angka';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Luas Kebun harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  DropdownFieldWidget(
                    label: "Pilih jenis tanaman yang ditanam",
                    hint: "Pilih jenis tanaman",
                    items: jenisTanamanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: jenisTanamanList.firstWhere(
                      (item) => item['id'] == selectedJenisTanaman,
                      orElse: () => {'nama': null},
                    )['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedJenisTanaman = jenisTanamanList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': null},
                        )['id']; // Simpan id dari item yang dipilih
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis tanaman tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                    label: "Jumlah tanaman",
                    hint: "Contoh: 20 (satuan tanaman)",
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tanaman tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Jumlah tanaman harus berupa angka';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Jumlah tanaman harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  RadioField(
                    label: 'Status kebun',
                    selectedValue: statusKebun,
                    options: const ['Aktif', 'Tidak aktif'],
                    onChanged: (value) {
                      setState(() {
                        statusKebun = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah gambar kebun",
                    image: _image,
                    imageUrl: imageUrl['data'],
                    onPickImage: _pickImage,
                  ),
                  InputFieldWidget(
                    label: "Deskripsi kebun",
                    hint: "Keterangan",
                    controller: _descriptionController,
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi kebun tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    onPressed: _submitKebun,
                    backgroundColor: green1,
                    textStyle: semibold16,
                    textColor: white,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
