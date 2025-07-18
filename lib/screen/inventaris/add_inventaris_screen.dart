import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

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
  AddInventarisScreenState createState() => AddInventarisScreenState();
}

class AddInventarisScreenState extends State<AddInventarisScreen> {
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
  DateTime? _selectedDateTimeKadaluwarsa;

  List<Map<String, dynamic>> kategoriList = [];
  List<Map<String, dynamic>> satuanList = [];

  Map<String, dynamic> imageUrl = {};
  File? _image;
  String? _existingImageUrl;
  final picker = ImagePicker();
  bool _isLoading = false;

  // Variables for tracking current stock values
  double _currentJumlahStok = 0.0;
  double _currentStokMinim = 0.0;

  // Helper methods for increment/decrement functionality
  void _incrementJumlahStok() {
    setState(() {
      _currentJumlahStok += 1.0;
      _sizeController.text = _currentJumlahStok.toStringAsFixed(1);
    });
  }

  void _decrementJumlahStok() {
    setState(() {
      if (_currentJumlahStok > 0) {
        _currentJumlahStok -= 1.0;
        _sizeController.text = _currentJumlahStok.toStringAsFixed(1);
      }
    });
  }

  void _incrementStokMinim() {
    setState(() {
      _currentStokMinim += 1.0;
      _minimController.text = _currentStokMinim.toStringAsFixed(1);
    });
  }

  void _decrementStokMinim() {
    setState(() {
      if (_currentStokMinim > 0) {
        _currentStokMinim -= 1.0;
        _minimController.text = _currentStokMinim.toStringAsFixed(1);
      }
    });
  }

  void _updateJumlahStokFromText() {
    final value = double.tryParse(_sizeController.text);
    if (value != null && value >= 0) {
      setState(() {
        _currentJumlahStok = value;
      });
    }
  }

  void _updateStokMinimFromText() {
    final value = double.tryParse(_minimController.text);
    if (value != null && value >= 0) {
      setState(() {
        _currentStokMinim = value;
      });
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
              key: const Key('open_camera'),
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
              key: const Key('open_gallery'),
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
      showAppToast(context, response['message'] ?? 'Gagal memuat data');
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
      showAppToast(context, response['message'] ?? 'Gagal memuat data');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize default values for new inventory
    if (!widget.isEdit) {
      _sizeController.text = _currentJumlahStok.toStringAsFixed(1);
      _minimController.text = _currentStokMinim.toStringAsFixed(1);
    }

    _loadDropdownData();

    if (widget.isEdit) {
      if (widget.inventarisData != null) {
        _prefillFormFromData(widget.inventarisData!);
      } else if (widget.idInventaris != null) {
        _fetchInventarisDataForEdit(widget.idInventaris!);
      } else {
        showAppToast(context, 'ID inventaris tidak ditemukan');
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

      // Initialize current stock values
      _currentJumlahStok = (data['jumlah'] as num?)?.toDouble() ?? 0.0;
      _sizeController.text = _currentJumlahStok.toStringAsFixed(1);

      _currentStokMinim = (data['stokMinim'] as num?)?.toDouble() ?? 0.0;
      _minimController.text = _currentStokMinim.toStringAsFixed(1);

      selectedSatuan = data['Satuan']?['id']?.toString() ??
          data['satuan']?['id']?.toString() ??
          data['SatuanId']?.toString();

      _descriptionController.text = data['detail'] ?? '';
      _existingImageUrl = data['gambar'];

      if (data['tanggalKadaluwarsa'] != null) {
        try {
          _selectedDateTimeKadaluwarsa =
              DateTime.parse(data['tanggalKadaluwarsa']);
          _dateController.text = DateFormat('EEEE, dd MMMM yyyy HH:mm')
              .format(_selectedDateTimeKadaluwarsa!);
        } catch (e) {
          showAppToast(context,
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
        showAppToast(context, response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() => _isLoading = false);
    }
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
      showAppToast(context, 'Gambar inventaris tidak boleh kosong');
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
          showAppToast(
              context, uploadResponse['message'] ?? 'Gagal mengunggah gambar');
          setState(() => _isLoading = false);
          return;
        }
      }

      final String? formattedKadaluwarsaForBackend =
          _selectedDateTimeKadaluwarsa?.toIso8601String();

      final inventarisPayload = {
        'nama': _nameController.text,
        'kategoriInventarisId': selectedLocation,
        'jumlah': double.tryParse(_sizeController.text) ?? 0.0,
        'SatuanId': selectedSatuan,
        'stokMinim': double.tryParse(_minimController.text) ?? 0.0,
        'tanggalKadaluwarsa': formattedKadaluwarsaForBackend,
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
        showAppToast(
            context,
            widget.isEdit
                ? 'Berhasil memperbarui inventaris'
                : 'Berhasil menambahkan inventaris',
            isError: false);

        Navigator.pop(context);
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      if (!mounted) return;
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
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

  // Helper method to check if stock editing should be disabled
  bool get _isStokEditingDisabled {
    return widget.isEdit && _currentJumlahStok > 0;
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
                          key: const Key('nama_inventaris_input'),
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
                          key: const Key('kategori_inventaris_dropdown'),
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
                        if (_isStokEditingDisabled) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.blue.shade600, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Informasi Jumlah Stok",
                                      style: semibold12.copyWith(
                                          color: Colors.blue.shade700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Jumlah stok tidak dapat diubah karena stok saat ini masih tersedia, habiskan stok terlebih dahulu untuk menambahkan stok baru.",
                                  style: regular10.copyWith(
                                      color: Colors.blue.shade600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        InputFieldWidget(
                            key: const Key('jumlah_stok_input'),
                            label: "Jumlah stok",
                            hint: "Contoh: 20.5",
                            controller: _sizeController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            isDisabled: _isStokEditingDisabled,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: const Key('decrease_stok_button'),
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: _isStokEditingDisabled
                                          ? Colors.grey
                                          : green1),
                                  onPressed: _isStokEditingDisabled
                                      ? null
                                      : _decrementJumlahStok,
                                ),
                                IconButton(
                                  key: const Key('increase_stok_button'),
                                  icon: Icon(Icons.add_circle_outline,
                                      color: _isStokEditingDisabled
                                          ? Colors.grey
                                          : green1),
                                  onPressed: _isStokEditingDisabled
                                      ? null
                                      : _incrementJumlahStok,
                                ),
                              ],
                            ),
                            onChanged: _isStokEditingDisabled
                                ? null
                                : (value) => _updateJumlahStokFromText(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah stok tidak boleh kosong';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Jumlah stok harus berupa angka';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Jumlah stok harus lebih dari 0';
                              }
                              return null;
                            }),
                        InputFieldWidget(
                            key: const Key('stok_minim_input'),
                            label: "Stok minim (untuk perhitungan stok rendah)",
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            hint: "Contoh: 5.0",
                            controller: _minimController,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  key: const Key('decrease_minim_button'),
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: green1),
                                  onPressed: _decrementStokMinim,
                                ),
                                IconButton(
                                  key: const Key('increase_minim_button'),
                                  icon: Icon(Icons.add_circle_outline,
                                      color: green1),
                                  onPressed: _incrementStokMinim,
                                ),
                              ],
                            ),
                            onChanged: (value) => _updateStokMinimFromText(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Stok minimal tidak boleh kosong';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Stok minimal harus berupa angka';
                              }
                              if (double.parse(value) < 0) {
                                return 'Stok minimal tidak boleh negatif';
                              }
                              return null;
                            }),
                        DropdownFieldWidget(
                          key: const Key('satuan_inventaris_dropdown'),
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
                          key: const Key('tanggal_kadaluwarsa_input'),
                          label: "Tanggal kadaluwarsa (opsional)",
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
                        ),
                        ImagePickerWidget(
                          key: const Key('gambar_inventaris_picker'),
                          label: "Unggah gambar inventaris",
                          image: _image,
                          imageUrl: _existingImageUrl,
                          onPickImage: _pickImage,
                        ),
                        InputFieldWidget(
                            key: const Key('deskripsi_inventaris_input'),
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
              buttonText:
                  widget.isEdit ? 'Simpan Perubahan' : 'Tambah Inventaris',
              onPressed: _submitForm,
              backgroundColor: green1,
              textStyle: semibold16.copyWith(color: white),
              isLoading: _isLoading,
              key: const Key('submit_inventaris_button')),
        ),
      ),
    );
  }
}
