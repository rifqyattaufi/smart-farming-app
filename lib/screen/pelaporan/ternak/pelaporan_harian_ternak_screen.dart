import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/radio_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanHarianTernakScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanHarianTernakScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanHarianTernakScreen> createState() =>
      _PelaporanHarianTernakScreenState();
}

class _PelaporanHarianTernakScreenState
    extends State<PelaporanHarianTernakScreen> {
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();
  final InventarisService _inventarisService = InventarisService();
  final KategoriInvService _kategoriInvService = KategoriInvService();
  final SatuanService _satuanService = SatuanService();

  String statusPakan = '';
  String statusKandang = '';

  // Variables for inventory category and feed selection
  String? selectedKategoriPakan = 'Pakan'; // Default to Pakan
  List<Map<String, dynamic>> listKategoriInventaris = [];
  Map<String, dynamic> selectedPakan = {};
  List<Map<String, dynamic>> listPakan = [];

  bool isLoading = false;
  File? _imageTernak;
  File? _imagePakan; // Image for feed dosage
  final picker = ImagePicker();
  final formKey = GlobalKey<FormState>();

  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _jumlahPakanController = TextEditingController();
  final TextEditingController _satuanPakanController = TextEditingController();

  Future<void> _pickImage(
      BuildContext context, Function(File) onImagePicked) async {
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
              key: const Key('camera'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  onImagePicked(File(pickedFile.path));
                }
              },
            ),
            ListTile(
              key: const Key('gallery'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  onImagePicked(File(pickedFile.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImagePakan(BuildContext context) async {
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
              key: const Key('camera_pakan'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _imagePakan = File(pickedFile.path);
                  });
                }
              },
            ),
            ListTile(
              key: const Key('gallery_pakan'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imagePakan = File(pickedFile.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchKategoriData() async {
    try {
      final response = await _kategoriInvService.getKategoriInventarisOnly();
      if (response['status'] && response['data'] != null) {
        setState(() {
          listKategoriInventaris =
              List<Map<String, dynamic>>.from(response['data']);
        });
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal memuat kategori inventaris');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _fetchInventarisByKategori(String kategoriName) async {
    setState(() {
      listPakan = [];
      selectedPakan = {};
      _jumlahPakanController.clear();
      _satuanPakanController.clear();
    });

    try {
      final response =
          await _inventarisService.getInventarisByKategoriName(kategoriName);
      if (response['status'] && response['data'] != null) {
        setState(() {
          final today = DateTime.now();
          listPakan = List<Map<String, dynamic>>.from(
            (response['data'] as List).where((item) {
              // Filter for active inventory items
              final tanggalKadaluarsa = item['tanggalKadaluarsa'];
              if (tanggalKadaluarsa == null) return true;

              try {
                final kadaluarsaDate = DateTime.parse(tanggalKadaluarsa);
                return kadaluarsaDate.isAfter(today);
              } catch (e) {
                return true; // Include if date parsing fails
              }
            }).map((item) => {
                  'id': item['id'],
                  'name': item['nama'],
                  'stok': item['jumlah'],
                  'satuanId': item['SatuanId'],
                  'satuanNama': item['Satuan']?['nama'] ?? '',
                }),
          );
        });
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal memuat data inventaris');
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _changeSatuanPakan() async {
    final satuanId = selectedPakan['satuanId'];
    if (satuanId != null) {
      try {
        final response = await _satuanService.getSatuanById(satuanId);
        if (response['status']) {
          setState(() {
            _satuanPakanController.text =
                "${response['data']['nama']} - ${response['data']['lambang']}";
          });
        } else {
          showAppToast(context, 'Gagal memuat data satuan');
        }
      } catch (e) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    }
  }

  Future<void> _submitForm() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      if (!formKey.currentState!.validate()) {
        setState(() => isLoading = false);
        return;
      }

      if (_imageTernak == null) {
        showAppToast(
            context, 'Silakan unggah bukti kondisi ternak terlebih dahulu');
        setState(() => isLoading = false);
        return;
      }

      // Validate feed data if feeding is selected
      if (statusPakan == 'Ya') {
        if (selectedPakan.isEmpty) {
          showAppToast(
              context, 'Silakan pilih item inventaris terlebih dahulu');
          setState(() => isLoading = false);
          return;
        }

        if (_jumlahPakanController.text.isEmpty) {
          showAppToast(context, 'Silakan masukkan jumlah inventaris');
          setState(() => isLoading = false);
          return;
        }

        if (_imagePakan == null) {
          showAppToast(context, 'Silakan unggah bukti penggunaan inventaris');
          setState(() => isLoading = false);
          return;
        }
      }

      formKey.currentState!.save();

      final imageUrl = await _imageService.uploadImage(_imageTernak!);
      if (!imageUrl['status']) {
        showAppToast(context,
            'Gagal mengunggah gambar kondisi ternak: ${imageUrl['message']}');
        setState(() => isLoading = false);
        return;
      }

      // Prepare main livestock report data
      final data = {
        'unitBudidayaId': widget.data?['unitBudidaya']['id'],
        "judul": "Laporan Harian ${widget.data?['unitBudidaya']['name']}",
        "tipe": widget.tipe,
        "gambar": imageUrl['data'],
        "catatan": _catatanController.text,
        "harianTernak": {
          "pakan": statusPakan == 'Ya',
          "cekKandang": statusKandang == 'Ya',
        }
      };

      final response = await _laporanService.createLaporanHarianTernak(data);

      if (!response['status']) {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan saat menyimpan laporan');
        setState(() => isLoading = false);
        return;
      }

      // Submit feed inventory usage report if feeding was done
      if (statusPakan == 'Ya' &&
          selectedPakan.isNotEmpty &&
          _imagePakan != null) {
        final imagePakanUrl = await _imageService.uploadImage(_imagePakan!);
        if (!imagePakanUrl['status']) {
          showAppToast(context,
              'Gagal mengunggah gambar bukti pakan: ${imagePakanUrl['message']}');
          setState(() => isLoading = false);
          return;
        }

        final inventarisYangDipilih = listPakan.firstWhere(
          (item) => item['id'] == selectedPakan['id'],
          orElse: () => {'nama': 'Tidak Diketahui'},
        );
        final inventarisNama =
            inventarisYangDipilih['name'] ?? inventarisYangDipilih['nama'];

        final dataPakan = {
          "judul":
              "Laporan Penggunaan ${selectedKategoriPakan ?? 'Inventaris'} $inventarisNama - ${widget.data?['unitBudidaya']['name']}",
          "tipe": "inventaris",
          "gambar": imagePakanUrl['data'],
          "catatan":
              "Penggunaan ${selectedKategoriPakan?.toLowerCase() ?? 'inventaris'} untuk ${widget.data?['unitBudidaya']['name']} - ${_catatanController.text}",
          "penggunaanInv": {
            "inventarisId": selectedPakan['id'],
            "jumlah": double.tryParse(_jumlahPakanController.text) ?? 0.0,
          }
        };

        final responsePakan =
            await _laporanService.createLaporanPenggunaanInventaris(dataPakan);

        if (!responsePakan['status']) {
          showAppToast(context,
              'Laporan harian berhasil disimpan, namun gagal mencatat penggunaan inventaris: ${responsePakan['message']}');
        }
      }

      if (mounted) {
        showAppToast(
          context,
          statusPakan == 'Ya'
              ? 'Berhasil mengirim laporan harian ternak dan penggunaan inventaris'
              : 'Berhasil mengirim laporan harian ternak',
          isError: false,
        );
      }

      for (int i = 0; i < widget.step; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchKategoriData();
    _fetchInventarisByKategori('Pakan'); // Load default Pakan category
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _jumlahPakanController.dispose();
    _satuanPakanController.dispose();
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
          title: const Header(
            headerType: HeaderType.back,
            title: 'Menu Pelaporan',
            greeting: 'Pelaporan Harian',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BannerWidget(
                  title: 'Step ${widget.step} - Isi Form Pelaporan',
                  subtitle:
                      'Harap mengisi form dengan data yang benar sesuai kondisi lapangan!',
                  showDate: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Ternak',
                        style: semibold16.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.data?['unitBudidaya']['category'] ?? 'unknown',
                        style: bold20.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.data?['unitBudidaya']['name'] ?? 'unknown',
                        style: semibold16.copyWith(color: dark1),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioField(
                          key: const Key('status_pakan'),
                          label: 'Dilakukan pemberian pakan?',
                          selectedValue: statusPakan,
                          options: const ['Ya', 'Belum'],
                          onChanged: (value) {
                            setState(() {
                              statusPakan = value;
                              // Reset feed data when "Belum" is selected
                              if (value == 'Belum') {
                                selectedPakan = {};
                                _jumlahPakanController.clear();
                                _satuanPakanController.clear();
                                _imagePakan = null;
                              }
                            });
                          },
                        ),

                        // Feed inventory form fields - only show when "Ya" is selected
                        if (statusPakan == 'Ya') ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
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
                                    Icon(Icons.inventory,
                                        color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Informasi Penggunaan Inventaris',
                                      style: semibold16.copyWith(
                                          color: Colors.blue.shade700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pilih jenis dan item inventaris yang digunakan untuk pemberian pakan.',
                                  style: regular12.copyWith(
                                      color: Colors.blue.shade600),
                                ),
                                const SizedBox(height: 16),
                                DropdownFieldWidget(
                                  key:
                                      const Key('dropdown_kategori_inventaris'),
                                  label: 'Jenis inventaris',
                                  hint: 'Pilih kategori inventaris',
                                  items: listKategoriInventaris
                                      .map((item) => item['nama'] as String)
                                      .toList(),
                                  selectedValue: selectedKategoriPakan,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedKategoriPakan = value;
                                        // Reset selected inventory when category changes
                                        selectedPakan = {};
                                        _jumlahPakanController.clear();
                                        _satuanPakanController.clear();
                                      });
                                      _fetchInventarisByKategori(value);
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih jenis inventaris';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownFieldWidget(
                                  key: const Key('dropdown_pakan'),
                                  label: 'Pilih item inventaris',
                                  hint: 'Pilih inventaris yang akan digunakan',
                                  items: listPakan.map((item) {
                                    final stok =
                                        (item['stok'] as num?)?.toDouble() ??
                                            0.0;
                                    final satuanNama = item['satuanNama'] ?? '';
                                    return '${item['name']} (Stok: ${stok.toStringAsFixed(1)} $satuanNama)';
                                  }).toList(),
                                  selectedValue: selectedPakan.isNotEmpty
                                      ? '${selectedPakan['name']} (Stok: ${(selectedPakan['stok'] as num?)?.toDouble().toStringAsFixed(1) ?? '0.0'} ${selectedPakan['satuanNama'] ?? ''})'
                                      : null,
                                  onChanged: (value) {
                                    if (value == null) {
                                      setState(() {
                                        selectedPakan = {};
                                        _satuanPakanController.clear();
                                      });
                                      return;
                                    }

                                    Map<String, dynamic> findPakan(
                                        List<Map<String, dynamic>> list) {
                                      for (var item in list) {
                                        final stok = (item['stok'] as num?)
                                                ?.toDouble() ??
                                            0.0;
                                        final satuanNama =
                                            item['satuanNama'] ?? '';
                                        final displayText =
                                            '${item['name']} (Stok: ${stok.toStringAsFixed(1)} $satuanNama)';
                                        if (displayText == value) {
                                          return item;
                                        }
                                      }
                                      return {};
                                    }

                                    setState(() {
                                      selectedPakan = findPakan(listPakan);
                                      if (selectedPakan.isNotEmpty) {
                                        _changeSatuanPakan();
                                      } else {
                                        _satuanPakanController.clear();
                                      }
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih jenis pakan';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                InputFieldWidget(
                                  key: const Key('jumlah_pakan'),
                                  label: 'Jumlah inventaris yang digunakan',
                                  hint: 'Contoh: 5.5',
                                  controller: _jumlahPakanController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan jumlah inventaris';
                                    }
                                    final number = double.tryParse(value);
                                    if (number == null || number <= 0) {
                                      return 'Masukkan jumlah yang valid';
                                    }
                                    // Check if amount exceeds available stock
                                    if (selectedPakan.isNotEmpty) {
                                      final stok =
                                          (selectedPakan['stok'] as num?)
                                                  ?.toDouble() ??
                                              0.0;
                                      if (number > stok) {
                                        final satuanNama =
                                            selectedPakan['satuanNama'] ?? '';
                                        return 'Jumlah melebihi stok tersedia (${stok.toStringAsFixed(1)} $satuanNama)';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                InputFieldWidget(
                                  key: const Key('satuan_pakan'),
                                  label: 'Satuan',
                                  hint: 'Pilih inventaris untuk melihat satuan',
                                  controller: _satuanPakanController,
                                  isDisabled: true,
                                  validator: (value) {
                                    if (selectedPakan.isNotEmpty &&
                                        (value == null || value.isEmpty)) {
                                      return 'Satuan tidak termuat, pilih ulang inventaris';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ImagePickerWidget(
                                  key: const Key('image_picker_pakan'),
                                  label: 'Unggah bukti penggunaan inventaris',
                                  image: _imagePakan,
                                  onPickImage: (context) {
                                    _pickImagePakan(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        RadioField(
                          key: const Key('status_kandang'),
                          label: 'Dilakukan pengecekan & pembersihan kandang?',
                          selectedValue: statusKandang,
                          options: const ['Ya', 'Tidak'],
                          onChanged: (value) {
                            setState(() {
                              statusKandang = value;
                            });
                          },
                        ),
                        ImagePickerWidget(
                          key: const Key('image_picker_ternak'),
                          label: "Unggah bukti kondisi ternak",
                          image: _imageTernak,
                          onPickImage: (context) {
                            _pickImage(context, (file) {
                              setState(() {
                                _imageTernak = file;
                              });
                            });
                          },
                        ),
                        InputFieldWidget(
                            key: const Key('catatan_jurnal'),
                            label: "Catatan/jurnal pelaporan",
                            hint: "Keterangan",
                            controller: _catatanController,
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Catatan tidak boleh kosong';
                              }
                              return null;
                            }),
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
            onPressed: () {
              _submitForm();
            },
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: isLoading,
            key: const Key('submit_pelaporan_harian_ternak_button'),
          ),
        ),
      ),
    );
  }
}
