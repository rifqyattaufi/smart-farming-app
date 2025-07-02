import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'dart:io';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddKomoditasTernakScreen extends StatefulWidget {
  final bool isEdit;
  final VoidCallback? onKomoditasAdded;
  final String? idKomoditas;

  const AddKomoditasTernakScreen(
      {super.key,
      this.onKomoditasAdded,
      this.isEdit = false,
      this.idKomoditas});

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
  bool _isFetchingEditData = false;
  final _formKey = GlobalKey<FormState>();
  String? _imageUrlFromApi;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  int _currentJumlah = 0;

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
        showAppToast(
            context, 'Error fetching satuan data: ${satuanResponse['message']}',
            isError: true);
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
        showAppToast(context,
            'Error fetching jenis ternak data: ${jenisBudidayaResponse['message']}',
            isError: true);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
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
              key: const Key('cameraTile'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _imageUrlFromApi = null;
                  });
                }
              },
            ),
            ListTile(
              key: const Key('galleryTile'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
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
    if (isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (_image == null && !widget.isEdit) {
        showAppToast(context,
            'Gambar komoditas tidak boleh kosong. Silakan unggah gambar.',
            isError: true);
        return;
      }

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      String? finalImageUrl;
      if (_image != null) {
        final imageUploadResponse = await _imageService.uploadImage(_image!);
        if (imageUploadResponse['status'] == true &&
            imageUploadResponse['data'] != null) {
          finalImageUrl = imageUploadResponse['data'];
        } else {
          if (mounted) {
            showAppToast(
                context,
                imageUploadResponse['message'] ??
                    'Gagal mengunggah gambar komoditas.');
            setState(() {
              isLoading = false;
            });
          }
          return;
        }
      } else if (widget.isEdit && _imageUrlFromApi != null) {
        finalImageUrl = _imageUrlFromApi;
      }

      final dataPayload = {
        'nama': _nameController.text,
        'satuanId': selectedSatuan,
        'jenisBudidayaId': selectedTernak,
        'jumlah': widget.isEdit ? int.parse(_jumlahController.text) : 0,
        if (finalImageUrl != null) 'gambar': finalImageUrl,
      };

      // Debug log untuk memastikan data yang dikirim

      Map<String, dynamic> response;

      if (widget.isEdit && widget.idKomoditas != null) {
        response = await _komoditasService.updateKomoditas(
            dataPayload, widget.idKomoditas!);
      } else {
        response = await _komoditasService.createKomoditas(dataPayload);
      }

      if (!mounted) return;

      if (response['status'] == true) {
        widget.onKomoditasAdded?.call();
        showAppToast(
          context,
          widget.isEdit
              ? 'Berhasil memperbarui data komoditas ternak'
              : 'Berhasil menambahkan data komoditas ternak',
          isError: false,
        );
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false;
        });
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    }
  }

  Future<void> _fetchEditData() async {
    if (!mounted) return;
    setState(() {
      _isFetchingEditData = true;
    });
    try {
      final response =
          await _komoditasService.getKomoditasById(widget.idKomoditas!);

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          final apiData = response['data'];

          if (apiData != null && apiData is Map<String, dynamic>) {
            setState(() {
              _nameController.text = apiData['nama']?.toString() ?? '';
              _currentJumlah = apiData['jumlah'] as int? ?? 0;
              _jumlahController.text = _currentJumlah.toString();

              // Set selected jenis ternak
              if (apiData['JenisBudidaya'] != null) {
                selectedTernak = apiData['JenisBudidaya']['id']?.toString();
              }

              // Set selected satuan
              if (apiData['Satuan'] != null) {
                selectedSatuan = apiData['Satuan']['id']?.toString();
              }

              if (apiData['gambar'] != null &&
                  apiData['gambar'].toString().isNotEmpty) {
                _imageUrlFromApi = apiData['gambar'] as String?;
              } else {
                _imageUrlFromApi = null;
              }
            });
          } else {
            if (mounted) {
              showAppToast(context,
                  'Data komoditas tidak ditemukan atau format tidak valid.');
            }
          }
        } else {
          if (mounted) {
            showAppToast(context,
                response['message'] ?? 'Gagal mengambil data komoditas.');
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

  @override
  void initState() {
    super.initState();
    _fetchData().then((_) {
      if (widget.isEdit && widget.idKomoditas != null) {
        _fetchEditData();
      } else if (widget.isEdit &&
          (widget.idKomoditas == null || widget.idKomoditas!.isEmpty)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showAppToast(context,
                'ID komoditas tidak ditemukan. Pastikan Anda memilih komoditas yang benar untuk di edit.');
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jumlahController.dispose();
    super.dispose();
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
              title: 'Manajemen Komoditas',
              greeting:
                  widget.isEdit ? 'Edit Komoditas Ternak' : 'Tambah Komoditas'),
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
                            key: const Key('nameField'),
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
                          key: const Key('jenisTernakField'),
                          label: "Pilih jenis ternak",
                          hint: "Pilih jenis ternak",
                          items: jenisHewanList
                              .map((item) => item['nama'] as String)
                              .toList(),
                          selectedValue: selectedTernak != null && jenisHewanList.isNotEmpty
                              ? jenisHewanList
                                  .where((item) => item['id'] == selectedTernak)
                                  .isNotEmpty
                                  ? jenisHewanList.firstWhere(
                                      (item) => item['id'] == selectedTernak)['nama']
                                  : null
                              : null,
                          onChanged: (value) {
                            setState(() {
                              final selectedItem = jenisHewanList.firstWhere(
                                (item) => item['nama'] == value,
                                orElse: () => {'id': null},
                              );
                              selectedTernak = selectedItem['id']?.toString();
                              // Debug log
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis ternak tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        DropdownFieldWidget(
                          key: const Key('satuanField'),
                          label: "Satuan",
                          hint: "Pilih satuan",
                          items: satuanList
                              .map((item) => item['nama'] as String)
                              .toList(),
                          selectedValue: selectedSatuan != null && satuanList.isNotEmpty
                              ? satuanList
                                  .where((item) => item['id'] == selectedSatuan)
                                  .isNotEmpty
                                  ? satuanList.firstWhere(
                                      (item) => item['id'] == selectedSatuan)['nama']
                                  : null
                              : null,
                          onChanged: (value) {
                            setState(() {
                              final selectedItem = satuanList.firstWhere(
                                (item) => item['nama'] == value,
                                orElse: () => {'id': null},
                              );
                              selectedSatuan = selectedItem['id']?.toString();
                              // Debug log
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Satuan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        if (widget.isEdit) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Pengurangan Stok Komoditas",
                            style: semibold14.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Masukkan jumlah yang tersisa setelah dikurangi. Jumlah tidak boleh lebih dari jumlah saat ini.",
                            style: regular12.copyWith(color: dark2),
                          ),
                          const SizedBox(height: 8),
                          InputFieldWidget(
                            key: const Key('jumlahField'),
                            label:
                                "Jumlah hasil ternak (saat ini: $_currentJumlah)",
                            hint: "Masukkan jumlah yang tersisa",
                            controller: _jumlahController,
                            keyboardType: TextInputType.number,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    final currentValue =
                                        int.tryParse(_jumlahController.text) ??
                                            0;
                                    if (currentValue > 0) {
                                      _jumlahController.text =
                                          (currentValue - 1).toString();
                                    }
                                  },
                                  key: const Key('decreaseButton'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.green),
                                  onPressed: () {
                                    final currentValue =
                                        int.tryParse(_jumlahController.text) ??
                                            0;
                                    if (currentValue < _currentJumlah) {
                                      _jumlahController.text =
                                          (currentValue + 1).toString();
                                    }
                                  },
                                  key: const Key('increaseButton'),
                                ),
                              ],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah hasil ternak tidak boleh kosong';
                              }
                              final inputValue = int.tryParse(value);
                              if (inputValue == null) {
                                return 'Jumlah hasil ternak harus berupa angka';
                              }
                              if (inputValue < 0) {
                                return 'Jumlah hasil ternak tidak boleh negatif';
                              }
                              if (inputValue > _currentJumlah) {
                                return 'Jumlah tidak boleh lebih dari $_currentJumlah';
                              }
                              return null;
                            },
                          ),
                        ],
                        ImagePickerWidget(
                          key: const Key('imagePicker'),
                          label: "Unggah gambar komoditas",
                          image: _image,
                          imageUrl: _imageUrlFromApi,
                          onPickImage: _pickImage,
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
            buttonText: widget.isEdit ? 'Simpan Perubahan' : 'Tambah Komoditas',
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: isLoading,
            key: const Key('submitKomoditasButton'),
          ),
        ),
      ),
    );
  }
}
