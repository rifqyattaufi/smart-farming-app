import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/laporan_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/service/grade_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class RincianGradeForm {
  String? gradeId;
  String? gradeNama;
  TextEditingController jumlahController = TextEditingController();
  GlobalKey<FormFieldState> gradeFieldKey = GlobalKey<FormFieldState>();
  GlobalKey<FormFieldState> jumlahFieldKey = GlobalKey<FormFieldState>();

  RincianGradeForm({this.gradeId, this.gradeNama});
}

class PelaporanTanamanPanenScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanTanamanPanenScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanTanamanPanenScreen> createState() =>
      _PelaporanTanamanPanenScreenState();
}

class _PelaporanTanamanPanenScreenState
    extends State<PelaporanTanamanPanenScreen> {
  final LaporanService _laporanService = LaporanService();
  final ImageService _imageService = ImageService();
  final GradeService _gradeService = GradeService();
  final SatuanService _satuanService = SatuanService();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _catatanController = TextEditingController();
  File? _image;

  DateTime _tanggalPanen = DateTime.now();
  final TextEditingController _umurTanamanController = TextEditingController();
  final TextEditingController _estimasiPanenController =
      TextEditingController();
  final TextEditingController _gagalPanenController = TextEditingController();

  List<RincianGradeForm> _rincianGradeList = [];
  List<Map<String, dynamic>> _gradeMasterList = [];
  bool _isLoadingGrade = true;

  Map<String, dynamic>? satuanData;

  bool _isLoadingSatuan = true;

  List<File?> imageList = [];
  final picker = ImagePicker();

  Future<void> _fetchSatuanData() async {
    if (widget.data?['komoditas']?['satuan'] == null) {
      setState(() => _isLoadingSatuan = false);
      return;
    }
    setState(() => _isLoadingSatuan = true);
    try {
      final response = await _satuanService
          .getSatuanById(widget.data!['komoditas']['satuan']);
      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            satuanData = {
              'id': response['data']['id'],
              'nama':
                  "${response['data']['nama']} - ${response['data']['lambang']}",
            };
            _isLoadingSatuan = false;
          });
        } else {
          _showError(response['message'] ?? 'Gagal memuat data satuan.');
          setState(() => _isLoadingSatuan = false);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error fetching satuan data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSatuan = false);
      }
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
        _showError(response['message'] ?? 'Gagal memuat data grade.');
        setState(() => _isLoadingGrade = false);
      }
    } catch (e) {
      _showError('Error fetching grade data: $e');
      setState(() => _isLoadingGrade = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _tambahRincianGrade() {
    setState(() {
      _rincianGradeList.add(RincianGradeForm());
    });
  }

  void _hapusRincianGrade(int index) {
    setState(() {
      _rincianGradeList.removeAt(index);
    });
  }

  double _calculateTotalRealisasiPanen() {
    double total = 0.0;

    for (var rincian in _rincianGradeList) {
      final jumlahText = rincian.jumlahController.text;
      final jumlahValue = double.tryParse(jumlahText);
      if (jumlahValue != null && jumlahValue > 0) {
        total += jumlahValue;
      }
    }

    return total;
  }

  void _calculateAndUpdateUmurTanaman() {
    final createdAtRaw = widget.data?['unitBudidaya']?['createdAt'];
    if (createdAtRaw == null ||
        createdAtRaw is! String ||
        createdAtRaw.isEmpty) {
      _umurTanamanController.text = '';
      return;
    }

    try {
      final tanggalTanam = DateTime.parse(createdAtRaw);

      final tanggalPanen = _tanggalPanen;

      final tglTanamClean =
          DateTime(tanggalTanam.year, tanggalTanam.month, tanggalTanam.day);
      final tglPanenClean =
          DateTime(tanggalPanen.year, tanggalPanen.month, tanggalPanen.day);

      final umurInDays = tglPanenClean.difference(tglTanamClean).inDays;

      if (umurInDays >= 0) {
        _umurTanamanController.text = umurInDays.toString();
      } else {
        _umurTanamanController.text = '0';
      }

      setState(() {});
    } catch (e) {
      _umurTanamanController.text = '';
    }
  }

  Future<void> _fetchGagalPanenData() async {
    final unitId = widget.data?['unitBudidaya']?['id'];
    if (unitId == null) return;

    try {
      final response = await _laporanService.getJumlahKematianByUnitId(unitId);
      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          final jumlahMati = response['data'] ?? 0;
          setState(() {
            _gagalPanenController.text = jumlahMati.toString();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memuat data gagal panen: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSatuanData();
    _fetchGradeMaster();

    _fetchGagalPanenData();

    if (_rincianGradeList.isEmpty) {
      _tambahRincianGrade();
    }

    _calculateAndUpdateUmurTanaman();
  }

  Future<void> _pickImage(BuildContext context) async {
    _image = null;
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
    if (!_formKey.currentState!.validate()) {
      _showError('Harap lengkapi semua field yang wajib diisi.');
      return;
    }
    for (var rincian in _rincianGradeList) {
      if (rincian.gradeId == null || rincian.jumlahController.text.isEmpty) {
        _showError(
            'Harap pilih grade dan isi jumlah pada setiap rincian grade.');
        return;
      }
      if (double.tryParse(rincian.jumlahController.text) == null ||
          double.parse(rincian.jumlahController.text) <= 0) {
        _showError('Jumlah pada rincian grade harus angka positif.');
        return;
      }
    }

    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_image != null) {
        final imageResponse = await _imageService.uploadImage(_image!);
        if (imageResponse['status'] == true && imageResponse['data'] != null) {
          imageUrl = imageResponse['data'];
        } else {
          _showError(
              imageResponse['message'] ?? 'Gagal mengunggah gambar laporan.');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Hitung total realisasi panen
      double totalRealisasiPanen = _calculateTotalRealisasiPanen();

      final payload = {
        'judul':
            "Laporan Panen ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${widget.data?['komoditas']?['name'] ?? ''}",
        'unitBudidayaId': widget.data?['unitBudidaya']?['id'],
        'tipe': 'panen',
        'gambar': imageUrl,
        'catatan': _catatanController.text,
        'panen': {
          'tanggalPanen': _tanggalPanen.toIso8601String(),
          'komoditasId': widget.data?['komoditas']?['id'],
          'umurTanamanPanen': _umurTanamanController.text.isNotEmpty
              ? int.tryParse(_umurTanamanController.text)
              : null,
          'estimasiPanen': _estimasiPanenController.text.isNotEmpty
              ? double.tryParse(_estimasiPanenController.text)
              : null,
          'gagalPanen': _gagalPanenController.text.isNotEmpty
              ? double.tryParse(_gagalPanenController.text)
              : null,
          'realisasiPanen': totalRealisasiPanen,
          'rincianGrade': _rincianGradeList
              .map((rincian) => {
                    'gradeId': rincian.gradeId,
                    'jumlah': double.parse(rincian.jumlahController.text),
                  })
              .toList(),
        }
      };
      final response = await _laporanService.createLaporanPanenKebun(payload);
      if (mounted) {
        if (response['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Laporan Panen ${widget.data?['unitBudidaya']?['name'] ?? ''} - ${widget.data?['komoditas']?['name'] ?? ''} berhasil dikirim!'),
              backgroundColor: Colors.green,
            ),
          );

          // Pop sebanyak step yang telah dilalui + halaman ini
          for (int i = 0; i < (widget.step + 1); i++) {
            // +1 untuk pop halaman form ini sendiri
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              break;
            }
          }
        } else {
          _showError(response['message'] ?? 'Gagal mengirim laporan panen.');
        }
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _umurTanamanController.dispose();
    _estimasiPanenController.dispose();
    _gagalPanenController.dispose();
    for (var rincian in _rincianGradeList) {
      rincian.jumlahController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            greeting: 'Pelaporan Hasil Panen',
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
                  title: 'Step ${widget.step} - Isi Form Pelaporan Panen',
                  subtitle:
                      'Harap mengisi form dengan data yang benar sesuai  kondisi lapangan!',
                  showDate: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Komoditas Tanaman',
                          style: semibold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (widget.data?['komoditas']?['name'] ?? '-'),
                          style: bold20.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.data?['komoditas']?['jenisBudidayaLatin'] ?? '-'} - ${widget.data?['unitBudidaya']?['name'] ?? '-'}',
                          style: semibold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tanggal dan waktu tanam: ${(() {
                            final createdAtRaw =
                                widget.data?['unitBudidaya']?['createdAt'];
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
                        const Divider(),
                        Text("Detail Kejadian Panen",
                            style: bold18.copyWith(color: dark1)),
                        const SizedBox(height: 12),
                        InputFieldWidget(
                          label: "Tanggal panen dilakukan",
                          hint: "Contoh: Senin, 17 Februari 2025",
                          controller: TextEditingController(
                              text: DateFormat('EEEE, dd MMMM yyyy')
                                  .format(_tanggalPanen)),
                          suffixIcon: const Icon(Icons.calendar_today),
                          isDisabled: true,
                          onSuffixIconTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggalPanen,
                              firstDate: DateTime(2000),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null && picked != _tanggalPanen) {
                              setState(() {
                                _tanggalPanen = picked;
                                _calculateAndUpdateUmurTanaman();
                              });
                            }
                          },
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Tanggal & waktu kadaluwarsa tidak boleh kosong'
                              : null,
                        ),
                        InputFieldWidget(
                          label: "Umur tanaman saat panen (hari)",
                          hint: "Contoh: 90",
                          controller: _umurTanamanController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                int.tryParse(value) == null) {
                              return 'Harus berupa angka';
                            }
                            if (value != null &&
                                value.isNotEmpty &&
                                int.tryParse(value)! <= 0) {
                              return 'Umur tanaman harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        InputFieldWidget(
                          label: "Estimasi total panen (sebelum panen)",
                          hint: "Contoh: 100",
                          controller: _estimasiPanenController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                double.tryParse(value) == null) {
                              return 'Harus berupa angka';
                            }
                            if (value != null &&
                                value.isNotEmpty &&
                                double.tryParse(value)! <= 0) {
                              return 'Estimasi panen harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        InputFieldWidget(
                          label: "Kuantitas gagal panen (jika ada)",
                          hint: "Contoh: 5",
                          controller: _gagalPanenController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                double.tryParse(value) == null) {
                              return 'Harus berupa angka';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() {}),
                        ),
                        DropdownFieldWidget(
                          label: "Satuan panen",
                          hint: "Pilih satuan panen",
                          items:
                              satuanData != null ? [satuanData!['nama']] : [],
                          selectedValue:
                              satuanData != null ? satuanData!['nama'] : '-',
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
                          image: _image,
                          onPickImage: (ctx) async {
                            await _pickImage(ctx);
                          },
                        ),
                        InputFieldWidget(
                          label: "Catatan/jurnal pelaporan",
                          hint: "Keterangan",
                          controller: _catatanController,
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Catatan wajib diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Rincian Hasil Panen per Grade",
                                style: bold18.copyWith(color: dark1)),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: green1),
                              onPressed: _tambahRincianGrade,
                              tooltip: "Tambah Rincian Grade",
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingGrade)
                          const Center(child: CircularProgressIndicator())
                        else if (_gradeMasterList.isEmpty)
                          const Text(
                              "Data master grade tidak ditemukan. Tidak dapat menambahkan rincian.")
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _rincianGradeList.length,
                            itemBuilder: (context, index) {
                              final rincian = _rincianGradeList[index];
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    DropdownFieldWidget(
                                      key: rincian.gradeFieldKey,
                                      label: 'Pilih Grade Kualitas',
                                      hint: 'Pilih Grade',
                                      items: _gradeMasterList
                                          .map((grade) =>
                                              grade['nama'].toString())
                                          .toList(),
                                      selectedValue: rincian.gradeNama,
                                      onChanged: (String? selectedNamaGrade) {
                                        setState(() {
                                          rincian.gradeNama = selectedNamaGrade;
                                          if (selectedNamaGrade != null &&
                                              _gradeMasterList.any((g) =>
                                                  g['nama'] ==
                                                  selectedNamaGrade)) {
                                            rincian.gradeId = _gradeMasterList
                                                    .firstWhere((grade) =>
                                                        grade['nama'] ==
                                                        selectedNamaGrade)['id']
                                                as String?;
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
                                    InputFieldWidget(
                                      key: rincian.jumlahFieldKey,
                                      label: "Jumlah kuantitas grade ini",
                                      hint: "Contoh: 5",
                                      controller: rincian.jumlahController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Jumlah wajib diisi';
                                        }
                                        final sanitizedValue =
                                            value.replaceAll(',', '.');
                                        if (double.tryParse(sanitizedValue) ==
                                            null) {
                                          return 'Harus angka';
                                        }
                                        if (double.parse(sanitizedValue) <= 0) {
                                          return 'Harus > 0';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                    if (_rincianGradeList.length > 1)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          icon: Icon(Icons.delete_outline,
                                              color: red, size: 24),
                                          label: Text('Hapus Grade',
                                              style: regular14.copyWith(
                                                  color: red)),
                                          onPressed: () =>
                                              _hapusRincianGrade(index),
                                          style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Realisasi Panen:",
                                style: semibold16.copyWith(color: dark1),
                              ),
                              Text(
                                _isLoadingSatuan
                                    ? "Menghitung..."
                                    : "${_calculateTotalRealisasiPanen().toStringAsFixed(1)} ${satuanData!['nama'] ?? ''}",
                                style: bold18.copyWith(color: green1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
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
