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
  AddTanamanScreenState createState() => AddTanamanScreenState();
}

class AddTanamanScreenState extends State<AddTanamanScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final ImageService _imageService = ImageService();

  final _formKey = GlobalKey<FormState>();

  String statusBudidaya = 'Aktif';

  File? _imageTanaman;
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
    if (widget.isEdit && widget.idTanaman != null) {
      _fetchEditData();
    } else if (widget.isEdit &&
        (widget.idTanaman == null || widget.idTanaman!.isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(context,
              'ID tanaman tidak ditemukan. Pastikan Anda memilih tanaman yang benar untuk di edit.');
          Navigator.of(context).pop();
        }
      });
    }
  }

  Future<void> _fetchEditData() async {
    if (!mounted) return;
    setState(() {
      _isFetchingEditData = true;
    });
    try {
      final response =
          await _jenisBudidayaService.getJenisBudidayaById(widget.idTanaman!);

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          final apiData = response['data'];
          final dataJenisBudidaya = apiData['jenisBudidaya'];

          if (dataJenisBudidaya != null &&
              dataJenisBudidaya is Map<String, dynamic>) {
            setState(() {
              _nameController.text =
                  dataJenisBudidaya['nama']?.toString() ?? '';
              _latinController.text =
                  dataJenisBudidaya['latin']?.toString() ?? '';
              _descriptionController.text =
                  dataJenisBudidaya['detail']?.toString() ?? '';

              var statusDariApi = dataJenisBudidaya['status'];
              statusBudidaya = (statusDariApi == 1 || statusDariApi == true)
                  ? 'Aktif'
                  : 'Tidak aktif';

              if (dataJenisBudidaya['gambar'] != null &&
                  dataJenisBudidaya['gambar'].toString().isNotEmpty) {
                _imageUrlFromApi = dataJenisBudidaya['gambar'] as String?;
              } else {
                _imageUrlFromApi = null;
              }
            });
          } else {
            if (mounted) {
              showAppToast(context,
                  'Data jenis budidaya tidak ditemukan atau format tidak valid.');
            }
          }
        } else {
          if (mounted) {
            showAppToast(context,
                response['message'] ?? 'Gagal mengambil data jenis tanaman.');
          }
        }
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
              key: const Key('open_camera'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _imageTanaman = File(pickedFile.path);
                    _imageUrlFromApi = null;
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
                    _imageTanaman = File(pickedFile.path);
                    _imageUrlFromApi = null;
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

      if (_imageTanaman == null && !widget.isEdit) {
        showAppToast(
          context,
          'Gambar tanaman tidak boleh kosong. Silakan unggah gambar.',
        );
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      String? finalImageUrl;
      if (_imageTanaman != null) {
        final imageUploadResponse =
            await _imageService.uploadImage(_imageTanaman!);
        if (imageUploadResponse['status'] == true &&
            imageUploadResponse['data'] != null) {
          finalImageUrl = imageUploadResponse['data'];
        } else {
          if (mounted) {
            showAppToast(
                context,
                imageUploadResponse['message'] ??
                    'Gagal mengunggah gambar tanaman.');
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
        'nama': _nameController.text,
        'latin': _latinController.text,
        'detail': _descriptionController.text,
        'tipe': 'tumbuhan',
        'status': statusBudidaya == 'Aktif' ? 1 : 0,
        if (finalImageUrl != null) 'gambar': finalImageUrl,
      };

      Map<String, dynamic> response;

      if (widget.isEdit && widget.idTanaman != null) {
        response = await _jenisBudidayaService.updateJenisBudidaya(
            dataPayload, widget.idTanaman!);
      } else {
        response = await _jenisBudidayaService.createJenisBudidaya(dataPayload);
      }

      if (!mounted) return;

      if (response['status'] == true) {
        widget.onTanamanAdded?.call();
        showAppToast(
          context,
          widget.isEdit
              ? 'Berhasil memperbarui data jenis tanaman'
              : 'Berhasil menambahkan data jenis tanaman',
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
              title: 'Manajemen Jenis Tanaman',
              greeting: widget.isEdit
                  ? 'Edit Jenis Tanaman'
                  : 'Tambah Jenis Tanaman'),
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
                          key: const Key('nama_jenis_tanaman'),
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
                            key: const Key('nama_latin_tanaman'),
                            label: "Nama latin",
                            hint: "Contoh: Cucumis melo",
                            controller: _latinController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama latin tidak boleh kosong';
                              }
                              return null;
                            }),
                        RadioField(
                          key: const Key('status_budidaya'),
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
                          key: const Key('image_picker_tanaman'),
                          label: "Unggah gambar tanaman",
                          image: _imageTanaman,
                          imageUrl: _imageUrlFromApi,
                          onPickImage: (ctx) => _pickImageTanaman(ctx),
                        ),
                        InputFieldWidget(
                          key: const Key('deskripsi_tanaman'),
                          label: "Deskripsi tanaman",
                          hint: "Keterangan umum mengenai jenis tanaman ini",
                          controller: _descriptionController,
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Deskripsi tanaman tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
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
              buttonText: widget.isEdit ? 'Simpan Perubahan' : 'Tambah Tanaman',
              backgroundColor: green1,
              textStyle: semibold16.copyWith(color: white),
              textColor: white,
              isLoading: _isLoading,
              key: const Key('submit_tanaman_button')),
        ),
      ),
    );
  }
}
