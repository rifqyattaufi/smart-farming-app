import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddTernakScreen extends StatefulWidget {
  final VoidCallback? onTernakAdded;
  final bool isEdit;
  final String? idTernak;

  const AddTernakScreen(
      {super.key, this.onTernakAdded, this.isEdit = false, this.idTernak});

  @override
  _AddTernakScreenState createState() => _AddTernakScreenState();
}

class _AddTernakScreenState extends State<AddTernakScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();

  final ImageService _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();
  String? selectedLocation;
  String statusTernak = 'Aktif';

  File? _imageTernak;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImageTernak(BuildContext context) async {
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
                    _imageTernak = File(pickedFile.path);
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
                    _imageTernak = File(pickedFile.path);
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
  final TextEditingController _latinController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic> _imageUrl = {};

  Future<void> _fetchData() async {
    final response =
        await _jenisBudidayaService.getJenisBudidayaById(widget.idTernak!);

    if (response['status'] == true) {
      final data = response['data']['jenisBudidaya'];

      setState(() {
        _nameController.text = data['nama'];
        _latinController.text = data['latin'];
        statusTernak = data['status'] ? 'Aktif' : 'Tidak Aktif';
        _descriptionController.text = data['detail'];
        _imageUrl = {
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

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_imageTernak == null && !widget.isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar hewan ternak tidak boleh kosong'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_imageTernak != null) {
        _imageUrl = await _imageService.uploadImage(_imageTernak!);
      }

      final data = {
        "nama": _nameController.text,
        "latin": _latinController.text,
        "tipe": "hewan",
        "status": statusTernak == 'Aktif',
        "detail": _descriptionController.text,
        "gambar": _imageUrl['data'],
      };

      Map<String, dynamic> response;

      if (widget.isEdit) {
        data['id'] = widget.idTernak;
        response = await _jenisBudidayaService.updateJenisBudidaya(data);
      } else {
        response = await _jenisBudidayaService.createJenisBudidaya(data);
      }

      if (response['status'] == true) {
        if (widget.onTernakAdded != null) {
          widget.onTernakAdded!();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdit
                ? 'Berhasil memperbarui jenis hewan ternak'
                : 'Berhasil menambahkan jenis hewan ternak'),
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
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _fetchData();
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
              title: 'Manajemen Jenis Hewan',
              greeting: widget.isEdit
                  ? 'Edit Jenis Hewan'
                  : 'Tambah Jenis Hewan'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                    label: "Nama hewan ternak",
                    hint: "Contoh: Ayam",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama hewan ternak tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      label: "Nama latin",
                      hint: "Contoh: Gallus gallus domesticus",
                      controller: _latinController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama latin tidak boleh kosong';
                        }
                        return null;
                      }),
                  RadioField(
                    label: 'Status ternak',
                    selectedValue: statusTernak,
                    options: const ['Aktif', 'Tidak Aktif'],
                    onChanged: (value) {
                      setState(() {
                        statusTernak = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah gambar hewan ternak",
                    image: _imageTernak,
                    onPickImage: _pickImageTernak,
                  ),
                  InputFieldWidget(
                      label: "Deskripsi hewan ternak",
                      hint: "Keterangan",
                      controller: _descriptionController,
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
