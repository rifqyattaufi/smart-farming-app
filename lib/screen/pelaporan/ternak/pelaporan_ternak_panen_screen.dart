import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/service/grade_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/capacity_objek_selection_grid.dart';

class RincianGradeForm {
  String? gradeId;
  String? gradeNama;
  TextEditingController jumlahController = TextEditingController();
  GlobalKey<FormFieldState> gradeFieldKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> jumlahFieldKey = GlobalKey<FormFieldState>();

  RincianGradeForm({this.gradeId, this.gradeNama});
}

class PelaporanTernakPanenScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;
  const PelaporanTernakPanenScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanTernakPanenScreen> createState() =>
      _PelaporanTernakPanenScreenState();
}

class _PelaporanTernakPanenScreenState
    extends State<PelaporanTernakPanenScreen> {
  final SatuanService _satuanService = SatuanService();
  final LaporanService _laporanService = LaporanService();
  final ImageService _imageService = ImageService();
  final ObjekBudidayaService _objekBudidayaService = ObjekBudidayaService();
  final GradeService _gradeService = GradeService();

  List<TextEditingController> sizeControllers = [];
  List<TextEditingController> jumlahHewanControllers = [];
  List<TextEditingController> catatanControllers = [];
  Map<String, dynamic>? satuanList;
  List<File?> imageList = [];
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> formKeys = [];
  bool isLoading = false;

  // Grade-related variables
  final List<List<RincianGradeForm>> _rincianGradeListPerAnimal = [];
  List<Map<String, dynamic>> _gradeMasterList = [];
  bool _isLoadingGrade = true;
  bool _isGradeExpanded = false; // For collapsible grade section

  // State for grid selection
  List<Map<String, dynamic>> allObjekBudidaya = [];
  Set<String> selectedObjekIds = {};
  bool isLoadingObjek = false;
  bool _isAnimalSelectionExpanded = false; // For collapsible animal selection

  Future<void> _fetchData() async {
    try {
      final response = await _satuanService
          .getSatuanById(widget.data!['komoditas']['satuan']);
      if (response['status']) {
        setState(() {
          satuanList = {
            'id': response['data']['id'],
            'nama':
                "${response['data']['nama']} - ${response['data']['lambang']}",
          };
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _fetchObjekBudidaya() async {
    if (widget.data?['unitBudidaya']?['id'] == null) return;

    setState(() {
      isLoadingObjek = true;
    });

    try {
      final response = await _objekBudidayaService
          .getObjekBudidayaByUnitBudidaya(widget.data!['unitBudidaya']['id']);

      if (response['status'] && response['data'] != null) {
        final List<dynamic> existingObjek = response['data'];
        final int capacity = widget.data?['unitBudidaya']?['kapasitas'] ?? 0;

        // Create grid items based on capacity
        List<Map<String, dynamic>> gridItems = [];

        // Create a map to store existing objek by their slot number
        Map<int, Map<String, dynamic>> slotMap = {};

        for (var objek in existingObjek) {
          String namaId = objek['namaId'] ?? '';
          // Extract slot number from namaId (e.g., "Ayam#1" -> 1)
          RegExp regExp = RegExp(r'#(\d+)$');
          Match? match = regExp.firstMatch(namaId);

          if (match != null) {
            int slotNumber = int.parse(match.group(1)!);
            slotMap[slotNumber] = {
              'id': objek['id'],
              'namaId': objek['namaId'],
              'name': objek['namaId'], // Use namaId as display name
              'gambar': objek['gambar'],
              'isAvailable': true,
              'slotNumber': slotNumber,
            };
          }
        }

        // Create grid items for all slots up to capacity
        for (int i = 1; i <= capacity; i++) {
          if (slotMap.containsKey(i)) {
            // Slot is filled with actual objek
            gridItems.add(slotMap[i]!);
          } else {
            // Slot is empty - create placeholder
            gridItems.add({
              'id': null,
              'namaId': 'Slot #$i',
              'name': 'Slot #$i',
              'gambar': null,
              'isAvailable': false,
              'slotNumber': i,
            });
          }
        }

        setState(() {
          allObjekBudidaya = gridItems;
          isLoadingObjek = false;
        });
      } else {
        setState(() {
          isLoadingObjek = false;
        });
        showAppToast(context, 'Gagal memuat data objek budidaya');
      }
    } catch (e) {
      setState(() {
        isLoadingObjek = false;
      });
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _fetchGradeMaster() async {
    setState(() => _isLoadingGrade = true);
    try {
      final response = await _gradeService.getPagedGrades();
      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> gradeData = response['data'];
        setState(() {
          _gradeMasterList = gradeData.map((grade) {
            return {
              'id': grade['id'],
              'nama': grade['nama'],
              'deskripsi': grade['deskripsi'] ?? '',
            };
          }).toList();
          _isLoadingGrade = false;
        });
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal memuat data grade.');
        setState(() => _isLoadingGrade = false);
      }
    } catch (e) {
      showAppToast(context, 'Error fetching grade data: $e');
      setState(() => _isLoadingGrade = false);
    }
  }

  void _tambahRincianGrade(int animalIndex) {
    setState(() {
      if (animalIndex < _rincianGradeListPerAnimal.length) {
        _rincianGradeListPerAnimal[animalIndex].add(RincianGradeForm());
      }
    });
  }

  void _hapusRincianGrade(int animalIndex, int gradeIndex) {
    setState(() {
      if (animalIndex < _rincianGradeListPerAnimal.length &&
          gradeIndex < _rincianGradeListPerAnimal[animalIndex].length) {
        _rincianGradeListPerAnimal[animalIndex].removeAt(gradeIndex);
      }
    });
  }

  List<String> _getAvailableGradesForIndex(int animalIndex, int currentIndex) {
    if (animalIndex >= _rincianGradeListPerAnimal.length) return [];

    // Get all grade names that are already selected (excluding current index)
    final selectedGradeIds = _rincianGradeListPerAnimal[animalIndex]
        .asMap()
        .entries
        .where(
            (entry) => entry.key != currentIndex && entry.value.gradeId != null)
        .map((entry) => entry.value.gradeId)
        .toSet();

    // Return grades that are not yet selected, plus the currently selected one for this index
    final currentGradeId =
        currentIndex < _rincianGradeListPerAnimal[animalIndex].length
            ? _rincianGradeListPerAnimal[animalIndex][currentIndex].gradeId
            : null;
    return _gradeMasterList
        .where((grade) =>
            !selectedGradeIds.contains(grade['id']) ||
            grade['id'] == currentGradeId)
        .map((grade) => grade['nama'].toString())
        .toList();
  }

  double _calculateTotalRealisasiPanen(int animalIndex) {
    if (animalIndex >= _rincianGradeListPerAnimal.length) return 0.0;

    double total = 0.0;
    for (var rincian in _rincianGradeListPerAnimal[animalIndex]) {
      final jumlahText = rincian.jumlahController.text;
      final jumlahValue = double.tryParse(jumlahText);
      if (jumlahValue != null && jumlahValue > 0) {
        total += jumlahValue;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchGradeMaster();

    // Only fetch objek budidaya for kolektif tipeKomoditas and individu unitBudidaya
    if (widget.data?['komoditas']?['tipeKomoditas'] == 'kolektif' &&
        widget.data?['unitBudidaya']?['tipe'] == 'individu') {
      _fetchObjekBudidaya();
    }

    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
    final length = objekBudidayaList.length;
    sizeControllers = List.generate(length, (_) => TextEditingController());
    jumlahHewanControllers =
        List.generate(length, (_) => TextEditingController());
    catatanControllers = List.generate(length, (_) => TextEditingController());
    imageList = List.generate(length, (_) => null);
    formKeys.clear();
    formKeys.addAll(List.generate(length, (_) => GlobalKey<FormState>()));

    // Initialize grade lists for each animal
    _rincianGradeListPerAnimal.clear();
    for (int i = 0; i < length; i++) {
      _rincianGradeListPerAnimal.add([RincianGradeForm()]);
    }
  }

  Future<void> _pickImage(BuildContext context, int index) async {
    _image = null;
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
              key: const Key('camera_option'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    imageList[index] = _image;
                  });
                }
              },
            ),
            ListTile(
              key: const Key('gallery_option'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _image = File(pickedFile.path);
                    imageList[index] = _image;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleObjekSelection(String objekId) {
    // Find the objek to check if it's available
    final objek = allObjekBudidaya.firstWhere(
      (item) => item['id']?.toString() == objekId,
      orElse: () => {},
    );

    // Only allow selection if the objek is available (has actual ID)
    if (objek.isNotEmpty &&
        objek['isAvailable'] == true &&
        objek['id'] != null) {
      setState(() {
        if (selectedObjekIds.contains(objekId)) {
          selectedObjekIds.remove(objekId);
        } else {
          selectedObjekIds.add(objekId);
        }
      });
    }
  }

  void _selectAllObjek() {
    setState(() {
      // Only select objek that are available (not empty slots)
      selectedObjekIds = allObjekBudidaya
          .where((objek) => objek['isAvailable'] == true && objek['id'] != null)
          .map((objek) => objek['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    });
  }

  void _deselectAllObjek() {
    setState(() {
      selectedObjekIds.clear();
    });
  }

  Widget _buildObjekGrid() {
    return CapacityObjekSelectionGrid(
      objektList: allObjekBudidaya,
      selectedObjekIds: selectedObjekIds,
      onObjekTap: _toggleObjekSelection,
      onSelectAll: _selectAllObjek,
      onDeselectAll: _deselectAllObjek,
      title: 'Pilih Hewan yang Dipanen',
      subtitle: 'Tap pada objek untuk memilih/membatalkan pilihan',
      isLoading: isLoadingObjek,
    );
  }

  Future<void> _submitForm() async {
    if (isLoading) return;

    // Validate grade data for all animals
    for (int animalIndex = 0;
        animalIndex < _rincianGradeListPerAnimal.length;
        animalIndex++) {
      if (_rincianGradeListPerAnimal[animalIndex].isNotEmpty) {
        final selectedGradeIds = <String>[];
        for (var rincian in _rincianGradeListPerAnimal[animalIndex]) {
          if (rincian.gradeId == null ||
              rincian.jumlahController.text.isEmpty) {
            showAppToast(context,
                'Harap pilih grade dan isi jumlah pada setiap rincian grade untuk hewan ${animalIndex + 1}.');
            return;
          }
          if (double.tryParse(rincian.jumlahController.text) == null ||
              double.parse(rincian.jumlahController.text) <= 0) {
            showAppToast(context,
                'Jumlah pada rincian grade hewan ${animalIndex + 1} harus angka positif.');
            return;
          }

          // Check for duplicate grades
          if (selectedGradeIds.contains(rincian.gradeId)) {
            showAppToast(context,
                'Grade yang sama tidak boleh dipilih lebih dari sekali untuk hewan ${animalIndex + 1}.');
            return;
          }
          selectedGradeIds.add(rincian.gradeId!);
        }
      }
    }

    // Validate that at least one objek is selected for kolektif tipeKomoditas and individu unitBudidaya
    if (widget.data?['komoditas']?['tipeKomoditas'] == 'kolektif' &&
        widget.data?['unitBudidaya']?['tipe'] == 'individu' &&
        selectedObjekIds.isEmpty) {
      showAppToast(
        context,
        'Pilih minimal satu hewan yang akan dipanen',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    final objekBudidayaList = widget.data?['objekBudidaya'];
    final list = (objekBudidayaList == null ||
            (objekBudidayaList is List && objekBudidayaList.isEmpty))
        ? [null]
        : objekBudidayaList;

    bool allValid = true;
    for (int i = 0; i < list.length; i++) {
      if (!(formKeys[i].currentState?.validate() ?? false)) {
        allValid = false;
      }

      if (imageList[i] == null && allValid == true) {
        allValid = false;
        showAppToast(
          context,
          'Gambar bukti hasil panen pada objek ${list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? ''} wajib diisi',
          isError: false,
        );
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
        final imageUrl = await _imageService.uploadImage(imageList[i]!);

        // Calculate total realisasi panen from grades for this animal
        double totalRealisasiPanen = i < _rincianGradeListPerAnimal.length
            ? _calculateTotalRealisasiPanen(i)
            : 0.0;

        final data = {
          'unitBudidayaId': widget.data?['unitBudidaya']?['id'],
          'objekBudidayaId': list[i]?['id'],
          'tipe': widget.tipe,
          'judul':
              "Laporan Panen ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${(list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? '')}",
          'gambar': imageUrl['data'],
          'catatan': catatanControllers[i].text,
          'panen': {
            'komoditasId': widget.data?['komoditas']?['id'],
            'jumlah': totalRealisasiPanen > 0
                ? totalRealisasiPanen
                : double.parse(sizeControllers[i].text),
            if (widget.data?['unitBudidaya']?['tipe'] == 'kolektif')
              'jumlahHewan': int.parse(jumlahHewanControllers[i].text),
            // Add grade data if available for this animal
            if (i < _rincianGradeListPerAnimal.length &&
                _rincianGradeListPerAnimal[i].isNotEmpty)
              'rincianGrade': _rincianGradeListPerAnimal[i]
                  .map((rincian) => {
                        'gradeId': rincian.gradeId,
                        'jumlah': double.parse(rincian.jumlahController.text),
                      })
                  .toList(),
          },
          'detailPanen': selectedObjekIds.toList(),
        };

        final response = await _laporanService.createLaporanPanen(data);

        if (response['status']) {
          showAppToast(
            context,
            'Berhasil mengirim laporan panen ${(list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? '')}',
            isError: false,
          );
        } else {
          showAppToast(
            context,
            'Gagal mengirim laporan panen ${(list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? '')}: ${response['message']}',
            isError: true,
          );
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

  @override
  void dispose() {
    for (var animalGradeList in _rincianGradeListPerAnimal) {
      for (var rincian in animalGradeList) {
        rincian.jumlahController.dispose();
      }
    }
    super.dispose();
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
            greeting: 'Pelaporan Panen Ternak',
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
                  final animalName = (objek?['name'] != null &&
                          (objek?['name'] as String).isNotEmpty)
                      ? objek!['name'] as String
                      : (widget.data?['komoditas']?['name'] as String? ??
                          'Hewan ${i + 1}');
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Form(
                      key: formKeys[i],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Komoditas Ternak',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ((objek?['name'] != null &&
                                        (objek?['name'] as String).isNotEmpty)
                                    ? '${objek?['name']} - '
                                    : '') +
                                (widget.data?['komoditas']?['name'] ?? '-'),
                            style: bold20.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${widget.data?['komoditas']?['jenisBudidayaLatin'] ?? '-'} - ${widget.data?['unitBudidaya']?['name'] ?? '-'}',
                            style: semibold16.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 12),
                          InputFieldWidget(
                            key: Key('jumlah_panen_input_$i'),
                            label: "Jumlah panen",
                            hint: "Contoh: 20.5",
                            controller: sizeControllers[i],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah panen wajib diisi';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Jumlah panen harus berupa angka';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Jumlah panen harus lebih dari 0';
                              }
                              return null;
                            },
                          ),
                          // Show jumlah hewan field for kolektif unitBudidaya
                          if (widget.data?['unitBudidaya']?['tipe'] ==
                              'kolektif')
                            InputFieldWidget(
                              key: Key('jumlah_hewan_input_$i'),
                              label: "Jumlah hewan",
                              hint: "Contoh: 5",
                              controller: jumlahHewanControllers[i],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Jumlah hewan wajib diisi';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Jumlah hewan harus berupa angka';
                                }
                                if (double.parse(value) <= 0) {
                                  return 'Jumlah hewan harus lebih dari 0';
                                }
                                return null;
                              },
                            ),
                          DropdownFieldWidget(
                            key: Key('satuan_panen_dropdown_$i'),
                            label: "Satuan panen",
                            hint: "Pilih satuan panen",
                            items: [satuanList?['nama'] ?? '-'],
                            selectedValue: satuanList?['nama'] ?? '-',
                            onChanged: (value) => {},
                            isEdit: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Satuan panen wajib diisi';
                              }
                              return null;
                            },
                          ),
                          ImagePickerWidget(
                            key: Key('image_picker_$i'),
                            label: "Unggah bukti hasil panen",
                            image: imageList[i],
                            onPickImage: (ctx) async {
                              await _pickImage(ctx, i);
                            },
                          ),
                          InputFieldWidget(
                            key: Key('catatan_input_$i'),
                            label: "Catatan/jurnal pelaporan",
                            hint: "Keterangan",
                            controller: catatanControllers[i],
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Catatan wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const Divider(),
                          // Grade Section for this animal
                          const SizedBox(height: 12),
                          // Grade Header with Collapse Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isGradeExpanded = !_isGradeExpanded;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: green1.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: green1.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isGradeExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: green1,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rincian Grade Panen - $animalName',
                                          style: bold18.copyWith(color: green1),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _isGradeExpanded
                                              ? 'Tap untuk menyembunyikan rincian grade'
                                              : 'Tap untuk mengatur rincian grade panen',
                                          style:
                                              regular12.copyWith(color: dark2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (i < _rincianGradeListPerAnimal.length &&
                                      _rincianGradeListPerAnimal[i].isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: green1,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_rincianGradeListPerAnimal[i].length} grade',
                                        style: medium10.copyWith(color: white),
                                      ),
                                    ),
                                  if (_isGradeExpanded)
                                    IconButton(
                                      key: Key('tambah_rincian_grade_$i'),
                                      icon:
                                          Icon(Icons.add_circle, color: green1),
                                      onPressed: () => _tambahRincianGrade(i),
                                      tooltip: "Tambah Rincian Grade",
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Collapsible Grade Content
                          if (_isGradeExpanded &&
                              i < _rincianGradeListPerAnimal.length) ...[
                            const SizedBox(height: 16),
                            if (_isLoadingGrade)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (_gradeMasterList.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color:
                                          Colors.orange.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: Colors.orange, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        key: Key('no_grade_found_$i'),
                                        "Data master grade tidak ditemukan. Tidak dapat menambahkan rincian.",
                                        style: medium12.copyWith(
                                            color: Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              // Grade List for this animal
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _rincianGradeListPerAnimal[i].length,
                                itemBuilder: (context, gradeIndex) {
                                  final rincian =
                                      _rincianGradeListPerAnimal[i][gradeIndex];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: dark4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header with Delete Button
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Grade ${gradeIndex + 1}',
                                                style: semibold14.copyWith(
                                                    color: dark1),
                                              ),
                                            ),
                                            if (_rincianGradeListPerAnimal[i]
                                                    .length >
                                                1)
                                              IconButton(
                                                icon: Icon(Icons.delete_outline,
                                                    color: red, size: 20),
                                                onPressed: () =>
                                                    _hapusRincianGrade(
                                                        i, gradeIndex),
                                                tooltip: 'Hapus Grade',
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Grade Dropdown
                                        DropdownFieldWidget(
                                          key: rincian.gradeFieldKey,
                                          label: 'Pilih Grade Kualitas',
                                          hint: 'Pilih Grade',
                                          items: _getAvailableGradesForIndex(
                                              i, gradeIndex),
                                          selectedValue: rincian.gradeNama,
                                          onChanged:
                                              (String? selectedNamaGrade) {
                                            setState(() {
                                              rincian.gradeNama =
                                                  selectedNamaGrade;
                                              if (selectedNamaGrade != null &&
                                                  _gradeMasterList.any((g) =>
                                                      g['nama'] ==
                                                      selectedNamaGrade)) {
                                                rincian
                                                    .gradeId = _gradeMasterList
                                                        .firstWhere((grade) =>
                                                            grade['nama'] ==
                                                            selectedNamaGrade)[
                                                    'id'] as String?;
                                              } else {
                                                rincian.gradeId = null;
                                              }
                                            });
                                          },
                                          validator: (value) =>
                                              (value == null || value.isEmpty)
                                                  ? 'Grade wajib dipilih'
                                                  : null,
                                        ),
                                        const SizedBox(height: 10),
                                        // Amount Input
                                        InputFieldWidget(
                                          key: rincian.jumlahFieldKey,
                                          label:
                                              "Jumlah kuantitas grade ini ${satuanList != null ? '(${satuanList!['nama']})' : ''}",
                                          hint:
                                              "Contoh: 5${satuanList != null ? ' ${satuanList!['nama']}' : ''}",
                                          controller: rincian.jumlahController,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          suffixIcon: satuanList != null
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Text(
                                                    satuanList!['nama'],
                                                    style: medium14.copyWith(
                                                        color: dark2),
                                                  ),
                                                )
                                              : null,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Jumlah wajib diisi';
                                            }
                                            final sanitizedValue =
                                                value.replaceAll(',', '.');
                                            if (double.tryParse(
                                                    sanitizedValue) ==
                                                null) {
                                              return 'Harus angka';
                                            }
                                            if (double.parse(sanitizedValue) <=
                                                0) {
                                              return 'Harus > 0';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Total Panen Display for this animal
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: blue1.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total Realisasi Panen:",
                                      style: semibold16.copyWith(color: blue1),
                                    ),
                                    Text(
                                      "${_calculateTotalRealisasiPanen(i).toStringAsFixed(1)} ${satuanList?['nama'] ?? ''}",
                                      style: bold18.copyWith(color: blue1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                // Collapsible Animal Selection Section - only for kolektif tipeKomoditas and individu unitBudidaya
                if (widget.data?['komoditas']?['tipeKomoditas'] == 'kolektif' &&
                    widget.data?['unitBudidaya']?['tipe'] == 'individu') ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 12),
                        // Animal Selection Header with Collapse Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAnimalSelectionExpanded =
                                  !_isAnimalSelectionExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: blue1.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: blue1.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isAnimalSelectionExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: blue1,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pilih Hewan yang Dipanen',
                                        style:
                                            semibold16.copyWith(color: blue1),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isAnimalSelectionExpanded
                                            ? 'Tap untuk menyembunyikan pilihan hewan'
                                            : 'Tap pada objek untuk memilih/membatalkan pilihan',
                                        style: regular12.copyWith(color: dark2),
                                      ),
                                    ],
                                  ),
                                ),
                                if (selectedObjekIds.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: blue1,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${selectedObjekIds.length} dipilih',
                                      style: medium10.copyWith(color: white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        // Collapsible Animal Selection Content
                        if (_isAnimalSelectionExpanded) ...[
                          const SizedBox(height: 16),
                          _buildObjekGrid(),
                        ],
                        // Warning when no animals selected
                        if (selectedObjekIds.isEmpty &&
                            allObjekBudidaya.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_outlined,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pilih minimal satu hewan yang akan dipanen',
                                      style:
                                          medium12.copyWith(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
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
            backgroundColor:
                (widget.data?['komoditas']?['tipeKomoditas'] == 'kolektif' &&
                        widget.data?['unitBudidaya']?['tipe'] == 'individu' &&
                        selectedObjekIds.isEmpty)
                    ? dark3
                    : green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: isLoading,
            key: const Key('submit_panen_button'),
          ),
        ),
      ),
    );
  }
}
