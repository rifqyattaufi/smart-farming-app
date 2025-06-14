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
  List<Map<String, dynamic>> listBahanPupuk = [];
  List<Map<String, dynamic>> listBahanDisinfektan = [];

  bool _isLoading = false;
  final picker = ImagePicker();

  List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _heightController = [];
  List<TextEditingController> _catatanController = [];
  List<TextEditingController> _sizeController = [];
  List<TextEditingController> _satuanController = [];
  List<File?> _imageTanamanList = [];
  List<File?> _imageDosisList = [];
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
                Text('Error fetching pupuk data: ${responsePupuk['message']}'),
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
                'Error fetching disinfektan data: ${responseDisinfektan['message']}'),
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
    try {
      // 1. Siapkan semua future untuk mengambil tinggi tanaman
      final List<Future<Map<String, dynamic>>> heightFutures = [];
      final List<dynamic>? sourceObjekList = widget.data?['objekBudidaya'];

      for (int i = 0; i < _heightController.length; i++) {
        final objek = (sourceObjekList != null && i < sourceObjekList.length)
            ? sourceObjekList[i]
            : null;
        final String? objekId = (objek is Map && objek.containsKey('id'))
            ? objek['id'] as String?
            : null;

        if (objekId != null) {
          heightFutures.add(
              _laporanService.getLastHarianKebunByObjekBudidayaId(objekId));
        } else {
          // Jika tidak ada ID, buat future palsu yang langsung selesai
          heightFutures.add(Future.value({'status': false, 'data': null}));
        }
      }

      // 2. Jalankan semua future secara paralel
      final List<Map<String, dynamic>> heightResults =
          await Future.wait(heightFutures);

      // 3. Panggil setState HANYA SEKALI setelah semua data siap
      if (mounted) {
        setState(() {
          for (int i = 0; i < heightResults.length; i++) {
            final responseHeight = heightResults[i];
            Map<String, dynamic>? dataFromService =
                responseHeight['data'] as Map<String, dynamic>?;
            Map<String, dynamic>? harianKebunData =
                dataFromService?['HarianKebun'] as Map<String, dynamic>?;
            dynamic tinggiTanamanValue = harianKebunData?['tinggiTanaman'];

            if (responseHeight['status'] == true &&
                tinggiTanamanValue != null) {
              _lastHeights[i] = (tinggiTanamanValue as num).toDouble();
              _heightController[i].text = _lastHeights[i].toStringAsFixed(1);
            } else {
              _heightController[i].text = "0.0";
              _lastHeights[i] = 0.0;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching last heights: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(BuildContext context, int index) async {
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
                    _imageTanamanList[index] = File(pickedFile.path);
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
                    _imageTanamanList[index] = File(pickedFile.path);
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
                    _imageDosisList[index] = File(pickedFile.path);
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
                    _imageDosisList[index] = File(pickedFile.path);
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
    bool allValid = true;
    for (int i = 0; i < formCountToValidate; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? false)) {
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Harap periksa kembali semua isian form.'),
        backgroundColor: Colors.red,
      ));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final List<Future<bool>> submissionFutures = [];
      final List<dynamic>? objekBudidayaOriginalList =
          widget.data?['objekBudidaya'];

      for (int i = 0; i < formCountToValidate; i++) {
        // final stopwatch = Stopwatch()..start();
        final future = () async {
          try {
            final currentObjek = (objekBudidayaOriginalList != null &&
                    i < objekBudidayaOriginalList.length)
                ? objekBudidayaOriginalList[i]
                : null;

            // print('SUBMIT($i): Mengunggah gambar tanaman...');
            final imageUrlResponse =
                await _imageService.uploadImage(_imageTanamanList[i]!);
            // print(
            //     'SUBMIT($i): Upload gambar tanaman selesai dalam ${stopwatch.elapsedMilliseconds}ms');
            // stopwatch.reset();
            if (!imageUrlResponse['status']) {
              return false;
            }

            // print('SUBMIT($i): Mengirim laporan harian...');
            // stopwatch.start();
            final double? tinggiTanaman =
                double.tryParse(_heightController[i].text);
            final String kondisi = kondisiDaun[i];
            final String status = statusTumbuh[i];

            final dataTanaman = {
              'unitBudidayaId': widget.data?['unitBudidaya']['id'],
              "objekBudidayaId": currentObjek?['id'],
              "judul":
                  "Laporan Harian ${widget.data?['unitBudidaya']['name']} - ${currentObjek?['name'] ?? 'Tanaman ${i + 1}'}",
              "tipe": widget.tipe,
              "gambar": imageUrlResponse['data'],
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
            // print(
            //     'SUBMIT($i): Kirim laporan harian selesai dalam ${stopwatch.elapsedMilliseconds}ms');
            // stopwatch.reset();
            if (!responseTanaman['status']) {
              return false;
            }

            if (statusNutrisi[i] == 'Ya') {
              // print('SUBMIT($i): Mengunggah gambar dosis...');
              // stopwatch.start();
              final imageDosisUrlResponse =
                  await _imageService.uploadImage(_imageDosisList[i]!);
              // print(
              //     'SUBMIT($i): Upload gambar dosis selesai dalam ${stopwatch.elapsedMilliseconds}ms');
              // stopwatch.reset();
              if (!imageDosisUrlResponse['status']) return false;

              // print('SUBMIT($i): Mengirim laporan nutrisi...');
              // stopwatch.start();
              final dataDosis = {
                'unitBudidayaId': widget.data?['unitBudidaya']['id'],
                'objekBudidayaId': currentObjek?['id'],
                'tipe': 'vitamin',
                'judul':
                    "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${(currentObjek?['name'] ?? 'Tanaman ${i + 1}')}",
                'gambar': imageDosisUrlResponse['data'],
                'catatan': _catatanController[i].text,
                'vitamin': {
                  'inventarisId': selectedBahanList[i]['id'],
                  'tipe': statusPemberianList[i],
                  'jumlah': double.parse(_sizeController[i].text),
                }
              };

              final responseDosis =
                  await _laporanService.createLaporanNutrisi(dataDosis);
              // print(
              //     'SUBMIT($i): Kirim laporan nutrisi selesai dalam ${stopwatch.elapsedMilliseconds}ms');
              // stopwatch.reset();
              if (!responseDosis['status']) {
                return false;
              }
            }

            return true;
          } catch (e) {
            return false;
          }
        }();
        submissionFutures.add(future);
      }

      final List<bool> results = await Future.wait(submissionFutures);

      final bool anyReportFailed = results.contains(false);

      if (mounted) {
        if (anyReportFailed) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Beberapa laporan gagal dikirim. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Semua laporan berhasil dikirim!'),
            backgroundColor: Colors.green,
          ));
          for (int k = 0; k < widget.step; k++) {
            if (Navigator.canPop(context)) Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan besar saat submit: $e'),
              backgroundColor: Colors.red),
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
      count = 1;
    }

    _formKeys = List.generate(count, (_) => GlobalKey<FormState>());
    _catatanController = List.generate(count, (_) => TextEditingController());
    _sizeController = List.generate(count, (_) => TextEditingController());
    _satuanController = List.generate(count, (_) => TextEditingController());
    _heightController =
        List.generate(count, (_) => TextEditingController(text: "0"));
    _imageTanamanList = List.generate(count, (_) => null);
    _imageDosisList = List.generate(count, (_) => null);
    selectedBahanList = List.generate(count, (_) => <String, dynamic>{});
    statusPemberianList = List.generate(count, (_) => 'Pupuk');
    statusPenyiraman = List.generate(count, (_) => 'Ya');
    statusPruning = List.generate(count, (_) => 'Ya');
    statusRepotting = List.generate(count, (_) => 'Ya');
    statusNutrisi = List.generate(count, (_) => 'Ya');
    kondisiDaun = List.generate(count, (_) => 'sehat');
    statusTumbuh = List.generate(count, (_) => 'bibit');
    _lastHeights = List.generate(count, (_) => 0.0);

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
                              selectedValue: statusPemberianList[i] ?? 'Pupuk',
                              options: const [
                                'Pupuk',
                                'Vitamin',
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
                                  case 'Disinfektan':
                                    return listBahanDisinfektan
                                        .map((item) => item['name'] as String)
                                        .toList()
                                        .cast<String>();
                                  default:
                                    return <String>[];
                                }
                              })(),
                              selectedValue:
                                  selectedBahanList[i]['name'] as String?,
                              onChanged: (value) {
                                if (value == null) return;

                                Map<String, dynamic> findBahan(
                                    List<Map<String, dynamic>> list) {
                                  return list.firstWhere(
                                    (item) => item['name'] == value,
                                    orElse: () => <String, dynamic>{},
                                  );
                                }

                                setState(() {
                                  Map<String, dynamic> bahanTerpilih = {};
                                  switch (statusPemberianList[i]) {
                                    case 'Vitamin':
                                      bahanTerpilih =
                                          findBahan(listBahanVitamin);
                                      break;
                                    case 'Pupuk':
                                      bahanTerpilih = findBahan(listBahanPupuk);
                                      break;
                                    case 'Disinfektan':
                                      bahanTerpilih =
                                          findBahan(listBahanDisinfektan);
                                      break;
                                  }
                                  selectedBahanList[i] = bahanTerpilih;

                                  if (bahanTerpilih.isNotEmpty) {
                                    changeSatuan(i);
                                  } else {
                                    _satuanController[i].clear();
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            onPressed: _submitForm,
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
