import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:flutter/scheduler.dart';

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

  List<TextEditingController> sizeControllers = [];
  List<TextEditingController> catatanControllers = [];
  Map<String, dynamic>? satuanList;
  List<File?> imageList = [];
  File? _image;
  final picker = ImagePicker();
  final List<GlobalKey<FormState>> formKeys = [];
  bool isLoading = false;

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
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    final objekBudidayaList = widget.data?['objekBudidaya'] ?? [null];
    final length = objekBudidayaList.length;
    sizeControllers = List.generate(length, (_) => TextEditingController());
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

  Future<void> _submitForm() async {
    if (isLoading) return;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gambar bukti panen ${(list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? '')} belum dipilih'),
            backgroundColor: Colors.red,
          ),
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
          }
        };

        final response = await _laporanService.createLaporanPanen(data);

        if (response['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Laporan panen ${(list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? '')} berhasil dikirim'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Gagal mengirim laporan panen ${(list[i]?['name'] ?? widget.data?['komoditas']?['name'] ?? '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      for (int i = 0; i < widget.step; i++) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
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
                        label: "Jumlah panen",
                        hint: "Contoh: 20",
                        controller: sizeControllers[i],
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah panen wajib diisi';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Jumlah panen harus berupa angka';
                          }
                          return null;
                        },
                      ),
                      DropdownFieldWidget(
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
                        label: "Unggah bukti hasil panen",
                        image: imageList[i],
                        onPickImage: (ctx) async {
                          await _pickImage(ctx, i);
                        },
                      ),
                      InputFieldWidget(
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
          isLoading: isLoading,
        ),
      ),
    );
  }
}
