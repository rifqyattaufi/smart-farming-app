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

class PelaporanKematianTernakScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;
  const PelaporanKematianTernakScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanKematianTernakScreen> createState() =>
      _PelaporanKematianTernakScreenState();
}

class _PelaporanKematianTernakScreenState
    extends State<PelaporanKematianTernakScreen> {
  final LaporanService _laporanService = LaporanService();
  final ImageService _imageService = ImageService();

  bool _isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> _formKeys = [];

  List<TextEditingController> _catatanController = [];
  List<TextEditingController> _dateController = [];
  List<TextEditingController> _nameController = [];
  final TextEditingController _jumlahController = TextEditingController();
  List<File?> _imageList = [];

  Future<void> _pickImageTernak(BuildContext context, int index) async {
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
                    _image = File(pickedFile.path);
                    _imageList[index] = _image;
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
            'Gambar kondisi ternak pada ${list[i]?['name'] ?? 'data ke-${i + 1}'} tidak boleh kosong');
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
        final imageUrl = await _imageService.uploadImage(_imageList[i]!);

        final data = {
          'unitBudidayaId': widget.data?['unitBudidaya']?['id'],
          'objekBudidayaId': list[i]?['id'],
          'tipe': widget.tipe,
          'judul': (list[i]?['name'] != null &&
                  (list[i]?['name'] as String).isNotEmpty)
              ? "Laporan Kematian ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${list[i]?['name']}"
              : "Laporan Kematian ${widget.data?['unitBudidaya']?['name'] ?? ''}",
          'gambar': imageUrl['data'],
          'catatan': _catatanController[i].text,
          'kematian': {
            'tanggal': _dateController[i].text,
            'penyebab': _nameController[i].text,
          },
          'jumlah': _jumlahController.text,
        };

        final response = await _laporanService.createLaporanKematian(data);

        if (response['status']) {
          showAppToast(
            context,
            'Berhasil mengirim laporan Kematian ${(list[i]?['name']?['name'] ?? '')}',
            isError: false,
          );
        } else {
          showAppToast(context,
              'Gagal mengirim laporan Kematian ${(list[i]?['name']?['name'] ?? '')}: ${response['message']}');
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
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
    final length = objekBudidayaList.length;
    _catatanController = List.generate(length, (_) => TextEditingController());
    _dateController = List.generate(length, (_) => TextEditingController());
    _nameController = List.generate(length, (_) => TextEditingController());
    _imageList = List.generate(length, (_) => null);
    _formKeys.clear();
    _formKeys.addAll(List.generate(length, (_) => GlobalKey<FormState>()));
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
            greeting: 'Pelaporan Kematian Ternak',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        InputFieldWidget(
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
                        if (objek == null)
                          InputFieldWidget(
                            label: "Jumlah Kematian",
                            hint: "Contoh: 2",
                            controller: _jumlahController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah kematian tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Jumlah kematian harus berupa angka';
                              }
                              return null;
                            },
                          ),
                        InputFieldWidget(
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
                            label: "Unggah bukti kondisi ternak",
                            image: _imageList[i],
                            onPickImage: (ctx) async {
                              _pickImageTernak(context, i);
                            }),
                        InputFieldWidget(
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
