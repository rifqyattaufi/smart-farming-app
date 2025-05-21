import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/radio_field.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanHarianTanamanScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanHarianTanamanScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanHarianTanamanScreen> createState() =>
      _PelaporanHarianTanamanScreenState();
}

class _PelaporanHarianTanamanScreenState
    extends State<PelaporanHarianTanamanScreen> {
  final InventarisService _inventarisService = InventarisService();
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();
  final SatuanService _satuanService = SatuanService();

  List<String?> statusPemberianList = [];
  List<Map<String, dynamic>> selectedBahanList = [];

  List<Map<String, dynamic>> listBahanVitamin = [];
  List<Map<String, dynamic>> listBahanVaksin = [];

  bool _isLoading = false;
  File? _imageTanaman;
  File? _imageDosis;
  final picker = ImagePicker();
  List<String> statusPenyiraman = [];
  List<String> statusPruning = [];
  List<String> statusRepotting = [];
  List<String> statusNutrisi = [];

  final List<GlobalKey<FormState>> _formKeys = [];

  final List<TextEditingController> _catatanController = [];
  final List<TextEditingController> _sizeController = [];
  final List<TextEditingController> _satuanController = [];
  final List<File?> _imageTanamanList = [];
  final List<File?> _imageDosisList = [];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error fetching vitamin data: ${responseVitamin['message']}'),
            backgroundColor: Colors.red,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error fetching vaksin data: ${responseVaksin['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage(BuildContext context, int index) async {
    _imageTanaman = null;
    await showModalBottomSheet(
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
                    _imageTanaman = File(pickedFile.path);
                    _imageTanamanList[index] = _imageTanaman;
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
                    _imageTanaman = File(pickedFile.path);
                    _imageTanamanList[index] = _imageTanaman;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
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
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _imageDosis = File(pickedFile.path);
                    _imageDosisList[index] = _imageDosis;
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
                    _imageDosis = File(pickedFile.path);
                    _imageDosisList[index] = _imageDosis;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching satuan data: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
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

      if (_imageTanamanList[i] == null && allValid == true) {
        allValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unggah bukti pelaporan harian tanaman'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Hanya cek gambar dosis jika statusNutrisi[i] == 'Ya'
      if (statusNutrisi[i] == 'Ya' &&
          _imageDosisList[i] == null &&
          allValid == true) {
        allValid = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unggah bukti pemberian dosis ke tanaman'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    if (!allValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      for (int i = 0; i < list.length; i++) {
        final imageUrl = await _imageService.uploadImage(_imageTanamanList[i]!);

        final dataTanaman = {
          'unitBudidayaId': widget.data?['unitBudidaya']['id'],
          "judul":
              "Laporan Harian ${widget.data?['unitBudidaya']['name']} - ${list[i]['name']}",
          "tipe": widget.tipe,
          "gambar": imageUrl['data'],
          "catatan": _catatanController[i].text,
          "harianKebun": {
            "penyiraman": statusPenyiraman[i] == 'Ya',
            "pruning": statusPruning[i] == 'Ya',
            "repotting": statusRepotting[i] == 'Ya',
          }
        };
        final responseTanaman =
            await _laporanService.createLaporanHarianKebun(dataTanaman);

        bool nutrisiSuccess = true;
        if (statusNutrisi[i] == 'Ya') {
          final imageDosisUrl =
              await _imageService.uploadImage(_imageDosisList[i]!);

          final dataDosis = {
            'unitBudidayaId': widget.data?['unitBudidaya']['id'],
            'objekBudidayaId': list[i]['id'],
            'tipe': widget.tipe,
            'judul':
                "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${(list[i]?['name'] ?? '')}",
            'gambar': imageDosisUrl['data'],
            'catatan': _catatanController[i].text,
            'vitamin': {
              'inventarisId': selectedBahanList[i]['id'],
              'tipe': statusPemberianList[i],
              'jumlah': double.parse(_sizeController[i].text),
            }
          };

          final responseDosis =
              await _laporanService.createLaporanNutrisi(dataDosis);

          nutrisiSuccess = responseDosis['status'];
          if (!nutrisiSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${responseDosis['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        if (responseTanaman['status'] && nutrisiSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Pelaporan Harian berhasil ${list[i]['name']} dikirim'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (!responseTanaman['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${responseTanaman['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      for (int i = 0; i < widget.step; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
    // final objekBudidayaList = (widget.data?['objekBudidaya'] as List<dynamic>?) ?? [];

    for (int i = 0; i < objekBudidayaList.length; i++) {
      _formKeys.add(GlobalKey<FormState>());
      _catatanController.add(TextEditingController());
      _sizeController.add(TextEditingController());
      _satuanController.add(TextEditingController());
      _imageTanamanList.add(null);
      _imageDosisList.add(null);
      selectedBahanList.add({});
      statusPemberianList.add(null);
      statusPenyiraman.add('Ya');
      statusPruning.add('Ya');
      statusRepotting.add('Ya');
      statusNutrisi.add('Ya');
    }
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [];
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
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            BannerWidget(
              title: 'Step ${widget.step} - Isi Form Pelaporan',
              subtitle:
                  'Harap mengisi form dengan data yang benar sesuai kondisi lapangan!',
              showDate: true,
            ),
            ...List.generate(objekBudidayaList.length, (i) {
              final objek = objekBudidayaList[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Tanaman',
                      style: semibold16.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ((objek?['name'] != null &&
                                  (objek?['name'] as String).isNotEmpty)
                              ? '${objek?['name']} - '
                              : '') +
                          (widget.data?['unitBudidaya']?['category'] ?? '-'),
                      style: bold20.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.data?['unitBudidaya']['latin']} - ${widget.data?['unitBudidaya']['name']}',
                      style: semibold16.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tanggal dan waktu tanam: ',
                      style: regular14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy HH:mm')
                          .format(DateTime.now()),
                      style: regular14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 12),
                    RadioField(
                      label: 'Dilakukan penyiraman?',
                      selectedValue: statusPenyiraman[i],
                      options: const ['Ya', 'Tidak'],
                      onChanged: (value) {
                        setState(() {
                          statusPenyiraman[i] = value;
                        });
                      },
                    ),
                    RadioField(
                      label: 'Dilakukan pruning?',
                      selectedValue: statusPruning[i],
                      options: const ['Ya', 'Tidak'],
                      onChanged: (value) {
                        setState(() {
                          statusPruning[i] = value;
                        });
                      },
                    ),
                    RadioField(
                      label: 'Dilakukan pemberian pupuk/vitamin/disinfektan?',
                      selectedValue: statusNutrisi[i],
                      options: const ['Ya', 'Tidak'],
                      onChanged: (value) {
                        setState(() {
                          statusNutrisi[i] = value;
                        });
                      },
                    ),
                    RadioField(
                      label:
                          'Dilakukan repotting (pemindahan pot/mengganti media tanam)?',
                      selectedValue: statusRepotting[i],
                      options: const ['Ya', 'Tidak'],
                      onChanged: (value) {
                        setState(() {
                          statusRepotting[i] = value;
                        });
                      },
                    ),
                    ImagePickerWidget(
                      label: "Unggah bukti kondisi tanaman",
                      image: _imageTanamanList[i],
                      onPickImage: (ctx) {
                        _pickImage(context, i);
                      },
                    ),
                    InputFieldWidget(
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
                    if (statusNutrisi[i] == 'Ya') ...[
                      RadioField(
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
                            selectedBahanList[i] = (statusPemberianList[i] ==
                                        'Vitamin'
                                    ? listBahanVitamin
                                    : listBahanVaksin)
                                .firstWhere((item) => item['name'] == value);
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
                          label: "Jumlah/dosis",
                          hint: "Contoh: 10",
                          controller: _sizeController[i],
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan jumlah/dosis';
                            } else if (double.tryParse(value) == null) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          }),
                      InputFieldWidget(
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
                        label: "Unggah bukti pemberian dosis ke tanaman",
                        image: _imageDosisList[i],
                        onPickImage: (ctx) {
                          _pickImageDosis(context, i);
                        },
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
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
