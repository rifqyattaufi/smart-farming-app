import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddInventarisScreen extends StatefulWidget {
  final VoidCallback? onInventarisAdded;
  final bool isEdit;
  final String? idInventaris;

  const AddInventarisScreen({
    super.key,
    this.onInventarisAdded,
    this.isEdit = false,
    this.idInventaris,
  });

  @override
  _AddInventarisScreenState createState() => _AddInventarisScreenState();
}

class _AddInventarisScreenState extends State<AddInventarisScreen> {
  final InventarisService _inventarisService = InventarisService();
  final KategoriInvService _kategoriInvService = KategoriInvService();
  final SatuanService _satuanService = SatuanService();
  final ImageService _imageService = ImageService();
  final _formKey = GlobalKey<FormState>();

  String? _mysqlDateTime;
  String? selectedLocation;
  String? selectedSatuan;
  String ketersediaanInv = 'tersedia';
  String kondisiInv = 'baik';

  List<Map<String, dynamic>> kategoriList = [];
  List<Map<String, dynamic>> satuanList = [];

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

  Future<void> _getKategoriInventaris() async {
    final response = await _kategoriInvService.getKategoriInventaris();
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        kategoriList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _getSatuan() async {
    final response = await _satuanService.getSatuan();
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        satuanList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.red),
      );
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _minimController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic> imageUrl = {};

  @override
  void initState() {
    super.initState();
    _getKategoriInventaris();
    _getSatuan();

    if (widget.isEdit) {
      _fetchInventarisData();
    }
  }

  Future<void> _fetchInventarisData() async {
    try {
      final response =
          await _inventarisService.getInventarisById(widget.idInventaris ?? '');
      if (response['status'] == true) {
        final data = response['data']['data'];
        setState(() {
          _nameController.text = data['nama'] ?? '';
          selectedLocation = data['kategoriInventarisId'];
          _sizeController.text = data['jumlah']?.toString() ?? '';
          _minimController.text = data['stokMinim']?.toString() ?? '';
          selectedSatuan = data['SatuanId'];
          kondisiInv = data['kondisi'] ?? 'baik';
          ketersediaanInv = data['ketersediaan'] ?? 'tersedia';
          _descriptionController.text = data['detail'] ?? '';
          imageUrl = {'data': data['gambar']};

          // Handle date formatting
          final DateTime expiryDate =
              DateTime.parse(data['tanggalKadaluwarsa']);
          _dateController.text =
              DateFormat('EEEE, dd MMMM yyyy HH:mm').format(expiryDate);
          _mysqlDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(expiryDate);
        });
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Failed to fetch inventaris data: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _minimController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_image == null && !widget.isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar inventaris tidak boleh kosong')),
        );
        return;
      }

      if (_mysqlDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tanggal kadaluwarsa tidak boleh kosong')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_image != null) {
        imageUrl = await _imageService.uploadImage(_image!);
      }

      final formattedKadaluwarsaDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime.parse(_mysqlDateTime!).add(const Duration(hours: 7)),
      );

      final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final formattedUpdatedAtDate = DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.now().add(const Duration(hours: 7)));

      final data = {
        'nama': _nameController.text,
        'kategoriInventarisId': selectedLocation,
        'jumlah': _sizeController.text,
        'satuanId': selectedSatuan,
        'stokMinim': _minimController.text,
        'tanggalKadaluwarsa': formattedKadaluwarsaDate,
        if (widget.isEdit) 'updatedAt': formattedUpdatedAtDate,
        'kondisi': kondisiInv,
        'ketersediaan': ketersediaanInv,
        'gambar': imageUrl['data'],
        'detail': _descriptionController.text,
        if (!widget.isEdit) 'createdAt': formattedDate,
      };

      Map<String, dynamic>? response;

      if (widget.isEdit) {
        data['id'] = widget.idInventaris;
        response = await _inventarisService.updateInventaris(data);
      } else {
        response = await _inventarisService.createInventaris(data);
      }

      if (response['status'] == true) {
        if (widget.onInventarisAdded != null) {
          widget.onInventarisAdded!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEdit
                ? 'Inventaris berhasil diperbarui'
                : 'Inventaris berhasil ditambahkan'),
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
        SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red),
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
              title: 'Manajemen Inventaris',
              greeting:
                  widget.isEdit ? 'Edit Inventaris' : 'Tambah Inventaris'),
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
                    label: "Nama inventaris",
                    hint: "Contoh: Bibit A",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama inventaris tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  DropdownFieldWidget(
                    label: "Kategori inventaris",
                    hint: "Pilih kategori inventaris",
                    items: kategoriList
                        .map((item) => item['nama'].toString())
                        .toList(),
                    selectedValue: kategoriList.firstWhere(
                        (item) => item['id'] == selectedLocation,
                        orElse: () => {'nama': ''})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = kategoriList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': ''},
                        )['id'];
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kategori inventaris tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      label: "Jumlah stok",
                      hint: "Contoh: 20",
                      controller: _sizeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jumlah stok tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Jumlah stok harus berupa angka';
                        }
                        return null;
                      }),
                  InputFieldWidget(
                      label: "Stok minim (untuk perhitungan stok rendah)",
                      hint: "Contoh: 5",
                      controller: _minimController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok minimal tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Stok minimal harus berupa angka';
                        }
                        return null;
                      }),
                  DropdownFieldWidget(
                    label: "Satuan",
                    hint: "Pilih satuan",
                    items: satuanList
                        .map((item) => item['nama'].toString())
                        .toList(),
                    selectedValue: satuanList.firstWhere(
                        (item) => item['id'] == selectedSatuan,
                        orElse: () => {'nama': null})['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedSatuan = satuanList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': null},
                        )['id'];
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Satuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                    label: "Tanggal kadaluwarsa",
                    hint: "Contoh:  Senin, 17 Februari 2025",
                    controller: _dateController,
                    suffixIcon: const Icon(Icons.calendar_today),
                    onSuffixIconTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          final DateTime pickedDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          final String formattedDisplayDateTime =
                              DateFormat('EEEE, dd MMMM yyyy HH:mm')
                                  .format(pickedDateTime);

                          final String formattedMySQLDateTime =
                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(pickedDateTime);

                          _dateController.text = formattedDisplayDateTime;
                          _mysqlDateTime = formattedMySQLDateTime;
                        }
                      }
                    },
                  ),
                  RadioField(
                    label: 'Kondisi inventaris',
                    selectedValue: kondisiInv,
                    options: const ['baik', 'rusak'],
                    onChanged: (value) {
                      setState(() {
                        kondisiInv = value;
                      });
                    },
                  ),
                  RadioField(
                    label: 'Ketersediaan',
                    selectedValue: ketersediaanInv,
                    options: const [
                      'tersedia',
                      'tidak tersedia',
                      'kadaluwarsa'
                    ],
                    onChanged: (value) {
                      setState(() {
                        ketersediaanInv = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    label: "Unggah gambar inventaris",
                    image: _image,
                    imageUrl: imageUrl['data'],
                    onPickImage: _pickImage,
                  ),
                  InputFieldWidget(
                      label: "Deskripsi inventaris",
                      hint: "Keterangan",
                      controller: _descriptionController,
                      maxLines: 10,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi inventaris tidak boleh kosong';
                        }
                        return null;
                      }),
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
        ]),
      ),
    );
  }
}
