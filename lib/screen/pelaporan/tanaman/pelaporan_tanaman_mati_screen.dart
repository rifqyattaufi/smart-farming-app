import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class PelaporanTanamanMatiScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanTanamanMatiScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanTanamanMatiScreen> createState() =>
      _PelaporanTanamanMatiScreenState();
}

class _PelaporanTanamanMatiScreenState
    extends State<PelaporanTanamanMatiScreen> {
  final LaporanService _laporanService = LaporanService();
  final ImageService _imageService = ImageService();

  bool _isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _catatanController = [];
  List<TextEditingController> _dateController = [];
  List<TextEditingController> _nameController = [];
  List<File?> _imageList = [];

  Future<void> _pickImageTanaman(BuildContext context, int index) async {
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

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [];
    // Ensure we have at least one item to work with
    final List<dynamic> list =
        objekBudidayaList is List && objekBudidayaList.isNotEmpty
            ? objekBudidayaList
            : [null];

    bool allValid = true;
    for (int i = 0; i < list.length; i++) {
      if (_formKeys.length > i && _formKeys[i].currentState != null) {
        if (!_formKeys[i].currentState!.validate()) {
          allValid = false;
        }
      } else {
        allValid = false;
      }

      if (_imageList.length > i && _imageList[i] == null && allValid == true) {
        allValid = false;
        final itemName = list[i] != null && list[i]['name'] != null
            ? list[i]['name']
            : 'tanaman ke-${i + 1}';
        showAppToast(context,
            'Gambar bukti kondisi tanaman pada $itemName tidak boleh kosong',
            isError: true);
      }
    }
    if (!allValid) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      for (var i = 0; i < list.length; i++) {
        // Check if we have valid controllers and images for this index
        if (i >= _imageList.length ||
            i >= _catatanController.length ||
            i >= _dateController.length ||
            i >= _nameController.length) {
          continue;
        }

        final imageUrl = await _imageService.uploadImage(_imageList[i]!);

        final itemName =
            list[i] != null && list[i]['name'] != null ? list[i]['name'] : '';
        final unitName = widget.data?['unitBudidaya']?['name'] ?? '';

        final data = {
          'unitBudidayaId': widget.data?['unitBudidaya']?['id'],
          'objekBudidayaId': list[i] != null ? list[i]['id'] : null,
          'tipe': widget.tipe,
          'judul': "Laporan Kematian $unitName - $itemName",
          'gambar': imageUrl['data'],
          'catatan': _catatanController[i].text,
          'kematian': {
            'tanggal': _dateController[i].text,
            'penyebab': _nameController[i].text,
          },
        };

        final response = await _laporanService.createLaporanKematian(data);

        if (response['status']) {
          showAppToast(
            context,
            'Berhasil mengirim laporan tanaman $itemName mati',
            isError: false,
          );
        } else {
          showAppToast(
              context, 'Gagal mengirim laporan tanaman $itemName mati');
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
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [];
    // Ensure we have at least one item to work with
    final List<dynamic> safeList =
        objekBudidayaList is List && objekBudidayaList.isNotEmpty
            ? objekBudidayaList
            : [null];

    final length = safeList.length;
    _catatanController = List.generate(length, (_) => TextEditingController());
    _dateController = List.generate(length, (_) => TextEditingController());
    _nameController = List.generate(length, (_) => TextEditingController());
    _imageList = List.generate(length, (_) => null);
    _formKeys.clear();
    _formKeys.addAll(List.generate(length, (_) => GlobalKey<FormState>()));
  }

  @override
  Widget build(BuildContext context) {
    final objekBudidayaRaw = widget.data?['objekBudidaya'] ?? [];
    final List<dynamic> objekBudidayaList =
        objekBudidayaRaw is List && objekBudidayaRaw.isNotEmpty
            ? objekBudidayaRaw
            : [null];

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
            greeting: 'Pelaporan Tanaman Mati',
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
                            'Data Tanaman',
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
                          InputFieldWidget(
                            key: Key('tanggal_waktu_kematian_$i'),
                            label: "Tanggal & waktu kematian",
                            hint: "Contoh: Senin, 17 Februari 2025 10:00",
                            controller: _dateController[i],
                            suffixIcon: const Icon(Icons.calendar_today),
                            isDisabled: true,
                            onSuffixIconTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2010),
                                lastDate: DateTime.now(),
                              );

                              if (pickedDate != null) {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (pickedTime != null) {
                                  final DateTime pickedDateTime = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  final String formattedDateTime =
                                      DateFormat('EEEE, dd MMMM yyyy HH:mm')
                                          .format(pickedDateTime);

                                  _dateController[i].text = formattedDateTime;
                                }
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal & waktu kematian tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          InputFieldWidget(
                            key: Key('penyebab_kematian_$i'),
                            label: "Penyebab kematian",
                            hint: "Contoh: Sakit",
                            controller: _nameController[i],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Penyebab kematian tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          ImagePickerWidget(
                              key: Key('image_picker_tanaman_$i'),
                              label: "Unggah bukti kondisi tanaman",
                              image: _imageList[i],
                              onPickImage: (ctx) async {
                                _pickImageTanaman(context, i);
                              }),
                          InputFieldWidget(
                            key: Key('catatan_jurnal_$i'),
                            label: "Catatan/jurnal pelaporan",
                            hint: "Keterangan",
                            controller: _catatanController[i],
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Catatan tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
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
              key: const Key('submit_pelaporan_tanaman_mati_button')),
        ),
      ),
    );
  }
}
