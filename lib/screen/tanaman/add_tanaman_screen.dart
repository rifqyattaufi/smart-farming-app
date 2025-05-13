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

class AddTanamanScreen extends StatefulWidget {
  final VoidCallback? onTanamanAdded;
  final bool isEdit;
  final String? idTanaman;

  const AddTanamanScreen({
    super.key,
    this.onTanamanAdded,
    this.isEdit = false,
    this.idTanaman,
  });

  @override
  _AddTanamanScreenState createState() => _AddTanamanScreenState();
}

class _AddTanamanScreenState extends State<AddTanamanScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ImageService _imageService = ImageService();

  final _formKey = GlobalKey<FormState>();
  String? selectedLocation;
  String statusBudidaya = 'Aktif';

  File? _imageTanaman;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImageTanaman(BuildContext context) async {
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
                    _imageTanaman = File(pickedFile.path);
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
                    _imageTanaman = File(pickedFile.path);
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

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_imageTanaman == null && widget.isEdit == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar tanaman tidak boleh kosong')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_imageTanaman != null) {
        _imageUrl = await _imageService.uploadImage(_imageTanaman!);
      }

      final data = {
        'nama': _nameController.text,
        'latin': _latinController.text,
        'detail': _descriptionController.text,
        'tipe': 'tumbuhan',
        'gambar': _imageUrl?['data'],
        'status': statusBudidaya == 'Aktif' ? 1 : 0,
      };

      Map<String, dynamic> response;

      if (widget.isEdit) {
        data['id'] = widget.idTanaman;
        response = await _jenisBudidayaService.updateJenisBudidaya(data);
      } else {
        response = await _jenisBudidayaService.createJenisBudidaya(data);
      }

      if (response['status'] == true) {
        if (widget.onTanamanAdded != null) {
          widget.onTanamanAdded!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isEdit
                  ? 'Berhasil memperbarui jenis tanaman'
                  : 'Berhasil menambahkan jenis tanaman')),
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
        SnackBar(content: Text('Terjadi kesalahan saat menambahkan: $e')),
      );
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latinController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic>? _imageUrl;

  Future<void> _fetchData() async {
    final response =
        await _jenisBudidayaService.getJenisBudidayaById(widget.idTanaman!);

    if (response['status'] == true) {
      final data = response['data']['jenisBudidaya'];

      setState(() {
        _nameController.text = data['nama'];
        _latinController.text = data['latin'];
        _descriptionController.text = data['detail'];
        statusBudidaya = data['status'] ? 'Aktif' : 'Tidak aktif';
        _imageUrl = {'data': data['gambar']};
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
              title: 'Manajemen Jenis Tanaman',
              greeting: widget.isEdit
                  ? 'Edit Jenis Tanaman'
                  : 'Tambah Jenis Tanaman'),
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
                    label: "Nama jenis tanaman",
                    hint: "Contoh: Melon",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama jenis tanaman tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      label: "Nama latin",
                      hint: "Contoh: Melo melo",
                      controller: _latinController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama latin tidak boleh kosong';
                        }
                        return null;
                      }),
                  RadioField(
                    label: 'Status budidaya',
                    selectedValue: statusBudidaya,
                    options: const ['Aktif', 'Tidak aktif'],
                    onChanged: (value) {
                      setState(() {
                        statusBudidaya = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah gambar tanaman",
                    image: _imageTanaman,
                    onPickImage: _pickImageTanaman,
                  ),
                  InputFieldWidget(
                      label: "Deskripsi tanaman",
                      hint: "Keterangan",
                      controller: _descriptionController,
                      maxLines: 10),
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
