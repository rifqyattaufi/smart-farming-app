import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class PelaporanNutrisiKebunScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanNutrisiKebunScreen({
    super.key,
    this.data,
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanNutrisiKebunScreen> createState() =>
      _PelaporanNutrisiKebunScreenState();
}

class _PelaporanNutrisiKebunScreenState
    extends State<PelaporanNutrisiKebunScreen> {
  final InventarisService _inventarisService = InventarisService();
  final ImageService _imageService = ImageService();
  final SatuanService _satuanService = SatuanService();
  final LaporanService _laporanService = LaporanService();

  List<Map<String, dynamic>> listBahanVitamin = [];
  List<Map<String, dynamic>> listBahanPupuk = [];
  List<Map<String, dynamic>> listBahanDisinfektan = [];

  bool _isLoading = false;
  final picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _satuanController = TextEditingController();

  String _selectedJenisPemberian = 'Pupuk';
  Map<String, dynamic>? _selectedBahan;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _sizeController.addListener(_updateStokDisplay);
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _sizeController.removeListener(_updateStokDisplay);
    _sizeController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

  void _updateStokDisplay() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchData() async {
    try {
      final responseVitamin =
          await _inventarisService.getInventarisByKategoriName('Vitamin');
      final responsePupuk =
          await _inventarisService.getInventarisByKategoriName('Pupuk');
      final responseDisinfektan =
          await _inventarisService.getInventarisByKategoriName('Disinfektan');

      if (mounted) {
        if (responseVitamin['status']) {
          setState(() {
            listBahanVitamin = responseVitamin['data']
                .map<Map<String, dynamic>>((item) => {
                      'name': item['nama'],
                      'id': item['id'],
                      'satuanId': item['SatuanId'],
                      'stok': double.tryParse(item['jumlah'].toString()) ?? 0.0,
                      'satuanNama': item['Satuan']?['nama'] ?? '',
                    })
                .toList();
          });
        } else {
          _showErrorSnackbar(
              'Error fetching vitamin data: ${responseVitamin['message']}');
        }

        if (responsePupuk['status']) {
          setState(() {
            listBahanPupuk = responsePupuk['data']
                .map<Map<String, dynamic>>((item) => {
                      'name': item['nama'],
                      'id': item['id'],
                      'satuanId': item['SatuanId'],
                      'stok': double.tryParse(item['jumlah'].toString()) ?? 0.0,
                      'satuanNama': item['Satuan']?['nama'] ?? '',
                    })
                .toList();
          });
        } else {
          _showErrorSnackbar(
              'Error fetching pupuk data: ${responsePupuk['message']}');
        }

        if (responseDisinfektan['status']) {
          setState(() {
            listBahanDisinfektan = responseDisinfektan['data']
                .map<Map<String, dynamic>>((item) => {
                      'name': item['nama'],
                      'id': item['id'],
                      'satuanId': item['SatuanId'],
                      'stok': double.tryParse(item['jumlah'].toString()) ?? 0.0,
                      'satuanNama': item['Satuan']?['nama'] ?? '',
                    })
                .toList();
          });
        } else {
          _showErrorSnackbar(
              'Error fetching disinfektan data: ${responseDisinfektan['message']}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error fetching data: $e');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      showAppToast(
        context,
        message,
      );
    }
  }

  Future<void> _changeSatuan() async {
    if (_selectedBahan == null || _selectedBahan!['satuanId'] == null) {
      setState(() {
        _satuanController.clear();
      });
      return;
    }
    final satuanId = _selectedBahan!['satuanId'];

    try {
      final response = await _satuanService.getSatuanById(satuanId);
      if (mounted) {
        if (response['status'] && response['data'] != null) {
          setState(() {
            _satuanController.text =
                "${response['data']['nama']} (${response['data']['lambang']})";
          });
        } else {
          _showErrorSnackbar(
              'Error fetching satuan data: ${response['message']}');
          _satuanController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error fetching satuan: $e');
        _satuanController.clear();
      }
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showErrorSnackbar("Harap periksa kembali semua isian form.");
      return;
    }

    if (_selectedImage == null) {
      _showErrorSnackbar("Harap unggah bukti gambar pemberian nutrisi.");
      return;
    }

    if (_selectedBahan == null) {
      _showErrorSnackbar("Harap pilih bahan terlebih dahulu.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrlResponse = await _imageService.uploadImage(_selectedImage!);

      if (!(imageUrlResponse['status'] ?? false) ||
          imageUrlResponse['data'] == null) {
        _showErrorSnackbar(
            'Gagal unggah gambar: ${imageUrlResponse['message']}');
        return;
      }
      final imageUrl = imageUrlResponse['data'];

      final data = {
        'unitBudidayaId': widget.data?['unitBudidaya']?['id'],
        'objekBudidayaId': null, // Kosong untuk pelaporan per kebun
        'tipe': 'vitamin',
        'judul':
            "Laporan Pemberian Nutrisi Per Kebun - ${widget.data?['unitBudidaya']?['name'] ?? ''}",
        'gambar': imageUrl,
        'catatan': _catatanController.text,
        'vitamin': {
          'inventarisId': _selectedBahan!['id'],
          'tipe': _selectedJenisPemberian,
          'jumlah': double.tryParse(_sizeController.text) ?? 0.0,
        }
      };

      final response = await _laporanService.createLaporanNutrisi(data);

      if (mounted) {
        if (response['status'] == true) {
          showAppToast(context, 'Laporan nutrisi kebun berhasil dikirim.',
              isError: false);

          // Kembali ke halaman sebelumnya sebanyak step yang ada
          for (int i = 0; i < widget.step; i++) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              break;
            }
          }
        } else {
          _showErrorSnackbar('Gagal mengirim laporan: ${response['message']}');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Terjadi kesalahan saat submit: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(BuildContext parentContext) async {
    showModalBottomSheet(
      context: parentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('camera_option'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(parentContext);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  if (mounted) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                }
              },
            ),
            ListTile(
              key: const Key('gallery_option'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(parentContext);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  if (mounted) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getCurrentBahanList() {
    switch (_selectedJenisPemberian) {
      case 'Vitamin':
        return listBahanVitamin;
      case 'Pupuk':
        return listBahanPupuk;
      case 'Disinfektan':
        return listBahanDisinfektan;
      default:
        return [];
    }
  }

  String _getStokLabel() {
    if (_selectedBahan == null) return "Jumlah/dosis";

    final stok = _selectedBahan!['stok'] as double;
    final satuanNama = _selectedBahan!['satuanNama'] as String;

    return "Jumlah/dosis (Stok: ${stok.toStringAsFixed(1)} $satuanNama)";
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
            title: 'Pelaporan Khusus',
            greeting: widget.greeting,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                BannerWidget(
                  title: 'Step ${widget.step} - Isi Form Pelaporan Kebun',
                  subtitle:
                      'Harap mengisi form pelaporan pemberian nutrisi per kebun dengan data yang benar sesuai kondisi lapangan!',
                  showDate: true,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Data Kebun
                        Text(
                          'Data Kebun',
                          style: semibold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.data?['unitBudidaya']?['name'] ?? '-'}',
                          style: bold20.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Budidaya ${widget.data?['unitBudidaya']?['category'] ?? ''}',
                          style: semibold16.copyWith(color: dark2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.data?['unitBudidaya']?['latin'] ?? ''}',
                          style: medium14.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 20),

                        // Jenis Pemberian
                        RadioField(
                          key: const Key('status_pemberian'),
                          label: 'Jenis Pemberian',
                          selectedValue: _selectedJenisPemberian,
                          options: const [
                            'Pupuk',
                            'Vitamin',
                            'Disinfektan',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedJenisPemberian = value;
                              _selectedBahan = null;
                              _sizeController.clear();
                              _satuanController.clear();
                            });
                          },
                        ),

                        // Nama Bahan
                        DropdownFieldWidget(
                          key: const Key('bahan_dropdown'),
                          label: "Nama bahan",
                          hint: "Pilih jenis bahan",
                          items: _getCurrentBahanList()
                              .map((item) => item['name'] as String)
                              .toList(),
                          selectedValue: _selectedBahan?['name'] as String?,
                          onChanged: (value) {
                            if (value == null) {
                              setState(() {
                                _selectedBahan = null;
                                _satuanController.clear();
                              });
                              return;
                            }

                            Map<String, dynamic>? matchingItem;
                            try {
                              matchingItem = _getCurrentBahanList().firstWhere(
                                (item) => item['name'] == value,
                              );
                            } catch (e) {
                              matchingItem = null;
                            }

                            setState(() {
                              _selectedBahan = matchingItem;
                              if (matchingItem == null) {
                                _satuanController.clear();
                              } else {
                                _changeSatuan();
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih bahan';
                            }
                            return null;
                          },
                        ),

                        // Jumlah/Dosis
                        InputFieldWidget(
                          key: const Key('jumlah_dosis'),
                          label: _getStokLabel(),
                          hint: "Contoh: 10",
                          controller: _sizeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan jumlah/dosis';
                            }
                            final number = double.tryParse(value);
                            if (number == null) {
                              return 'Masukkan angka yang valid';
                            }
                            if (number <= 0) {
                              return 'Jumlah/dosis harus lebih dari 0';
                            }

                            if (_selectedBahan != null) {
                              final stok = _selectedBahan!['stok'] as double;
                              if (number > stok) {
                                final satuanNama =
                                    _selectedBahan!['satuanNama'] as String;
                                return 'Dosis melebihi stok (Tersedia: ${stok.toStringAsFixed(1)} $satuanNama)';
                              }
                            }
                            return null;
                          },
                        ),

                        // Satuan Dosis
                        InputFieldWidget(
                          key: const Key('satuan_dosis'),
                          label: "Satuan dosis",
                          hint: "Pilih bahan untuk melihat satuan",
                          controller: _satuanController,
                          isDisabled: true,
                          validator: (value) {
                            if (_selectedBahan != null &&
                                (value == null || value.isEmpty)) {
                              return 'Satuan tidak termuat, pilih ulang bahan.';
                            }
                            return null;
                          },
                        ),

                        // Image Picker
                        ImagePickerWidget(
                          key: const Key('image_picker'),
                          label: "Unggah bukti pemberian nutrisi ke kebun",
                          image: _selectedImage,
                          onPickImage: (pickerContext) {
                            _pickImage(context);
                          },
                        ),

                        // Catatan
                        InputFieldWidget(
                          key: const Key('catatan_jurnal'),
                          label: "Catatan/jurnal pelaporan",
                          hint: "Keterangan",
                          controller: _catatanController,
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan catatan';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            onPressed: _submitForm,
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isLoading,
            key: const Key('submit_pelaporan_nutrisi_kebun_button'),
          ),
        ),
      ),
    );
  }
}
