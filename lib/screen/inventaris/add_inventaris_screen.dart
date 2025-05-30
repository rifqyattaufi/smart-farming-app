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
  final Map<String, dynamic>? inventarisData;

  const AddInventarisScreen({
    super.key,
    this.onInventarisAdded,
    this.isEdit = false,
    this.idInventaris,
    this.inventarisData,
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _minimController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedLocation;
  String? selectedSatuan;
  String ketersediaanInv = 'tersedia';
  String kondisiInv = 'baik';
  DateTime? _selectedDateTimeKadaluwarsa;

  List<Map<String, dynamic>> kategoriList = [];
  List<Map<String, dynamic>> satuanList = [];

  Map<String, dynamic> imageUrl = {};
  File? _image;
  String? _existingImageUrl;
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
    if (!mounted) return;
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
      _showError(response['message'] ?? "Gagal memuat kategori.");
    }
  }

  Future<void> _getSatuan() async {
    final response = await _satuanService.getSatuan();
    if (!mounted) return;
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
      _showError(response['message'] ?? "Gagal memuat satuan.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();

    if (widget.isEdit) {
      if (widget.inventarisData != null) {
        _prefillFormFromData(widget.inventarisData!);
      } else if (widget.idInventaris != null) {
        _fetchInventarisDataForEdit(widget.idInventaris!);
      } else {
        _showError("ID Inventaris tidak valid untuk mode edit.");
      }
    }
  }

  Future<void> _loadDropdownData() async {
    await Future.wait([
      _getKategoriInventaris(),
      _getSatuan(),
    ]);
  }

  void _prefillFormFromData(Map<String, dynamic> data) {
    setState(() {
      _nameController.text = data['nama'] ?? '';
      selectedLocation = data['kategoriInventaris']?['id']?.toString() ??
          data['KategoriInventarisId']?.toString();

      _sizeController.text = (data['jumlah'] ?? '').toString();
      _minimController.text = (data['stokMinim'] ?? '').toString();

      selectedSatuan = data['Satuan']?['id']?.toString() ??
          data['satuan']?['id']?.toString() ??
          data['SatuanId']?.toString();

      kondisiInv = data['kondisi'] ?? 'baik';
      ketersediaanInv = data['ketersediaan'] ?? 'tersedia';
      _descriptionController.text = data['detail'] ?? '';
      _existingImageUrl = data['gambar'];

      if (data['tanggalKadaluwarsa'] != null) {
        try {
          _selectedDateTimeKadaluwarsa =
              DateTime.parse(data['tanggalKadaluwarsa']);
          _dateController.text = DateFormat('EEEE, dd MMMM yyyy HH:mm')
              .format(_selectedDateTimeKadaluwarsa!);
        } catch (e) {
          _showError(
              "Format tanggal kadaluwarsa tidak valid: ${data['tanggalKadaluwarsa']}");
          _dateController.text = '';
          _selectedDateTimeKadaluwarsa = null;
        }
      }
    });
  }

  Future<void> _fetchInventarisDataForEdit(String inventarisId) async {
    if (inventarisId.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await _inventarisService.getInventarisById(inventarisId);
      if (response['status'] == true &&
          response['data']?['inventaris'] != null) {
        final dataInventaris = response['data']['inventaris'];
        _prefillFormFromData(dataInventaris);
      } else {
        _showError(response['message'] ??
            "Gagal memuat data inventaris untuk diedit.");
      }
    } catch (e) {
      _showError('Error memuat data inventaris: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    });
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
    if (!_formKey.currentState!.validate()) return;

    if (_image == null &&
        (!widget.isEdit ||
            (widget.isEdit &&
                (_existingImageUrl == null || _existingImageUrl!.isEmpty)))) {
      _showError('Gambar inventaris tidak boleh kosong');
      return;
    }

    if (_selectedDateTimeKadaluwarsa == null) {
      _showError('Tanggal kadaluwarsa tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    String? finalImageUrl = _existingImageUrl;

    try {
      if (_image != null) {
        final uploadResponse = await _imageService.uploadImage(_image!);
        if (uploadResponse['status'] == true &&
            uploadResponse['data'] != null) {
          finalImageUrl = uploadResponse['data'];
        } else {
          _showError(uploadResponse['message'] ?? "Gagal mengunggah gambar.");
          setState(() => _isLoading = false);
          return;
        }
      }

      final String formattedKadaluwarsaForBackend =
          _selectedDateTimeKadaluwarsa!.toIso8601String();

      final inventarisPayload = {
        'nama': _nameController.text,
        'kategoriInventarisId': selectedLocation,
        'jumlah': int.tryParse(_sizeController.text) ?? 0,
        'satuanId': selectedSatuan,
        'stokMinim': int.tryParse(_minimController.text) ?? 0,
        'tanggalKadaluwarsa': formattedKadaluwarsaForBackend,
        'kondisi': kondisiInv,
        'ketersediaan': ketersediaanInv,
        'gambar': finalImageUrl,
        'detail': _descriptionController.text,
      };

      Map<String, dynamic> response;

      if (widget.isEdit) {
        inventarisPayload['id'] = widget.idInventaris;
        response = await _inventarisService.updateInventaris(inventarisPayload);
      } else {
        response = await _inventarisService.createInventaris(inventarisPayload);
      }

      if (!mounted) return;

      if (response['status'] == true) {
        widget.onInventarisAdded?.call();
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
        _showError(response['message'] ?? "Operasi gagal.");
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _getSelectedNameFromId(String? id, List<Map<String, dynamic>> list) {
    if (id == null || list.isEmpty) return null;
    try {
      return list.firstWhere((item) => item['id'] == id)['nama'];
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? selectedKategoriName = kategoriList.isNotEmpty
        ? _getSelectedNameFromId(selectedLocation, kategoriList)
        : null;
    String? selectedSatuanName = satuanList.isNotEmpty
        ? _getSelectedNameFromId(selectedSatuan, satuanList)
        : null;

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
        child: _isLoading && widget.isEdit && widget.inventarisData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
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
                          selectedValue: selectedKategoriName,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              try {
                                selectedLocation = kategoriList.firstWhere(
                                    (item) => item['nama'] == value)['id'];
                              } catch (e) {
                                selectedLocation = null;
                              }
                            });
                          },
                          validator: (value) {
                            if (selectedLocation == null ||
                                selectedLocation!.isEmpty) {
                              return 'Kategori inventaris tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        InputFieldWidget(
                            label: "Jumlah stok",
                            hint: "Contoh: 20",
                            controller: _sizeController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah stok tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Jumlah stok harus berupa angka';
                              }
                              if (int.parse(value) <= 0) {
                                return 'Jumlah stok harus lebih dari 0';
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
                          selectedValue: selectedSatuanName,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              try {
                                selectedSatuan = satuanList.firstWhere(
                                    (item) => item['nama'] == value)['id'];
                              } catch (e) {
                                selectedSatuan = null;
                              }
                            });
                          },
                          validator: (value) {
                            if (selectedSatuan == null ||
                                selectedSatuan!.isEmpty) {
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
                          isDisabled: true,
                          onSuffixIconTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDateTimeKadaluwarsa ??
                                  DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null) {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime:
                                    _selectedDateTimeKadaluwarsa != null
                                        ? TimeOfDay.fromDateTime(
                                            _selectedDateTimeKadaluwarsa!)
                                        : TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedDateTimeKadaluwarsa = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                  _dateController.text = DateFormat(
                                          'EEEE, dd MMMM yyyy HH:mm')
                                      .format(_selectedDateTimeKadaluwarsa!);
                                });
                              }
                            }
                          },
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Tanggal & waktu kadaluwarsa tidak boleh kosong'
                              : null,
                        ),
                        RadioField(
                          label: 'Kondisi inventaris',
                          selectedValue: kondisiInv,
                          options: const ['baik', 'rusak'],
                          onChanged: (value) =>
                              setState(() => kondisiInv = value),
                        ),
                        RadioField(
                            label: 'Ketersediaan',
                            selectedValue: ketersediaanInv,
                            options: const [
                              'tersedia',
                              'tidak tersedia',
                              'kadaluwarsa'
                            ],
                            onChanged: (value) =>
                                setState(() => ketersediaanInv = value)),
                        ImagePickerWidget(
                          label: "Unggah gambar inventaris",
                          image: _image,
                          imageUrl: _existingImageUrl,
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
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          buttonText: widget.isEdit ? 'Simpan Perubahan' : 'Tambah Inventaris',
          onPressed: _submitForm,
          backgroundColor: green1,
          textStyle: semibold16,
          textColor: white,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
