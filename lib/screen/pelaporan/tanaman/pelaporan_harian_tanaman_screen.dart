import 'dart:async';
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

  List<String> statusPenyiraman = [];
  List<String> statusPruning = [];
  List<String> statusRepotting = [];
  List<String> statusNutrisi = [];
  List<String?> statusPemberianList = [];
  List<String> kondisiDaun = [];
  List<String> statusTumbuh = [];

  List<Map<String, dynamic>> selectedBahanList = [];
  List<Map<String, dynamic>> listBahanVitamin = [];
  List<Map<String, dynamic>> listBahanVaksin = [];
  List<Map<String, dynamic>> listBahanPupuk = [];
  List<Map<String, dynamic>> listBahanDisinfektan = [];

  bool _isLoading = false;
  File? _imageTanaman;
  File? _imageDosis;
  final picker = ImagePicker();

  final List<GlobalKey<FormState>> _formKeys = [];

  final List<TextEditingController> _heightController = [];
  final List<TextEditingController> _catatanController = [];
  final List<TextEditingController> _sizeController = [];
  final List<TextEditingController> _satuanController = [];
  final List<File?> _imageTanamanList = [];
  final List<File?> _imageDosisList = [];
  List<double> _lastHeights = [];

  final Map<String, String> statusTumbuhDisplayMap = {
    'bibit': 'Bibit',
    'perkecambahan': 'Perkecambahan',
    'vegetatifAwal': 'Vegetatif Awal',
    'vegetatifLanjut': 'Vegetatif Lanjut',
    'generatifAwal': 'Generatif Awal',
    'generatifLanjut': 'Generatif Lanjut',
    'panen': 'Panen',
    'dormansi': 'Dormansi',
  };

  final Map<String, String> kondisiDaunDisplayMap = {
    'sehat': 'Sehat',
    'kering': 'Kering',
    'layu': 'Layu',
    'kuning': 'Kuning',
    'keriting': 'Keriting',
    'bercak': 'Bercak',
    'rusak': 'Rusak',
  };

  Future<void> _fetchData() async {
    try {
      final responseVitamin =
          await _inventarisService.getInventarisByKategoriName('Vitamin');
      final responseVaksin =
          await _inventarisService.getInventarisByKategoriName('Vaksin');
      final responsePupuk =
          await _inventarisService.getInventarisByKategoriName('Pupuk');
      final responseDisinfektan =
          await _inventarisService.getInventarisByKategoriName('Disinfektan');

      if (responseVitamin['status']) {
        setState(() {
          listBahanVitamin = responseVitamin['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
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
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
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

      if (responsePupuk['status']) {
        setState(() {
          listBahanPupuk = responsePupuk['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
                  })
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error fetching vaksin data: ${responsePupuk['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (responseDisinfektan['status']) {
        setState(() {
          listBahanDisinfektan = responseDisinfektan['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
                  })
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error fetching vaksin data: ${responseDisinfektan['message']}'),
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

    // Fetch last heights
    final List<dynamic>? sourceObjekList = widget.data?['objekBudidaya'];
    for (int i = 0; i < _heightController.length; i++) {
      final objek = (sourceObjekList != null && i < sourceObjekList.length)
          ? sourceObjekList[i]
          : null;
      final String? objekId = (objek is Map && objek.containsKey('id'))
          ? objek['id'] as String?
          : null;

      if (objekId != null) {
        try {
          final responseHeight = await _laporanService
              .getLastHarianKebunByObjekBudidayaId(objekId);

          if (mounted) {
            Map<String, dynamic>? dataFromService =
                responseHeight['data'] as Map<String, dynamic>?;
            Map<String, dynamic>? harianKebunData =
                dataFromService?['HarianKebun'] as Map<String, dynamic>?;
            dynamic tinggiTanamanValue = harianKebunData?['tinggiTanaman'];

            setState(() {
              if (responseHeight['status'] == true &&
                  tinggiTanamanValue != null) {
                _lastHeights[i] = (tinggiTanamanValue as num).toDouble();
                _heightController[i].text = _lastHeights[i].toStringAsFixed(1);
              } else {
                _heightController[i].text = "0.0";
                _lastHeights[i] = 0.0;
              }
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _heightController[i].text = "0.0";
              _lastHeights[i] = 0.0;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Gagal memuat tinggi terakhir untuk ${objek?['name'] ?? 'tanaman $i'}. Error: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _heightController[i].text = "0.0";
            if (i < _lastHeights.length) _lastHeights[i] = 0.0;
          });
        }
      }
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
    int formCountToValidate = _formKeys.length;
    final List<dynamic>? objekBudidayaOriginalList =
        widget.data?['objekBudidaya'];
    print('Validating $formCountToValidate forms');
    print('Original objekBudidaya list: $objekBudidayaOriginalList');
    bool allValid = true;
    for (int i = 0; i < formCountToValidate; i++) {
      if (_formKeys[i].currentState == null ||
          !_formKeys[i].currentState!.validate()) {
        allValid = false;
      }

      if (_imageTanamanList[i] == null) {
        allValid = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Unggah bukti kondisi tanaman untuk tanaman ${i + 1}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (statusNutrisi[i] == 'Ya' && _imageDosisList[i] == null) {
        allValid = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Unggah bukti pemberian dosis untuk tanaman ${i + 1}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (!allValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      bool anyReportFailed = false;
      for (int i = 0; i < formCountToValidate; i++) {
        final currentObjek = (objekBudidayaOriginalList != null &&
                i < objekBudidayaOriginalList.length)
            ? objekBudidayaOriginalList[i]
            : null;

        print('Processing form $i for objek: $currentObjek');
        final double? tinggiTanaman =
            double.tryParse(_heightController[i].text);
        final String kondisi = kondisiDaun[i];
        final String status = statusTumbuh[i];

        final imageUrl = await _imageService.uploadImage(_imageTanamanList[i]!);
        final dataTanaman = {
          'unitBudidayaId': widget.data?['unitBudidaya']['id'],
          "objekBudidayaId": currentObjek?['id'],
          "judul":
              "Laporan Harian ${widget.data?['unitBudidaya']['name']} - ${currentObjek?['name'] ?? 'Tanaman ${i + 1}'}",
          "tipe": widget.tipe,
          "gambar": imageUrl['data'],
          "catatan": _catatanController[i].text,
          "harianKebun": {
            "penyiraman": statusPenyiraman[i] == 'Ya',
            "pruning": statusPruning[i] == 'Ya',
            "repotting": statusRepotting[i] == 'Ya',
            "tinggiTanaman": tinggiTanaman,
            "kondisiDaun": kondisi,
            "statusTumbuh": status,
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
            'objekBudidayaId': currentObjek?['id'],
            'tipe': 'vitamin',
            'judul':
                "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${(currentObjek?['name'] ?? 'Tanaman ${i + 1}')}",
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
            anyReportFailed = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Error Laporan Nutrisi (${currentObjek?['name'] ?? 'Tanaman ${i + 1}'}): ${responseDosis['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        if (!responseTanaman['status']) {
          anyReportFailed = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Error Laporan Harian (${currentObjek?['name'] ?? 'Tanaman ${i + 1}'}): ${responseTanaman['message']}'),
                backgroundColor: Colors.red));
          }
        }

        if (responseTanaman['status'] && nutrisiSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Pelaporan Harian berhasil ${currentObjek?['name'] ?? 'Tanaman ${i + 1}'} dikirim'),
              backgroundColor: Colors.green));
        }
      }

      if (!anyReportFailed && mounted) {
        // Hanya pop jika semua berhasil
        for (int k = 0; k < widget.step; k++) {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error submit: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final List<dynamic> objekBudidayaProp =
        widget.data?['objekBudidaya'] ?? [null];
    int count = objekBudidayaProp.length;
    if (objekBudidayaProp.isEmpty ||
        (objekBudidayaProp.length == 1 && objekBudidayaProp[0] == null)) {
      // Jika objekBudidaya kosong atau hanya berisi null dari default, anggap 1 form default
      count = 1;
    }

    for (int i = 0; i < count; i++) {
      _formKeys.add(GlobalKey<FormState>());
      _catatanController.add(TextEditingController());
      _sizeController.add(TextEditingController());
      _satuanController.add(TextEditingController());
      _heightController.add(TextEditingController(text: "0"));
      _imageTanamanList.add(null);
      _imageDosisList.add(null);
      selectedBahanList.add({});
      statusPemberianList.add(null);
      statusPenyiraman.add('Ya');
      statusPruning.add('Ya');
      statusRepotting.add('Ya');
      statusNutrisi.add('Ya');
      kondisiDaun.add('sehat');
      statusTumbuh.add('bibit');
      _lastHeights.add(0.0);
    }
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    int formCount = _heightController.length;
    final List<dynamic>? dataObjekBudidaya = widget.data?['objekBudidaya'];

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
              children: [
                BannerWidget(
                  title: 'Step ${widget.step} - Isi Form Pelaporan',
                  subtitle:
                      'Harap mengisi form dengan data yang benar sesuai kondisi lapangan!',
                  showDate: true,
                ),
                ...List.generate(formCount, (i) {
                  final objek = (dataObjekBudidaya != null &&
                          i < dataObjekBudidaya.length)
                      ? dataObjekBudidaya[i]
                      : null;

                  Map<String, dynamic>? currentBahanTerpilih =
                      (selectedBahanList.length > i)
                          ? selectedBahanList[i]
                          : null;

                  String labelUntukJumlah = "Jumlah/dosis";
                  String satuanDisplay = "";

                  if (currentBahanTerpilih != null &&
                      currentBahanTerpilih['stok'] != null) {
                    dynamic stokValue = currentBahanTerpilih['stok'];
                    String stokFormatted = "";

                    if (stokValue is num) {
                      stokFormatted = stokValue.toStringAsFixed(1);
                    } else {
                      stokFormatted = stokValue.toString();
                    }

                    satuanDisplay =
                        currentBahanTerpilih['satuanNama'] as String? ?? '';
                    labelUntukJumlah =
                        "Jumlah/dosis (Sisa: $stokFormatted $satuanDisplay)";
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKeys[i],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Tanaman ${(formCount > 1 || objek != null) ? (objek?['name'] ?? "Tanaman ${i + 1}") : ""}',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ((objek?['name'] != null &&
                                        (objek!['name'] as String).isNotEmpty)
                                    ? '${objek['name']} - '
                                    : (formCount == 1 && objek == null
                                        ? 'Tanaman Default - '
                                        : '')) +
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
                          Text(
                            'Tanggal dan waktu tanam: ${(() {
                              final createdAtRaw = objek?['createdAt'];
                              if (createdAtRaw == null ||
                                  createdAtRaw is! String ||
                                  createdAtRaw.isEmpty) {
                                return '-';
                              }
                              try {
                                return DateFormat('EE, dd MMMM yyyy HH:mm')
                                    .format(DateTime.parse(createdAtRaw));
                              } catch (_) {
                                return 'Unknown';
                              }
                            })()}',
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
                            label:
                                'Dilakukan pemberian pupuk/vitamin/disinfektan?',
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
                          InputFieldWidget(
                              label: "Pertumbuhan tinggi tanaman (cm)",
                              hint:
                                  "Contoh: ${_lastHeights[i].toStringAsFixed(1)} atau lebih",
                              controller: _heightController[i],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan tinggi tanaman saat ini';
                                }
                                final newHeight = double.tryParse(value);
                                if (newHeight == null) {
                                  return 'Masukkan angka yang valid';
                                }
                                if (newHeight < _lastHeights[i]) {
                                  return 'Tinggi tidak boleh kurang dari tinggi sebelumnya (${_lastHeights[i].toStringAsFixed(1)} cm)';
                                }
                                return null;
                              }),
                          DropdownFieldWidget(
                            label: "Kondisi daun",
                            hint: "Pilih kondisi daun",
                            items: kondisiDaunDisplayMap.values.toList(),
                            selectedValue:
                                kondisiDaunDisplayMap[kondisiDaun[i]],
                            onChanged: (displayValue) {
                              if (displayValue == null) return;
                              setState(() {
                                kondisiDaun[i] = kondisiDaunDisplayMap.entries
                                    .firstWhere(
                                        (entry) => entry.value == displayValue,
                                        orElse: () =>
                                            kondisiDaunDisplayMap.entries.first)
                                    .key;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih kondisi daun';
                              }
                              return null;
                            },
                          ),
                          DropdownFieldWidget(
                            label: "Status pertumbuhan tanaman",
                            hint: "Pilih status tumbuh",
                            items: statusTumbuhDisplayMap.values.toList(),
                            selectedValue:
                                statusTumbuhDisplayMap[statusTumbuh[i]],
                            onChanged: (displayValue) {
                              if (displayValue == null) return;
                              setState(() {
                                statusTumbuh[i] = statusTumbuhDisplayMap.entries
                                    .firstWhere(
                                        (entry) => entry.value == displayValue,
                                        orElse: () => statusTumbuhDisplayMap
                                            .entries.first)
                                    .key;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Pilih status tumbuh';
                              }
                              return null;
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
                              selectedValue:
                                  statusPemberianList[i] ?? 'Vitamin',
                              options: const [
                                'Vitamin',
                                'Pupuk',
                                'Vaksin',
                                'Disinfektan',
                              ],
                              onChanged: (value) {
                                setState(() {
                                  statusPemberianList[i] = value;
                                  selectedBahanList[i] = {};
                                  _satuanController[i].clear();
                                  _sizeController[i].clear();
                                });
                              },
                            ),
                            DropdownFieldWidget(
                              label: "Nama bahan",
                              hint: "Pilih jenis bahan",
                              items: (() {
                                switch (statusPemberianList[i]) {
                                  case 'Vitamin':
                                    return listBahanVitamin
                                        .map((item) => item['name'] as String)
                                        .toList()
                                        .cast<String>();
                                  case 'Pupuk':
                                    return listBahanPupuk
                                        .map((item) => item['name'] as String)
                                        .toList()
                                        .cast<String>();
                                  case 'Vaksin':
                                    return listBahanVaksin
                                        .map((item) => item['name'] as String)
                                        .toList()
                                        .cast<String>();
                                  case 'Disinfektan':
                                    return listBahanDisinfektan
                                        .map((item) => item['name'] as String)
                                        .toList()
                                        .cast<String>();
                                  default:
                                    return <String>[];
                                }
                              })(),
                              selectedValue: selectedBahanList[i]['name'] ?? '',
                              onChanged: (value) {
                                setState(() {
                                  switch (statusPemberianList[i]) {
                                    case 'Vitamin':
                                      selectedBahanList[i] =
                                          listBahanVitamin.firstWhere(
                                              (item) => item['name'] == value);
                                      break;
                                    case 'Pupuk':
                                      selectedBahanList[i] =
                                          listBahanPupuk.firstWhere(
                                              (item) => item['name'] == value);
                                      break;
                                    case 'Vaksin':
                                      selectedBahanList[i] =
                                          listBahanVaksin.firstWhere(
                                              (item) => item['name'] == value);
                                      break;
                                    case 'Disinfektan':
                                      selectedBahanList[i] =
                                          listBahanDisinfektan.firstWhere(
                                              (item) => item['name'] == value);
                                      break;
                                    default:
                                      selectedBahanList[i] = {};
                                  }
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
                                label: labelUntukJumlah,
                                hint: "Contoh: 10",
                                controller: _sizeController[i],
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
                                      currentBahanTerpilih['stok'] != null) {
                                    dynamic stokValue =
                                        currentBahanTerpilih['stok'];
                                    if (stokValue is num &&
                                        number > stokValue) {
                                      return 'Dosis melebihi stok (Sisa: ${stokValue.toStringAsFixed(1)} $satuanDisplay)';
                                    }
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
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
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
