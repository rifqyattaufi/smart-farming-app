import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
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
  AddTernakScreenState createState() => AddTernakScreenState();
}

class AddTernakScreenState extends State<AddTernakScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ImageService _imageService = ImageService();

  final _formKey = GlobalKey<FormState>();

  String statusTernak = 'Aktif';

  File? _imageTernak;
  final picker = ImagePicker();
  bool _isLoading = false;
  bool _isFetchingEditData = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latinController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _imageUrlFromApi;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.idTernak != null) {
      _fetchEditData();
    }
  }

  Future<void> _fetchEditData() async {
    if (!mounted) return;
    setState(() {
      _isFetchingEditData = true;
    });
    try {
      final response =
          await _jenisBudidayaService.getJenisBudidayaById(widget.idTernak!);

      if (mounted && response['status'] == true) {
        final dataJenisBudidaya = response['data']?['jenisBudidaya'];

        if (dataJenisBudidaya != null) {
          setState(() {
            _nameController.text = dataJenisBudidaya['nama'] ?? '';
            _latinController.text = dataJenisBudidaya['latin'] ?? '';
            _descriptionController.text = dataJenisBudidaya['detail'] ?? '';
            statusTernak = (dataJenisBudidaya['status'] == 1 ||
                    dataJenisBudidaya['status'] == true)
                ? 'Aktif'
                : 'Tidak Aktif';
            if (dataJenisBudidaya['gambar'] != null &&
                dataJenisBudidaya['gambar'].toString().isNotEmpty) {
              _imageUrlFromApi = dataJenisBudidaya['gambar'];
            }
          });
        } else {
          if (mounted) {
            showAppToast(context, 'Data jenis hewan ternak tidak ditemukan');
          }
        }
      } else if (mounted) {
        showAppToast(context,
            response['message'] ?? 'Gagal mengambil data jenis hewan ternak');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingEditData = false;
        });
      }
    }
  }

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
              key: const Key('open_camera'),
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
              key: const Key('open_gallery'),
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

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_imageTernak == null && !widget.isEdit) {
        showAppToast(context, 'Gambar hewan ternak tidak boleh kosong');
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      String? finalImageUrl;
      if (_imageTernak != null) {
        final imageUploadResponse =
            await _imageService.uploadImage(_imageTernak!);
        if (imageUploadResponse['status'] == true &&
            imageUploadResponse['data'] != null) {
          finalImageUrl = imageUploadResponse['data'];
        } else {
          if (mounted) {
            showAppToast(
                context,
                imageUploadResponse['message'] ??
                    'Gagal mengunggah gambar hewan ternak');
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
      } else if (widget.isEdit && _imageUrlFromApi != null) {
        finalImageUrl = _imageUrlFromApi;
      }

      final dataPayload = {
        "nama": _nameController.text,
        "latin": _latinController.text,
        "tipe": "hewan",
        "status": statusTernak == 'Aktif',
        "detail": _descriptionController.text,
        if (finalImageUrl != null) "gambar": finalImageUrl,
      };

      Map<String, dynamic> response;

      if (widget.isEdit && widget.idTernak != null) {
        response = await _jenisBudidayaService.updateJenisBudidaya(
            dataPayload, widget.idTernak!);
      } else {
        response = await _jenisBudidayaService.createJenisBudidaya(dataPayload);
      }

      if (!mounted) return;

      if (response['status'] == true) {
        widget.onTernakAdded?.call();
        showAppToast(
          context,
          widget.isEdit
              ? 'Berhasil memperbarui data jenis hewan ternak'
              : 'Berhasil menambahkan data jenis hewan ternak',
          isError: false,
        );
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
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
              greeting:
                  widget.isEdit ? 'Edit Jenis Hewan' : 'Tambah Jenis Hewan'),
        ),
      ),
      body: SafeArea(
        child: _isFetchingEditData
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
                          key: const Key('nama_hewan_ternak'),
                          label: "Nama hewan ternak",
                          hint: "Contoh: Ayam Kampung",
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama hewan ternak tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        InputFieldWidget(
                            key: const Key('nama_latin_hewan_ternak'),
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
                          key: const Key('status_ternak'),
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
                          key: const Key('image_picker_hewan_ternak'),
                          label: "Unggah gambar hewan ternak",
                          image: _imageTernak,
                          imageUrl: _imageUrlFromApi,
                          onPickImage: (ctx) => _pickImageTernak(ctx),
                        ),
                        InputFieldWidget(
                            key: const Key('deskripsi_hewan_ternak'),
                            label: "Deskripsi hewan ternak",
                            hint:
                                "Keterangan umum mengenai jenis hewan ternak ini",
                            controller: _descriptionController,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
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
              onPressed: _submitForm,
              buttonText: widget.isEdit ? 'Simpan Perubahan' : 'Tambah Ternak',
              backgroundColor: green1,
              textStyle: semibold16.copyWith(color: white),
              isLoading: _isLoading,
              key: const Key('submit_ternak_button')),
        ),
      ),
    );
  }
}
