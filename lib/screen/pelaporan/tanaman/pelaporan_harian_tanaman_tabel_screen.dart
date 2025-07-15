import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tindakan_massal_screen.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanHarianTanamanTabelScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanHarianTanamanTabelScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanHarianTanamanTabelScreen> createState() =>
      _PelaporanHarianTanamanTabelScreenState();
}

class _PelaporanHarianTanamanTabelScreenState
    extends State<PelaporanHarianTanamanTabelScreen> {
  final ImageService _imageService = ImageService();
  final LaporanService _laporanService = LaporanService();

  List<String> kondisiDaun = [];
  List<String> statusTumbuh = [];

  // Untuk melacak nilai awal yang diambil dari laporan terakhir
  List<String> _initialKondisiDaun = [];
  List<String> _initialStatusTumbuh = [];

  bool _isLoading = false;
  final picker = ImagePicker();

  List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _heightController = [];
  List<TextEditingController> _catatanController = [];
  List<File?> _imageTanamanList = [];
  List<File?> _imageDosisList = [];
  List<double> _lastHeights = [];

  final Map<String, String> statusTumbuhDisplayMap = {
    'bibit': 'Bibit',
    'perkecambahan': 'Perkecambahan',
    'vegetatifAwal': 'Vegetatif Awal - Pertumbuhan Daun & Batang',
    'vegetatifLanjut': 'Vegetatif Lanjut - Siap Berbunga',
    'generatifAwal': 'Generatif Awal - Pembentukan Bunga',
    'generatifLanjut': 'Generatif Lanjut - Pembentukan Buah',
    'panen': 'Panen - Pematangan Buah',
    'dormansi': 'Dormansi - Fase Istirahat Tanaman',
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
    // Fetch last heights
    try {
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
          heightFutures.add(Future.value({'status': false, 'data': null}));
        }
      }

      final List<Map<String, dynamic>> heightResults =
          await Future.wait(heightFutures);

      if (mounted) {
        setState(() {
          for (int i = 0; i < heightResults.length; i++) {
            final responseHeight = heightResults[i];
            Map<String, dynamic>? dataFromService =
                responseHeight['data'] as Map<String, dynamic>?;
            Map<String, dynamic>? harianKebunData =
                dataFromService?['HarianKebun'] as Map<String, dynamic>?;

            // Ambil tinggi tanaman
            dynamic tinggiTanamanValue = harianKebunData?['tinggiTanaman'];
            if (responseHeight['status'] == true &&
                tinggiTanamanValue != null) {
              _lastHeights[i] = (tinggiTanamanValue as num).toDouble();
              _heightController[i].text = _lastHeights[i].toStringAsFixed(1);
            } else {
              _heightController[i].text = "0.0";
              _lastHeights[i] = 0.0;
            }

            // Ambil kondisi daun dari laporan terakhir
            dynamic kondisiDaunValue = harianKebunData?['kondisiDaun'];
            if (responseHeight['status'] == true &&
                kondisiDaunValue != null &&
                kondisiDaunDisplayMap.containsKey(kondisiDaunValue)) {
              kondisiDaun[i] = kondisiDaunValue;
              _initialKondisiDaun[i] = kondisiDaunValue;
            }

            // Ambil status tumbuh dari laporan terakhir
            dynamic statusTumbuhValue = harianKebunData?['statusTumbuh'];
            if (responseHeight['status'] == true &&
                statusTumbuhValue != null &&
                statusTumbuhDisplayMap.containsKey(statusTumbuhValue)) {
              statusTumbuh[i] = statusTumbuhValue;
              _initialStatusTumbuh[i] = statusTumbuhValue;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
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
              key: Key('camera_$index'),
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
              key: Key('gallery_$index'),
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
              key: Key('camera_dosis_$index'),
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
              key: Key('gallery_dosis_$index'),
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

  Future<void> _editTindakanMassal() async {
    // Kembali ke screen tindakan massal dengan data yang sudah ada
    final dataWithoutTindakanMassal =
        Map<String, dynamic>.from(widget.data ?? {});
    dataWithoutTindakanMassal.remove('tindakanMassal');

    final result = await context.push('/pelaporan-tindakan-massal',
        extra: PelaporanTindakanMassalScreen(
          greeting: widget.greeting,
          data: dataWithoutTindakanMassal,
          tipe: widget.tipe,
          step: widget.step - 1,
        ));

    // Jika ada perubahan, update state
    if (result != null && mounted) {
      setState(() {});
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    int formCountToValidate = _formKeys.length;
    bool allValid = true;
    List<bool> hasDataPerTanaman = List.filled(formCountToValidate, false);

    // Check which plants have data filled
    for (int i = 0; i < formCountToValidate; i++) {
      bool hasData = false;

      // Check if any field is filled (made more flexible)
      if (_heightController[i].text.isNotEmpty &&
          _heightController[i].text != "0.0" &&
          _heightController[i].text != "0") {
        hasData = true;
      }
      if (_catatanController[i].text.isNotEmpty) {
        hasData = true;
      }
      if (_imageTanamanList[i] != null) {
        hasData = true;
      }

      final Map<String, dynamic>? tindakanMassal =
          widget.data?['tindakanMassal'];
      final bool isNutrisiEnabled = tindakanMassal?['nutrisi'] ?? false;
      if (isNutrisiEnabled && _imageDosisList[i] != null) {
        hasData = true;
      }

      // Note: Untuk nutrisi massal, foto dosis individual tidak wajib
      // Nutrisi massal akan tetap diproses meskipun tidak ada foto dosis individual

      // Only count condition or growth status changes if they are different from the ones loaded from the last report
      // (tracked through the _initialKondisiDaun and _initialStatusTumbuh arrays)
      if (kondisiDaun[i] != _initialKondisiDaun[i]) {
        hasData = true;
      }
      if (statusTumbuh[i] != _initialStatusTumbuh[i]) {
        hasData = true;
      }

      hasDataPerTanaman[i] = hasData;

      // Only validate if user has started filling data for this plant
      if (hasData) {
        if (!(_formKeys[i].currentState?.validate() ?? false)) {
          allValid = false;
        }

        // Optional validation: All images are now optional
        // No mandatory image requirements - users can submit reports with or without photos
      }
    }

    // Check if at least one plant has data OR if this is just mass actions
    bool hasAnyData = hasDataPerTanaman.contains(true);
    final Map<String, dynamic>? tindakanMassal = widget.data?['tindakanMassal'];
    bool hasMassActions = (tindakanMassal?['penyiraman'] == true) ||
        (tindakanMassal?['pruning'] == true) ||
        (tindakanMassal?['nutrisi'] == true) ||
        (tindakanMassal?['repotting'] == true);

    if (!hasAnyData && !hasMassActions) {
      showAppToast(
        context,
        'Pilih minimal satu tindakan massal atau isi data individual tanaman. Anda bisa mengirim laporan tanpa data individual jika hanya melakukan tindakan massal.',
        isError: true,
      );
      setState(() => _isLoading = false);
      return;
    }

    if (!allValid) {
      showAppToast(
        context,
        'Harap perbaiki semua kesalahan pada data yang sudah diisi',
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final List<Future<bool>> submissionFutures = [];
      final List<dynamic>? objekBudidayaOriginalList =
          widget.data?['objekBudidaya'];
      final Map<String, dynamic>? tindakanMassal =
          widget.data?['tindakanMassal'];
      final bool hasMassActions = (tindakanMassal?['penyiraman'] == true) ||
          (tindakanMassal?['pruning'] == true) ||
          (tindakanMassal?['nutrisi'] == true) ||
          (tindakanMassal?['repotting'] == true);

      int processedCount = 0;

      // Jika tidak ada data individual tapi ada tindakan massal, kirim laporan untuk SEMUA tanaman
      // karena tindakan massal berlaku untuk semua tanaman
      bool needToSubmitMassActionOnly =
          !hasDataPerTanaman.contains(true) && hasMassActions;

      // OPTIMASI: Upload foto kondisi tanaman hanya sekali jika diperlukan
      String? sharedKondisiHarianUrl;
      final File? imageKondisiHarian =
          tindakanMassal?['imageKondisiHarian'] as File?;

      // Cek apakah ada tanaman yang akan menggunakan foto kondisi harian kebun
      bool needsSharedImage = false;
      for (int i = 0; i < formCountToValidate; i++) {
        if ((hasDataPerTanaman[i] || needToSubmitMassActionOnly) &&
            _imageTanamanList[i] == null &&
            imageKondisiHarian != null) {
          needsSharedImage = true;
          break;
        }
      }

      // Upload foto kondisi harian kebun sekali saja jika diperlukan
      if (needsSharedImage) {
        final imageUrlResponse =
            await _imageService.uploadImage(imageKondisiHarian!);
        if (!imageUrlResponse['status']) {
          if (mounted) {
            showAppToast(context, 'Gagal mengupload foto kondisi tanaman');
            setState(() => _isLoading = false);
          }
          return;
        }
        sharedKondisiHarianUrl = imageUrlResponse['data'];
      }

      for (int i = 0; i < formCountToValidate; i++) {
        // Proses tanaman jika memiliki data individual ATAU jika perlu mengirim tindakan massal
        // (tindakan massal berlaku untuk SEMUA tanaman, bukan hanya tanaman pertama)
        if (!hasDataPerTanaman[i] && !needToSubmitMassActionOnly) {
          continue;
        }

        processedCount++;

        final future = () async {
          try {
            final currentObjek = (objekBudidayaOriginalList != null &&
                    i < objekBudidayaOriginalList.length)
                ? objekBudidayaOriginalList[i]
                : null;

            // Upload gambar tanaman (priority: individual image -> shared kondisi harian -> placeholder)
            String imageUrl;
            if (_imageTanamanList[i] != null) {
              // Upload gambar individual jika ada
              final imageUrlResponse =
                  await _imageService.uploadImage(_imageTanamanList[i]!);
              if (!imageUrlResponse['status']) {
                return false;
              }
              imageUrl = imageUrlResponse['data'];
            } else if (sharedKondisiHarianUrl != null) {
              // Gunakan URL foto kondisi harian yang sudah diupload
              imageUrl = sharedKondisiHarianUrl;
            } else {
              // Gunakan gambar kebun/unit budidaya sebagai fallback
              final String? kebunImageUrl =
                  widget.data?['unitBudidaya']?['image'];
              if (kebunImageUrl != null && kebunImageUrl.isNotEmpty) {
                imageUrl = kebunImageUrl;
              } else {
                // Gunakan placeholder hanya jika gambar kebun juga tidak ada
                imageUrl =
                    "https://res.cloudinary.com/do4mvm3ta/image/upload/v1749373032/axclv6ilcevzf9jazfk3.webp";
              }
            }

            // Submit laporan harian
            double? tinggiTanaman;
            if (_heightController[i].text.isNotEmpty) {
              tinggiTanaman = double.tryParse(_heightController[i].text);
            }
            final String kondisi = kondisiDaun[i];
            final String status = statusTumbuh[i];

            final dataTanaman = {
              'unitBudidayaId': widget.data?['unitBudidaya']['id'],
              "objekBudidayaId": currentObjek?['id'],
              "judul":
                  "Laporan Harian ${widget.data?['unitBudidaya']['name']} - ${currentObjek?['name'] ?? 'Tanaman ${i + 1}'}",
              "tipe": widget.tipe,
              "gambar": imageUrl,
              "catatan": _catatanController[i].text.isEmpty
                  ? "Laporan tindakan massal"
                  : _catatanController[i].text,
              "harianKebun": {
                // Tindakan massal: Selalu kirim
                "penyiraman": tindakanMassal?['penyiraman'] ?? false,
                "pruning": tindakanMassal?['pruning'] ?? false,
                "repotting": tindakanMassal?['repotting'] ?? false,

                // Data individual: Kirim data baru jika ada perubahan, atau data terakhir jika tidak ada perubahan
                "tinggiTanaman": hasDataPerTanaman[i]
                    ? tinggiTanaman
                    : (_lastHeights[i] > 0 ? _lastHeights[i] : null),
                "kondisiDaun": hasDataPerTanaman[i] ? kondisi : kondisiDaun[i],
                "statusTumbuh": hasDataPerTanaman[i] ? status : statusTumbuh[i],
              }
            };

            final responseTanaman =
                await _laporanService.createLaporanHarianKebun(dataTanaman);
            if (!responseTanaman['status']) {
              return false;
            }

            // Submit laporan nutrisi jika diperlukan
            if (tindakanMassal?['nutrisi'] == true) {
              String? imageDosisUrl;

              // Priority untuk foto dosis: individual image -> shared kondisi harian -> kebun image -> placeholder
              if (_imageDosisList[i] != null) {
                // Upload foto dosis individual jika ada
                final imageDosisUrlResponse =
                    await _imageService.uploadImage(_imageDosisList[i]!);
                if (!imageDosisUrlResponse['status']) return false;
                imageDosisUrl = imageDosisUrlResponse['data'];
              } else if (sharedKondisiHarianUrl != null) {
                // Gunakan foto kondisi harian yang sudah diupload
                imageDosisUrl = sharedKondisiHarianUrl;
              } else {
                // Gunakan foto yang sama dengan laporan harian (imageUrl yang sudah disiapkan di atas)
                imageDosisUrl = imageUrl;
              }

              // Ambil data nutrisi massal
              final Map<String, dynamic>? nutrisiData =
                  tindakanMassal?['nutrisiData'];

              final dataDosis = {
                'unitBudidayaId': widget.data?['unitBudidaya']['id'],
                'objekBudidayaId': currentObjek?['id'],
                'tipe': 'vitamin',
                'judul':
                    "Laporan Pemberian Nutrisi ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${(currentObjek?['name'] ?? 'Tanaman ${i + 1}')}",
                'gambar': imageDosisUrl,
                'catatan': _catatanController[i].text.isEmpty
                    ? "Pemberian nutrisi massal"
                    : _catatanController[i].text,
                'vitamin': {
                  'inventarisId': nutrisiData?['bahan']?['id'],
                  'tipe': nutrisiData?['jenisPemberian'],
                  'jumlah': nutrisiData?['jumlahDosis'] ?? 0.0,
                }
              };

              final responseDosis =
                  await _laporanService.createLaporanNutrisi(dataDosis);
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
          showAppToast(
              context, 'Beberapa laporan gagal dikirim. Silakan coba lagi.');
        } else {
          String message = needToSubmitMassActionOnly
              ? 'Laporan tindakan massal berhasil dicatat untuk $processedCount tanaman.'
              : 'Laporan berhasil dikirim untuk $processedCount tanaman.';
          showAppToast(
            context,
            message,
            isError: false,
          );
          for (int k = 0; k < widget.step; k++) {
            if (Navigator.canPop(context)) Navigator.pop(context);
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
    _heightController =
        List.generate(count, (_) => TextEditingController(text: "0"));
    _imageTanamanList = List.generate(count, (_) => null);
    kondisiDaun = List.generate(count, (_) => 'sehat');
    statusTumbuh = List.generate(count, (_) => 'bibit');
    _lastHeights = List.generate(count, (_) => 0.0);

    // Inisialisasi nilai awal untuk kondisi daun dan status tumbuh
    _initialKondisiDaun = List.generate(count, (_) => 'sehat');
    _initialStatusTumbuh = List.generate(count, (_) => 'bibit');

    // Inisialisasi image dosis jika nutrisi diaktifkan
    final Map<String, dynamic>? tindakanMassal = widget.data?['tindakanMassal'];
    final bool isNutrisiEnabled = tindakanMassal?['nutrisi'] ?? false;
    if (isNutrisiEnabled) {
      _imageDosisList = List.generate(count, (_) => null);
    }

    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    int formCount = _heightController.length;
    final List<dynamic>? dataObjekBudidaya = widget.data?['objekBudidaya'];
    final Map<String, dynamic>? tindakanMassal = widget.data?['tindakanMassal'];
    final bool isNutrisiEnabled = tindakanMassal?['nutrisi'] ?? false;

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
            title: 'Menu Pelaporan',
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
                  title:
                      'Step ${widget.step} - Input Data Individual (Opsional)',
                  subtitle:
                      'Isi data spesifik untuk setiap tanaman jika perlu. Jika hanya tindakan massal, anda bisa langsung klik "Simpan Laporan".',
                  showDate: true,
                ),

                // Ringkasan tindakan massal
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.green.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Tindakan Massal yang Dipilih',
                                  style: semibold14.copyWith(
                                      color: Colors.green.shade700),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _editTindakanMassal,
                              icon: Icon(Icons.edit, size: 16, color: green1),
                              label: Text(
                                'Edit',
                                style: semibold12.copyWith(color: green1),
                              ),
                              key: const Key('edit_tindakan_massal_button'),
                            ),
                          ],
                        ),
                        Text(
                          'Penyiraman: ${tindakanMassal?['penyiraman'] == true ? "Ya" : "Tidak"} • '
                          'Pruning: ${tindakanMassal?['pruning'] == true ? "Ya" : "Tidak"} • '
                          'Nutrisi: ${tindakanMassal?['nutrisi'] == true ? "Ya" : "Tidak"} • '
                          'Repotting: ${tindakanMassal?['repotting'] == true ? "Ya" : "Tidak"} • '
                          'Foto Kondisi: ${tindakanMassal?['uploadGambar'] == true ? "Ya" : "Tidak"}',
                          style:
                              regular12.copyWith(color: Colors.green.shade600),
                        ),
                        // Tampilkan detail nutrisi jika diaktifkan
                        if (tindakanMassal?['nutrisi'] == true &&
                            tindakanMassal?['nutrisiData'] != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detail Nutrisi Massal:',
                                  style: semibold12.copyWith(
                                      color: Colors.orange.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Jenis: ${tindakanMassal?['nutrisiData']?['jenisPemberian'] ?? '-'}',
                                  style: regular12.copyWith(
                                      color: Colors.orange.shade600),
                                ),
                                Text(
                                  'Bahan: ${tindakanMassal?['nutrisiData']?['bahan']?['name'] ?? '-'}',
                                  style: regular12.copyWith(
                                      color: Colors.orange.shade600),
                                ),
                                Text(
                                  'Dosis per tanaman: ${tindakanMassal?['nutrisiData']?['jumlahDosis'] ?? 0} ${tindakanMassal?['nutrisiData']?['satuan'] ?? ''}',
                                  style: regular12.copyWith(
                                      color: Colors.orange.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Tabel input untuk setiap tanaman
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Data Individual Tanaman ($formCount)',
                            style: bold18.copyWith(color: dark1),
                          ),
                          TextButton.icon(
                            onPressed: _editTindakanMassal,
                            icon:
                                Icon(Icons.arrow_back, size: 16, color: green1),
                            label: Text(
                              'Kembali',
                              style: semibold12.copyWith(color: green1),
                            ),
                            key: const Key('back_to_tindakan_massal_button'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lengkapi data spesifik untuk setiap tanaman di bawah ini.',
                        style: medium14.copyWith(color: dark2),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.blue.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'SEMUA data individual bersifat OPSIONAL termasuk foto. Anda dapat:\n• Hanya menjalankan tindakan massal saja (langsung klik "Simpan Laporan")\n• Mengisi data individual untuk tanaman tertentu\n• Mengombinasikan keduanya sesuai kebutuhan\n\nJika hanya tindakan massal, kondisi tanaman tetap menggunakan data terakhir untuk analisis kesehatan.',
                                    style: regular12.copyWith(
                                        color: Colors.blue.shade700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.image,
                                    color: Colors.orange.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tindakanMassal?['uploadGambar'] == true
                                        ? 'Foto kondisi tanaman telah diupload di tahap sebelumnya dan akan digunakan untuk laporan yang tidak memiliki foto individual (dioptimasi: 1x upload untuk banyak tanaman).'
                                        : 'Tidak ada foto kondisi harian kebun. Isi foto kondisi individual per tanaman (opsional). Apabila keduanya kosong maka akan menggunakan gambar kebun sebagai pengganti.',
                                    style: regular12.copyWith(
                                        color: Colors.orange.shade700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.history,
                                    color: Colors.green.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Data tinggi tanaman, kondisi daun dan status pertumbuhan terakhir telah otomatis dimuat dari laporan sebelumnya. Hanya perubahan dan data baru yang akan dikirim.',
                                    style: regular12.copyWith(
                                        color: Colors.green.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                ...List.generate(formCount, (i) {
                  final objek = (dataObjekBudidaya != null &&
                          i < dataObjekBudidaya.length)
                      ? dataObjekBudidaya[i]
                      : null;

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Form(
                        key: _formKeys[i],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: green1,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: semibold14.copyWith(color: white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        objek?['name'] ?? 'Tanaman ${i + 1}',
                                        style:
                                            semibold16.copyWith(color: dark1),
                                      ),
                                      Text(
                                        widget.data?['unitBudidaya']
                                                ?['category'] ??
                                            '-',
                                        style: regular12.copyWith(color: dark2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Input tinggi tanaman
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InputFieldWidget(
                                    key: Key('tinggi_tanaman_$i'),
                                    label: "Tinggi Tanaman (cm) - Opsional",
                                    hint:
                                        "Contoh: ${_lastHeights[i].toStringAsFixed(1)} atau lebih",
                                    controller: _heightController[i],
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) {
                                      // Only validate if value is not empty
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          value != "0.0" &&
                                          value != "0") {
                                        final newHeight =
                                            double.tryParse(value);
                                        if (newHeight == null) {
                                          return 'Masukkan angka yang valid';
                                        }
                                        if (newHeight < _lastHeights[i]) {
                                          return 'Tinggi tidak boleh kurang dari tinggi sebelumnya (${_lastHeights[i].toStringAsFixed(1)} cm)';
                                        }
                                      }
                                      return null;
                                    }),
                                if (_lastHeights[i] > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 4, bottom: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            size: 12,
                                            color: Colors.blue.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Tinggi terakhir: ${_lastHeights[i].toStringAsFixed(1)} cm',
                                          style: regular10.copyWith(
                                              color: Colors.blue.shade600,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            // Dropdown kondisi daun
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownFieldWidget(
                                  key: Key('kondisi_daun_$i'),
                                  label: "Kondisi Daun - Opsional",
                                  hint: "Pilih kondisi daun",
                                  items: kondisiDaunDisplayMap.values.toList(),
                                  selectedValue:
                                      kondisiDaunDisplayMap[kondisiDaun[i]],
                                  onChanged: (displayValue) {
                                    if (displayValue == null) return;
                                    setState(() {
                                      kondisiDaun[i] = kondisiDaunDisplayMap
                                          .entries
                                          .firstWhere(
                                              (entry) =>
                                                  entry.value == displayValue,
                                              orElse: () =>
                                                  kondisiDaunDisplayMap
                                                      .entries.first)
                                          .key;
                                    });
                                  },
                                  validator: (value) {
                                    // Optional field - no validation required
                                    return null;
                                  },
                                ),
                                if (kondisiDaun[i] == _initialKondisiDaun[i] &&
                                    _initialKondisiDaun[i] != 'sehat')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 4, bottom: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            size: 12,
                                            color: Colors.blue.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Diambil dari laporan terakhir',
                                          style: regular10.copyWith(
                                              color: Colors.blue.shade600,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            // Dropdown status tumbuh
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownFieldWidget(
                                  key: Key('status_tumbuh_$i'),
                                  label: "Status Pertumbuhan - Opsional",
                                  hint: "Pilih status tumbuh",
                                  items: statusTumbuhDisplayMap.values.toList(),
                                  selectedValue:
                                      statusTumbuhDisplayMap[statusTumbuh[i]],
                                  onChanged: (displayValue) {
                                    if (displayValue == null) return;
                                    setState(() {
                                      statusTumbuh[i] = statusTumbuhDisplayMap
                                          .entries
                                          .firstWhere(
                                              (entry) =>
                                                  entry.value == displayValue,
                                              orElse: () =>
                                                  statusTumbuhDisplayMap
                                                      .entries.first)
                                          .key;
                                    });
                                  },
                                  validator: (value) {
                                    // Optional field - no validation required
                                    return null;
                                  },
                                ),
                                if (statusTumbuh[i] ==
                                        _initialStatusTumbuh[i] &&
                                    _initialStatusTumbuh[i] != 'bibit')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0, left: 4, bottom: 12),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            size: 12,
                                            color: Colors.blue.shade600),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Diambil dari laporan terakhir',
                                          style: regular10.copyWith(
                                              color: Colors.blue.shade600,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            // Image picker untuk tanaman
                            ImagePickerWidget(
                              key: Key('image_tanaman_$i'),
                              label: "Foto Kondisi Tanaman - Opsional",
                              image: _imageTanamanList[i],
                              onPickImage: (ctx) {
                                _pickImage(context, i);
                              },
                            ),

                            // Catatan
                            InputFieldWidget(
                                key: Key('catatan_$i'),
                                label: "Catatan Pelaporan - Opsional",
                                hint: "Keterangan tambahan",
                                controller: _catatanController[i],
                                maxLines: 3,
                                validator: (value) {
                                  // Optional field - no validation required
                                  return null;
                                }),

                            // Image picker untuk dosis nutrisi jika diperlukan
                            if (isNutrisiEnabled) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.orange.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.camera_alt,
                                            color: Colors.orange.shade700,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Foto Pemberian Nutrisi - Opsional',
                                          style: semibold14.copyWith(
                                              color: Colors.orange.shade700),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Tampilkan info nutrisi massal
                                    if (tindakanMassal?['nutrisiData'] !=
                                        null) ...[
                                      Text(
                                        'Nutrisi: ${tindakanMassal?['nutrisiData']?['bahan']?['name'] ?? '-'}',
                                        style: regular12.copyWith(
                                            color: Colors.orange.shade600),
                                      ),
                                      Text(
                                        'Dosis: ${tindakanMassal?['nutrisiData']?['jumlahDosis'] ?? 0} ${tindakanMassal?['nutrisiData']?['satuan'] ?? ''}',
                                        style: regular12.copyWith(
                                            color: Colors.orange.shade600),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    ImagePickerWidget(
                                      key: Key('image_dosis_$i'),
                                      label: "Foto Pemberian Dosis - Opsional",
                                      image: _imageDosisList.length > i
                                          ? _imageDosisList[i]
                                          : null,
                                      onPickImage: (ctx) {
                                        _pickImageDosis(context, i);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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
            buttonText: 'Simpan Laporan',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isLoading,
            key: const Key('submit_all_reports_button'),
          ),
        ),
      ),
    );
  }
}
