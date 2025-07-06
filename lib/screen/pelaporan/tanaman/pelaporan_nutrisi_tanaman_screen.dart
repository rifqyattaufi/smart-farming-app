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

class PelaporanNutrisiTanamanScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanNutrisiTanamanScreen({
    super.key,
    this.data,
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanNutrisiTanamanScreen> createState() =>
      _PelaporanNutrisiTanamanScreenState();
}

class _PelaporanNutrisiTanamanScreenState
    extends State<PelaporanNutrisiTanamanScreen> {
  final InventarisService _inventarisService = InventarisService();
  final ImageService _imageService = ImageService();
  final SatuanService _satuanService = SatuanService();
  final LaporanService _laporanService = LaporanService();

  List<Map<String, dynamic>> _objekBudidayaList = [];
  List<String?> statusPemberianList = [];
  List<Map<String, dynamic>?> selectedBahanList = [];

  List<Map<String, dynamic>> listBahanVitamin = [];
  List<Map<String, dynamic>> listBahanPupuk = [];
  List<Map<String, dynamic>> listBahanDisinfektan = [];

  bool _isLoading = false;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _catatanControllers = [];
  List<TextEditingController> _sizeControllers = [];
  List<TextEditingController> _satuanControllers = [];
  List<File?> _imageList = [];

  @override
  void initState() {
    super.initState();
    _initializeForms();
    _fetchData();
  }

  void _initializeForms() {
    final rawObjekBudidayaList = widget.data?['objekBudidaya'];
    if (rawObjekBudidayaList is List && rawObjekBudidayaList.isNotEmpty) {
      _objekBudidayaList = List<Map<String, dynamic>>.from(
          rawObjekBudidayaList.map((e) => e as Map<String, dynamic>));
    } else {
      _objekBudidayaList = [];
    }

    int length = _objekBudidayaList.length;
    if (length == 0 &&
        widget.data != null &&
        widget.data!.containsKey('unitBudidaya')) {}

    _disposeControllers();

    _catatanControllers = List.generate(length, (_) => TextEditingController());
    _sizeControllers = List.generate(length, (index) {
      final controller = TextEditingController();
      // Add listener untuk update stok display
      controller.addListener(() => _updateStokDisplay());
      return controller;
    });
    _satuanControllers = List.generate(length, (_) => TextEditingController());
    _imageList = List.generate(length, (_) => null);

    _formKeys.clear();
    _formKeys.addAll(List.generate(length, (_) => GlobalKey<FormState>()));

    statusPemberianList = List.generate(length, (_) => 'Pupuk'); // Default
    selectedBahanList = List.generate(length, (_) => null); // Default null
  }

  void _disposeControllers() {
    for (var controller in _catatanControllers) {
      controller.dispose();
    }
    for (var controller in _sizeControllers) {
      controller.removeListener(() => _updateStokDisplay());
      controller.dispose();
    }
    for (var controller in _satuanControllers) {
      controller.dispose();
    }
    _catatanControllers = [];
    _sizeControllers = [];
    _satuanControllers = [];
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
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

  Future<void> changeSatuan(int i) async {
    final selectedBahan = selectedBahanList[i];
    if (selectedBahan == null || selectedBahan['satuanId'] == null) {
      setState(() {
        _satuanControllers[i].clear();
      });
      return;
    }
    final satuanId = selectedBahan['satuanId'];

    try {
      final response = await _satuanService.getSatuanById(satuanId);
      if (mounted) {
        if (response['status'] && response['data'] != null) {
          setState(() {
            _satuanControllers[i].text =
                "${response['data']['nama']} (${response['data']['lambang']})";
          });
        } else {
          _showErrorSnackbar(
              'Error fetching satuan data: ${response['message']}');
          _satuanControllers[i].clear(); // Kosongkan jika error
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error fetching satuan: $e');
        _satuanControllers[i].clear();
      }
    }
  }

  void _updateStokDisplay() {
    // Trigger rebuild untuk update label stok
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildInfoPenggunaanBahan(
      int currentIndex, Map<String, dynamic> bahan) {
    final bahanId = bahan['id'].toString();
    final bahanNama = bahan['name'];

    // Hitung berapa tanaman lain yang menggunakan bahan yang sama
    List<int> tanamanLainIndices = [];
    for (int i = 0; i < selectedBahanList.length; i++) {
      if (i != currentIndex &&
          selectedBahanList[i] != null &&
          selectedBahanList[i]!['id'].toString() == bahanId) {
        tanamanLainIndices.add(i);
      }
    }

    if (tanamanLainIndices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
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
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Bahan "$bahanNama" juga digunakan oleh:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...tanamanLainIndices.map((index) {
            final dosisText = _sizeControllers[index].text;
            final dosis = double.tryParse(dosisText) ?? 0.0;
            final tanamanNama =
                _objekBudidayaList[index]['name'] ?? 'Tanpa Nama';
            return Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                '• Tanaman ${index + 1} ($tanamanNama): ${dosis > 0 ? '${dosis.toStringAsFixed(1)} ${bahan['satuanNama']}' : 'Belum diisi'}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade600,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    bool allFormsValid = true;
    List<String> errorMessages = [];

    if (_objekBudidayaList.isEmpty) {
      _showErrorSnackbar("Tidak ada data objek budidaya untuk dilaporkan.");
      setState(() => _isLoading = false);
      return;
    }

    // Validasi stok kumulatif untuk semua bahan yang digunakan
    Map<String, double> penggunaanBahan = {};
    Map<String, Map<String, dynamic>> infoBahan = {};

    for (int i = 0; i < _objekBudidayaList.length; i++) {
      if (selectedBahanList[i] != null) {
        final bahanId = selectedBahanList[i]!['id'].toString();
        final dosisText = _sizeControllers[i].text;
        final dosis = double.tryParse(dosisText) ?? 0.0;

        penggunaanBahan[bahanId] = (penggunaanBahan[bahanId] ?? 0.0) + dosis;

        if (!infoBahan.containsKey(bahanId)) {
          final stokValue = selectedBahanList[i]!['stok'];
          final stokDouble = (stokValue is double)
              ? stokValue
              : double.tryParse(stokValue.toString()) ?? 0.0;

          infoBahan[bahanId] = {
            'nama': selectedBahanList[i]!['name'],
            'stok': stokDouble,
            'satuanNama': selectedBahanList[i]!['satuanNama'],
          };
        }
      }
    }

    // Cek apakah ada penggunaan yang melebihi stok
    for (final entry in penggunaanBahan.entries) {
      final bahanId = entry.key;
      final totalPenggunaan = entry.value;
      final infoBahanItem = infoBahan[bahanId]!;
      final stok = infoBahanItem['stok'] as double;

      if (totalPenggunaan > stok) {
        errorMessages.add(
            "Total penggunaan ${infoBahanItem['nama']} (${totalPenggunaan.toStringAsFixed(1)} ${infoBahanItem['satuanNama']}) melebihi stok yang tersedia (${stok.toStringAsFixed(1)} ${infoBahanItem['satuanNama']})");
        allFormsValid = false;
      }
    }

    for (int i = 0; i < _objekBudidayaList.length; i++) {
      // Validasi form
      if (!(_formKeys[i].currentState?.validate() ?? false)) {
        allFormsValid = false;
      }
      // Validasi gambar
      if (_imageList[i] == null) {
        allFormsValid = false;
        errorMessages.add(
            "Bukti gambar untuk tanaman ke-${i + 1} (${_objekBudidayaList[i]['name'] ?? 'Tanpa Nama'}) belum diunggah.");
      }
      // Validasi bahan terpilih
      if (selectedBahanList[i] == null || selectedBahanList[i]!['id'] == null) {
        allFormsValid = false;
        errorMessages.add(
            "Bahan untuk tanaman ke-${i + 1} (${_objekBudidayaList[i]['name'] ?? 'Tanpa Nama'}) belum dipilih.");
      }
    }

    if (!allFormsValid) {
      if (errorMessages.isNotEmpty) {
        _showErrorSnackbar(errorMessages.join('\n'));
      } else {
        _showErrorSnackbar("Harap periksa kembali semua isian form.");
      }
      setState(() => _isLoading = false);
      return;
    }

    List<bool> submissionStatus = [];
    try {
      for (int i = 0; i < _objekBudidayaList.length; i++) {
        final objek = _objekBudidayaList[i];
        final imageUrlResponse =
            await _imageService.uploadImage(_imageList[i]!);

        if (!(imageUrlResponse['status'] ?? false) ||
            imageUrlResponse['data'] == null) {
          _showErrorSnackbar(
              'Gagal unggah gambar untuk ${objek['name'] ?? 'tanaman ke-${i + 1}'}: ${imageUrlResponse['message']}');
          submissionStatus.add(false);
          continue;
        }
        final imageUrl = imageUrlResponse['data'];

        final data = {
          'unitBudidayaId': widget.data?['unitBudidaya']?['id'],
          'objekBudidayaId': objek['id'],
          'tipe': widget.tipe,
          'judul':
              "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${objek['name'] ?? ''}",
          'gambar': imageUrl,
          'catatan': _catatanControllers[i].text,
          'vitamin': {
            'inventarisId': selectedBahanList[i]!['id'],
            'tipe': statusPemberianList[i],
            'jumlah': double.tryParse(_sizeControllers[i].text) ?? 0.0,
          }
        };

        final response = await _laporanService.createLaporanNutrisi(data);
        submissionStatus.add(response['status'] ?? false);

        if (mounted) {
          if (response['status'] == true) {
            showAppToast(context,
                'Laporan untuk ${objek['name'] ?? 'tanaman ke-${i + 1}'} berhasil dikirim.',
                isError: false);
          } else {
            _showErrorSnackbar(
                'Gagal mengirim laporan untuk ${objek['name'] ?? 'tanaman ke-${i + 1}'}: ${response['message']}');
          }
        }
      }

      if (submissionStatus.every((status) => status)) {
        if (mounted) {
          for (int i = 0; i < widget.step; i++) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              break;
            }
          }
        }
      } else {
        _showErrorSnackbar(
            "Beberapa laporan gagal dikirim. Silakan periksa kembali.");
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

  Future<void> _pickImageDosis(BuildContext parentContext, int index) async {
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
                      _imageList[index] = File(pickedFile.path);
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
                      _imageList[index] = File(pickedFile.path);
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

  @override
  Widget build(BuildContext context) {
    if (_objekBudidayaList.isEmpty &&
        widget.data != null &&
        widget.data!.containsKey('unitBudidaya')) {}

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
        child: _objekBudidayaList.isEmpty
            ? Center(
                child: Text(
                  key: const Key('no_data_available'),
                  "Tidak ada data tanaman untuk dilaporkan.",
                  style: regular16.copyWith(color: dark1),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      BannerWidget(
                        title: 'Step ${widget.step}  - Isi Form Pelaporan',
                        subtitle:
                            'Harap mengisi form dengan data yang benar sesuai kondisi lapangan!',
                        showDate: true,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _objekBudidayaList.length,
                        itemBuilder: (context, i) {
                          final objek = _objekBudidayaList[i];
                          List<Map<String, dynamic>> currentBahanList;
                          switch (statusPemberianList[i]) {
                            case 'Vitamin':
                              currentBahanList = listBahanVitamin;
                              break;
                            case 'Pupuk':
                              currentBahanList = listBahanPupuk;
                              break;
                            case 'Disinfektan':
                              currentBahanList = listBahanDisinfektan;
                              break;
                            default:
                              currentBahanList = [];
                          }

                          Map<String, dynamic>? currentBahanTerpilih =
                              (selectedBahanList.length > i)
                                  ? selectedBahanList[i]
                                  : null;

                          String labelUntukJumlah = "Jumlah/dosis";
                          String satuanDisplay = "";

                          if (currentBahanTerpilih != null &&
                              currentBahanTerpilih['stok'] != null) {
                            final double stokAwal =
                                (currentBahanTerpilih['stok'] is double)
                                    ? currentBahanTerpilih['stok'] as double
                                    : double.tryParse(
                                            currentBahanTerpilih['stok']
                                                .toString()) ??
                                        0.0;
                            satuanDisplay =
                                currentBahanTerpilih['satuanNama'] as String? ??
                                    '';

                            if (stokAwal > 0) {
                              // Hitung total penggunaan bahan yang sama di tanaman sebelumnya
                              double totalTerpakai = 0.0;
                              final currentBahanId =
                                  currentBahanTerpilih['id'].toString();

                              for (int j = 0; j < i; j++) {
                                if (selectedBahanList.length > j &&
                                    selectedBahanList[j] != null &&
                                    selectedBahanList[j]!['id'].toString() ==
                                        currentBahanId) {
                                  final dosisText = _sizeControllers[j].text;
                                  final dosis =
                                      double.tryParse(dosisText) ?? 0.0;
                                  totalTerpakai += dosis;
                                }
                              }

                              final double stokTersisa =
                                  stokAwal - totalTerpakai;
                              final String stokFormatted =
                                  stokTersisa.toStringAsFixed(1);

                              if (totalTerpakai > 0) {
                                labelUntukJumlah =
                                    "Jumlah/dosis (Sisa: $stokFormatted $satuanDisplay, Terpakai: ${totalTerpakai.toStringAsFixed(1)} $satuanDisplay)";
                              } else {
                                labelUntukJumlah =
                                    "Jumlah/dosis (Sisa: $stokFormatted $satuanDisplay)";
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Form(
                              key: _formKeys[i],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_objekBudidayaList.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tanaman Ke-${i + 1}: ${objek['name'] ?? 'Tanpa Nama'}',
                                            style:
                                                bold18.copyWith(color: dark1),
                                          ),
                                          // Tampilkan informasi penggunaan bahan yang sama jika ada
                                          if (currentBahanTerpilih != null) ...[
                                            const SizedBox(height: 4),
                                            _buildInfoPenggunaanBahan(
                                                i, currentBahanTerpilih),
                                          ],
                                        ],
                                      ),
                                    ),
                                  if (_objekBudidayaList.length == 1 &&
                                      objek['name'] != null)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Data Tanaman',
                                          style:
                                              semibold16.copyWith(color: dark1),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          ((objek['name'] != null &&
                                                      (objek['name'] as String)
                                                          .isNotEmpty)
                                                  ? '${objek['name']} - '
                                                  : '') +
                                              (widget.data?['unitBudidaya']
                                                      ?['category'] ??
                                                  '-'),
                                          style: bold20.copyWith(color: dark1),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${widget.data?['unitBudidaya']?['latin'] ?? ''} - ${widget.data?['unitBudidaya']?['name'] ?? ''}',
                                          style:
                                              semibold16.copyWith(color: dark1),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  RadioField(
                                    key: Key('status_pemberian_$i'),
                                    label: 'Jenis Pemberian',
                                    selectedValue:
                                        statusPemberianList[i] ?? 'Pupuk',
                                    options: const [
                                      'Pupuk',
                                      'Vitamin',
                                      'Disinfektan',
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        statusPemberianList[i] = value;
                                        selectedBahanList[i] = null;
                                        _sizeControllers[i].clear();
                                        _satuanControllers[i].clear();
                                      });
                                    },
                                  ),
                                  DropdownFieldWidget(
                                    key: Key('bahan_dropdown_$i'),
                                    label: "Nama bahan",
                                    hint: "Pilih jenis bahan",
                                    items: currentBahanList
                                        .map((item) => item['name'] as String)
                                        .toList(),
                                    selectedValue: selectedBahanList[i]?['name']
                                        as String?,
                                    onChanged: (value) {
                                      if (value == null) {
                                        setState(() {
                                          selectedBahanList[i] = null;
                                          _satuanControllers[i].clear();
                                        });
                                        return;
                                      }

                                      Map<String, dynamic>? matchingItem;
                                      try {
                                        matchingItem =
                                            currentBahanList.firstWhere(
                                          (item) => item['name'] == value,
                                        );
                                      } catch (e) {
                                        matchingItem = null;
                                      }

                                      setState(() {
                                        selectedBahanList[i] = matchingItem;

                                        if (matchingItem == null) {
                                          _satuanControllers[i].clear();
                                        } else {
                                          changeSatuan(i);
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
                                  InputFieldWidget(
                                      key: Key('jumlah_dosis_$i'),
                                      label: labelUntukJumlah,
                                      hint: "Contoh: 10",
                                      controller: _sizeControllers[i],
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
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

                                        if (currentBahanTerpilih != null &&
                                            currentBahanTerpilih['stok'] !=
                                                null) {
                                          final double stokAwal =
                                              (currentBahanTerpilih['stok']
                                                      is double)
                                                  ? currentBahanTerpilih['stok']
                                                      as double
                                                  : double.tryParse(
                                                          currentBahanTerpilih[
                                                                  'stok']
                                                              .toString()) ??
                                                      0.0;

                                          if (stokAwal > 0) {
                                            // Hitung total penggunaan bahan yang sama di tanaman lain
                                            double totalTerpakai = 0.0;
                                            final currentBahanId =
                                                currentBahanTerpilih['id']
                                                    .toString();

                                            // Hitung penggunaan di tanaman sebelumnya
                                            for (int j = 0; j < i; j++) {
                                              if (selectedBahanList
                                                          .length >
                                                      j &&
                                                  selectedBahanList[j] !=
                                                      null &&
                                                  selectedBahanList[j]!['id']
                                                          .toString() ==
                                                      currentBahanId) {
                                                final dosisText =
                                                    _sizeControllers[j].text;
                                                final dosis = double.tryParse(
                                                        dosisText) ??
                                                    0.0;
                                                totalTerpakai += dosis;
                                              }
                                            }

                                            // Hitung penggunaan di tanaman setelahnya (jika sudah diisi)
                                            for (int j = i + 1;
                                                j < selectedBahanList.length;
                                                j++) {
                                              if (selectedBahanList[j] !=
                                                      null &&
                                                  selectedBahanList[j]!['id']
                                                          .toString() ==
                                                      currentBahanId) {
                                                final dosisText =
                                                    _sizeControllers[j].text;
                                                final dosis = double.tryParse(
                                                        dosisText) ??
                                                    0.0;
                                                totalTerpakai += dosis;
                                              }
                                            }

                                            final double totalKebutuhan =
                                                totalTerpakai + number;

                                            if (totalKebutuhan > stokAwal) {
                                              final double stokTersisa =
                                                  stokAwal - totalTerpakai;
                                              if (stokTersisa <= 0) {
                                                return 'Stok habis (Sudah terpakai: ${totalTerpakai.toStringAsFixed(1)} $satuanDisplay)';
                                              } else {
                                                return 'Total dosis melebihi stok (Sisa: ${stokTersisa.toStringAsFixed(1)} $satuanDisplay)';
                                              }
                                            }
                                          }
                                        }
                                        return null;
                                      }),
                                  InputFieldWidget(
                                      key: Key('satuan_dosis_$i'),
                                      label: "Satuan dosis",
                                      hint: "Pilih bahan untuk melihat satuan",
                                      controller: _satuanControllers[i],
                                      isDisabled: true,
                                      validator: (value) {
                                        if (selectedBahanList[i] != null &&
                                            (value == null || value.isEmpty)) {
                                          return 'Satuan tidak termuat, pilih ulang bahan.';
                                        }
                                        return null;
                                      }),
                                  ImagePickerWidget(
                                    key: Key('image_picker_$i'),
                                    label:
                                        "Unggah bukti pemberian dosis ke tanaman",
                                    image: _imageList[i],
                                    onPickImage: (pickerContext) {
                                      _pickImageDosis(context, i);
                                    },
                                  ),
                                  InputFieldWidget(
                                      key: Key('catatan_jurnal_$i'),
                                      label: "Catatan/jurnal pelaporan",
                                      hint: "Keterangan",
                                      controller: _catatanControllers[i],
                                      maxLines: 5,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Masukkan catatan';
                                        }
                                        return null;
                                      }),
                                  if (i < _objekBudidayaList.length - 1)
                                    const Divider(height: 32, thickness: 1),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _objekBudidayaList.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  onPressed: _submitForm,
                  backgroundColor: green1,
                  textStyle: semibold16.copyWith(color: white),
                  isLoading: _isLoading,
                  key: const Key('submit_pelaporan_nutrisi_tanaman_button'),
                ),
              ),
            ),
    );
  }
}
