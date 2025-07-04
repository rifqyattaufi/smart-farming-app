import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/objek_selection_grid.dart';

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

  List<TextEditingController> sizeControllers = [];
  List<TextEditingController> jumlahHewanControllers = [];
  List<TextEditingController> catatanControllers = [];
  Map<String, dynamic>? satuanList;
  List<File?> imageList = [];
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> formKeys = [];
  bool isLoading = false;

  // State for grid selection
  List<Map<String, dynamic>> allObjekBudidaya = [];
  Set<String> selectedObjekIds = {};
  bool isLoadingObjek = false;

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
        setState(() {
          allObjekBudidaya = List<Map<String, dynamic>>.from(response['data']);
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

  @override
  void initState() {
    super.initState();
    _fetchData();

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
    setState(() {
      if (selectedObjekIds.contains(objekId)) {
        selectedObjekIds.remove(objekId);
      } else {
        selectedObjekIds.add(objekId);
      }
    });
  }

  void _selectAllObjek() {
    setState(() {
      selectedObjekIds = allObjekBudidaya
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
    return ObjekSelectionGrid(
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
            'jumlah': double.parse(sizeControllers[i].text),
            if (widget.data?['unitBudidaya']?['tipe'] == 'kolektif')
              'jumlahHewan': int.parse(jumlahHewanControllers[i].text),
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
                        ],
                      ),
                    ),
                  );
                }),
                // Show grid only for kolektif tipeKomoditas and individu unitBudidaya
                if (widget.data?['komoditas']?['tipeKomoditas'] == 'kolektif' &&
                    widget.data?['unitBudidaya']?['tipe'] == 'individu') ...[
                  _buildObjekGrid(),
                  if (selectedObjekIds.isEmpty && allObjekBudidaya.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_outlined,
                                color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pilih minimal satu hewan yang akan dipanen',
                                style: medium12.copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
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
            textStyle: semibold16,
            textColor: white,
            isLoading: isLoading,
            key: const Key('submit_panen_button'),
          ),
        ),
      ),
    );
  }
}
