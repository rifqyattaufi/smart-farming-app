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

class PelaporanNutrisiTernakScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanNutrisiTernakScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanNutrisiTernakScreen> createState() =>
      _PelaporanNutrisiTernakScreenState();
}

class _PelaporanNutrisiTernakScreenState
    extends State<PelaporanNutrisiTernakScreen> {
  final InventarisService _inventarisService = InventarisService();
  final ImageService _imageService = ImageService();
  final SatuanService _satuanService = SatuanService();
  final LaporanService _laporanService = LaporanService();

  List<String?> statusPemberianList = [];
  List<Map<String, dynamic>> selectedBahanList = [];

  List<Map<String, dynamic>> listBahanVitamin = [];
  List<Map<String, dynamic>> listBahanVaksin = [];

  bool isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _catatanController = [];
  List<TextEditingController> _sizeController = [];
  List<TextEditingController> _satuanController = [];
  List<File?> _imageList = [];

  Future<void> _fetchData() async {
    try {
      final responseVitamin =
          await _inventarisService.getInventarisByKategoriName('Vitamin');
      final responseVaksin =
          await _inventarisService.getInventarisByKategoriName('Vaksin');

      if (responseVitamin['status']) {
        setState(() {
          listBahanVitamin = responseVitamin['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                  })
              .toList();
        });
      } else {
        showAppToast(
          context,
          'Error fetching vitamin data: ${responseVitamin['message']}',
        );
      }

      if (responseVaksin['status']) {
        setState(() {
          listBahanVaksin = responseVaksin['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                  })
              .toList();
        });
      } else {
        showAppToast(
          context,
          'Error fetching vaksin data: ${responseVaksin['message']}',
        );
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> changeSatuan(int i) async {
    final satuanId = selectedBahanList[i]['satuanId'];
    if (satuanId != null) {
      final response = await _satuanService.getSatuanById(satuanId);
      if (response['status']) {
        setState(() {
          _satuanController[i].text =
              "${response['data']['nama']} - ${response['data']['lambang']}";
        });
      } else {
        showAppToast(
            context, 'Error fetching satuan data: ${response['message']}',
            title: 'Error Tidak Terduga 😢');
      }
    }
  }

  Future<void> _submitForm() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
    final list = (objekBudidayaList == null ||
            (objekBudidayaList is List && objekBudidayaList.isEmpty))
        ? [null]
        : objekBudidayaList;
    bool allValid = true;
    for (int i = 0; i < list.length; i++) {
      if (_formKeys[i].currentState == null ||
          !_formKeys[i].currentState!.validate()) {
        allValid = false;
      }

      if (_imageList[i] == null && allValid == true) {
        allValid = false;
        showAppToast(context,
            'Gambar bukti pemberian dosis ke ternak tidak boleh kosong');
      }
    }
    if (!allValid) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      for (int i = 0; i < list.length; i++) {
        final imageUrl = await _imageService.uploadImage(_imageList[i]!);

        final data = {
          'unitBudidayaId': widget.data?['unitBudidaya']['id'],
          'objekBudidayaId': list[i]?['id'],
          'tipe': widget.tipe,
          'judul': (list[i]?['name'] != null &&
                  (list[i]?['name'] as String).isNotEmpty)
              ? "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${list[i]?['name']}"
              : "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''}",
          'gambar': imageUrl['data'],
          'catatan': _catatanController[i].text,
          'vitamin': {
            'inventarisId': selectedBahanList[i]['id'],
            'tipe': statusPemberianList[i],
            'jumlah': double.parse(_sizeController[i].text),
          }
        };

        final response = await _laporanService.createLaporanNutrisi(data);
        if (response['status']) {
          showAppToast(
            context,
            'Laporan Pemberian Nutrisi berhasil ${(list[i]?['name'] ?? '')} dikirim',
            isError: false,
          );
        } else {
          showAppToast(context,
              response['message'] ?? 'Terjadi kesalahan tidak diketahui');
        }
      }

      for (int i = 0; i < widget.step; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImageDosis(BuildContext context, int index) async {
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
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    _imageList[index] = _image;
                  });
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
                  setState(() {
                    _image = File(pickedFile.path);
                    _imageList[index] = _image;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
    final length = objekBudidayaList.length;
    _catatanController = List.generate(
      length,
      (_) => TextEditingController(),
    );
    _sizeController = List.generate(
      length,
      (_) => TextEditingController(),
    );
    _imageList = List.generate(
      length,
      (_) => null,
    );
    _formKeys.clear();
    _formKeys.addAll(List.generate(length, (_) => GlobalKey<FormState>()));
    statusPemberianList = List.generate(length, (_) => 'Vitamin');
    selectedBahanList = List.generate(length, (_) => {});
    _satuanController = List.generate(length, (_) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
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
            title: 'Pelaporan Khusus',
            greeting: 'Pelaporan Nutrisi Ternak',
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
                  title: 'Step ${widget.step} - Isi Form Pelaporan',
                  subtitle:
                      'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
                  showDate: true,
                ),
                ...List.generate(objekBudidayaList.length, (i) {
                  final objek = objekBudidayaList[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKeys[i],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Ternak',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ((objek?['name'] != null &&
                                        (objek?['name'] as String).isNotEmpty)
                                    ? '${objek?['name']} - '
                                    : '') +
                                (widget.data?['unitBudidaya']?['category'] ??
                                    '-'),
                            style: bold20.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.data?['unitBudidaya']['latin']} - ${widget.data?['unitBudidaya']['name']}',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          RadioField(
                            key: Key('status_pemberian_$i'),
                            label: 'Jenis Pemberian',
                            selectedValue: statusPemberianList[i] ?? 'Vitamin',
                            options: const [
                              'Vitamin',
                              'Vaksin',
                            ],
                            onChanged: (value) {
                              setState(() {
                                statusPemberianList[i] = value;
                                selectedBahanList[i] = {};
                                _satuanController[i].clear();
                              });
                            },
                          ),
                          DropdownFieldWidget(
                            key: Key('bahan_pemberian_$i'),
                            label: "Nama bahan",
                            hint: "Pilih jenis bahan",
                            items: (statusPemberianList[i] == 'Vitamin'
                                    ? listBahanVitamin
                                    : listBahanVaksin)
                                .map((item) => item['name'] as String)
                                .toList(),
                            selectedValue: selectedBahanList[i]['name'] ?? '',
                            onChanged: (value) {
                              setState(() {
                                selectedBahanList[i] =
                                    (statusPemberianList[i] == 'Vitamin'
                                            ? listBahanVitamin
                                            : listBahanVaksin)
                                        .firstWhere(
                                            (item) => item['name'] == value);
                              });
                              changeSatuan(i);
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
                              label: "Jumlah/dosis",
                              hint: "Contoh: 10.5",
                              controller: _sizeController[i],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan jumlah/dosis';
                                } else if (double.tryParse(value) == null) {
                                  return 'Masukkan angka yang valid';
                                } else if (double.parse(value) <= 0) {
                                  return 'Jumlah/dosis harus lebih dari 0';
                                }
                                return null;
                              }),
                          InputFieldWidget(
                            key: Key('satuan_dosis_$i'),
                            label: "Satuan dosis",
                            hint: "",
                            controller: _satuanController[i],
                            isDisabled: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih satuan dosis';
                              }
                              return null;
                            },
                          ),
                          ImagePickerWidget(
                            key: Key('image_picker_$i'),
                            label: "Unggah bukti pemberian dosis ke ternak",
                            image: _imageList[i],
                            onPickImage: (ctx) {
                              _pickImageDosis(context, i);
                            },
                          ),
                          InputFieldWidget(
                              key: Key('catatan_$i'),
                              label: "Catatan/jurnal pelaporan",
                              hint: "Keterangan",
                              controller: _catatanController[i],
                              maxLines: 10,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan catatan';
                                }
                                return null;
                              }),
                          const Divider()
                        ],
                      ),
                    ),
                  );
                }),
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
            isLoading: isLoading,
            key: const Key('submit_button_pelaporan_nutrisi_ternak'),
          ),
        ),
      ),
    );
  }
}
