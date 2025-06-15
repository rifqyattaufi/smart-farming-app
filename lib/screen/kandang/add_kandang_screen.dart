import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/schedule_unit_notification_service.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'dart:io';

import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/day_of_month_picker.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/img_picker.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddKandangScreen extends StatefulWidget {
  final VoidCallback? onKandangAdded;
  final bool isEdit;
  final String? idKandang;

  const AddKandangScreen(
      {super.key, this.onKandangAdded, this.isEdit = false, this.idKandang});

  @override
  _AddKandangScreenState createState() => _AddKandangScreenState();
}

class _AddKandangScreenState extends State<AddKandangScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final ScheduleUnitNotificationService _scheduleUnitNotification =
      ScheduleUnitNotificationService();
  final ImageService _imageService = ImageService();

  final _formKey = GlobalKey<FormState>();
  String? selectedJenisHewan;
  String statusKandang = 'Aktif';
  String jenisPencatatan = 'Individu';
  String notifikasiPanen = 'Tidak Aktif';
  String notifikasiNutrisi = 'Tidak Aktif';
  String? selectedHariPanen;
  String? selectedHariNutrisi;
  List<Map<String, dynamic>> jenisHewanList = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _waktuNotifikasiPanenController =
      TextEditingController();
  final TextEditingController _waktuNotifikasiNutrisiController =
      TextEditingController();
  final TextEditingController _tanggalNotifikasiNutrisiController =
      TextEditingController();
  final TextEditingController _tanggalNotifikasiPanenController =
      TextEditingController();
  Map<String, dynamic> imageUrl = {};
  String selectedTipePanen = '';
  String selectedTipeNutrisi = '';

  final Map<String, int?> dayToInt = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7,
  };
  final Map<String, String> notificationType = {
    'Harian': 'daily',
    'Mingguan': 'weekly',
    'Bulanan': 'monthly',
  };
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  String? panenId;
  String? nutrisiId;

  Future<void> _pickImage(BuildContext context) async {
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
              key: const Key('open_camera'),
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
              key: const Key('open_gallery'),
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

  Future<void> _getJenisHewan() async {
    final response =
        await _jenisBudidayaService.getJenisBudidayaByTipe('hewan');
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        jenisHewanList = data.map((item) {
          return {
            'id': item['id'],
            'nama': item['nama'],
          };
        }).toList();
      });
    } else {
      showAppToast(
          context, response['message'] ?? 'Terjadi kesalahan tidak diketahui');
    }
  }

  Future<void> _fetchKandang() async {
    final response =
        await _unitBudidayaService.getUnitBudidayaById(widget.idKandang ?? '');

    if (response['status'] == true) {
      final data = response['data']['unitBudidaya'];
      setState(() {
        _nameController.text = data['nama'] ?? '';
        _locationController.text = data['lokasi'] ?? '';
        _sizeController.text = data['luas']?.toString() ?? '';
        _jumlahController.text = data['jumlah']?.toString() ?? '';
        _descriptionController.text = data['deskripsi'] ?? '';
        statusKandang = data['status'] == true ? 'Aktif' : 'Tidak aktif';
        jenisPencatatan = data['tipe'] == 'individu' ? 'Individu' : 'Kolektif';
        selectedJenisHewan = data['JenisBudidayaId'].toString();
        imageUrl = {
          'data': data['gambar'],
        };
      });

      final notifikasi = await _scheduleUnitNotification
          .getScheduleUnitNotificationByUnitBudidaya(widget.idKandang ?? '');
      if (notifikasi['status'] == true) {
        final dataPanen = (notifikasi['data'] as List).firstWhere(
            (item) => item['tipeLaporan'] == 'panen',
            orElse: () => null);
        final dataNutrisi = (notifikasi['data'] as List).firstWhere(
            (item) => item['tipeLaporan'] == 'vitamin',
            orElse: () => null);

        if (dataPanen != null) {
          setState(() {
            panenId = dataPanen['id'];
            notifikasiPanen = 'Aktif';
            selectedTipePanen = notificationType.entries
                .firstWhere(
                    (entry) => entry.value == dataPanen['notificationType'],
                    orElse: () => const MapEntry('', ''))
                .key;
            if (dataPanen['scheduledTime'] != null &&
                dataPanen['scheduledTime'].toString().isNotEmpty) {
              final timeParts =
                  dataPanen['scheduledTime'].toString().split(':');
              if (timeParts.length >= 2) {
                _waktuNotifikasiPanenController.text =
                    '${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}';
              } else {
                _waktuNotifikasiPanenController.text =
                    dataPanen['scheduledTime'];
              }
            } else {
              _waktuNotifikasiPanenController.text = '';
            }
            _tanggalNotifikasiPanenController.text =
                dataPanen['dayOfMonth']?.toString() ?? '';
            selectedHariPanen = dayToInt.entries
                .firstWhere((entry) => entry.value == dataPanen['dayOfWeek'],
                    orElse: () => const MapEntry('', null))
                .key;
          });
        }

        if (dataNutrisi != null) {
          setState(() {
            nutrisiId = dataNutrisi['id'];
            notifikasiNutrisi = 'Aktif';
            selectedTipeNutrisi = notificationType.entries
                .firstWhere(
                    (entry) => entry.value == dataNutrisi['notificationType'],
                    orElse: () => const MapEntry('', ''))
                .key;
            if (dataNutrisi['scheduledTime'] != null &&
                dataNutrisi['scheduledTime'].toString().isNotEmpty) {
              final timeParts =
                  dataNutrisi['scheduledTime'].toString().split(':');
              if (timeParts.length >= 2) {
                _waktuNotifikasiNutrisiController.text =
                    '${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}';
              } else {
                _waktuNotifikasiNutrisiController.text =
                    dataNutrisi['scheduledTime'];
              }
            } else {
              _waktuNotifikasiNutrisiController.text = '';
            }
            _tanggalNotifikasiNutrisiController.text =
                dataNutrisi['dayOfMonth']?.toString() ?? '';
            selectedHariNutrisi = dayToInt.entries
                .firstWhere((entry) => entry.value == dataNutrisi['dayOfWeek'],
                    orElse: () => const MapEntry('', null))
                .key;
          });
        }
      }
    } else {
      showAppToast(
          context, response['message'] ?? 'Terjadi kesalahan tidak diketahui');
    }
  }

  @override
  void initState() {
    super.initState();
    _getJenisHewan();
    if (widget.isEdit) {
      _fetchKandang();
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_image == null && !widget.isEdit) {
        showAppToast(context, 'Gambar kandang tidak boleh kosong');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_image != null) {
        imageUrl = await _imageService.uploadImage(_image!);
      }

      final data = {
        'jenisBudidayaId': selectedJenisHewan,
        'nama': _nameController.text,
        'lokasi': _locationController.text,
        'tipe': jenisPencatatan,
        'luas': _sizeController.text,
        'jumlah': _jumlahController.text,
        'status': statusKandang == 'Aktif',
        'deskripsi': _descriptionController.text,
        'gambar': imageUrl['data'],
        'notifikasi': {
          'panen': notifikasiPanen == 'Aktif'
              ? {
                  'isActive': true,
                  'notificationType': notificationType[selectedTipePanen],
                  'scheduledTime': _waktuNotifikasiPanenController.text,
                  'dayOfMonth': _tanggalNotifikasiPanenController.text,
                  'dayOfWeek': dayToInt[selectedHariPanen],
                }
              : null,
          'vitamin': notifikasiNutrisi == 'Aktif'
              ? {
                  'isActive': true,
                  'notificationType': notificationType[selectedTipeNutrisi],
                  'scheduledTime': _waktuNotifikasiNutrisiController.text,
                  'dayOfMonth': _tanggalNotifikasiNutrisiController.text,
                  'dayOfWeek': dayToInt[selectedHariNutrisi],
                }
              : null,
        }
      };

      Map<String, dynamic>? response;

      if (widget.isEdit) {
        data['id'] = widget.idKandang;
        if (notifikasiPanen == 'Aktif') {
          data['notifikasi']['panen']['id'] = panenId;
        }
        if (notifikasiNutrisi == 'Aktif') {
          data['notifikasi']['vitamin']['id'] = nutrisiId;
        }
        response = await _unitBudidayaService.updateUnitBudidaya(data);
      } else {
        response = await _unitBudidayaService.createUnitBudidaya(data);
      }

      if (response['status'] == true) {
        if (widget.onKandangAdded != null) {
          widget.onKandangAdded!();
        }

        showAppToast(
          context,
          widget.isEdit
              ? 'Berhasil memperbarui data kandang'
              : 'Berhasil menambahkan data kandang',
          isError: false,
        );
        Navigator.pop(context);
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
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

  Future<int?> _showDayOfMonthPicker(
      BuildContext context, int? selectedDay) async {
    final int? pickedDay = await showDialog<int>(
        context: context,
        builder: (BuildContext dialogContext) {
          int? tempPickedDay = selectedDay;
          return AlertDialog(
            title: const Text('Pilih Tanggal Notifikasi'),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: DayOfMonthPicker(
                    initialSelectedDay: tempPickedDay,
                    onDaySelected: (day) {
                      tempPickedDay = day;
                    }),
              ),
            ),
            actions: <Widget>[
              TextButton(
                key: const Key('cancelButton'),
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                key: const Key('selectButton'),
                child: const Text('Pilih'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(tempPickedDay);
                },
              ),
            ],
          );
        });

    return pickedDay;
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
          title: Header(
              headerType: HeaderType.back,
              title: 'Manajemen Kandang',
              greeting: widget.isEdit ? 'Edit Kandang' : 'Tambah Kandang'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Informasi Kandang",
                            style: bold18.copyWith(color: dark1)),
                        const SizedBox(height: 16),
                        InputFieldWidget(
                          key: const Key('nama_kandang_input'),
                          label: "Nama kandang",
                          hint: "Contoh: kandang A",
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama kandang tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        InputFieldWidget(
                            key: const Key('lokasi_kandang_input'),
                            label: "Lokasi kandang",
                            hint: "Contoh: Rooftop",
                            controller: _locationController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lokasi kandang tidak boleh kosong';
                              }
                              return null;
                            }),
                        InputFieldWidget(
                            key: const Key('luas_kandang_input'),
                            label: "Luas kandang",
                            hint: "Contoh: 30m²",
                            controller: _sizeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Luas kandang tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Luas kandang harus berupa angka';
                              }
                              return null;
                            }),
                        DropdownFieldWidget(
                          key: const Key('jenis_hewan_dropdown'),
                          label: "Pilih jenis hewan yang diternak",
                          hint: "Pilih jenis hewan ternak",
                          items: jenisHewanList
                              .map((item) => item['nama'] as String)
                              .toList(),
                          selectedValue: jenisHewanList.firstWhere(
                              (item) => item['id'] == selectedJenisHewan,
                              orElse: () => {'nama': null})['nama'],
                          onChanged: (value) {
                            setState(() {
                              selectedJenisHewan = jenisHewanList.firstWhere(
                                (item) => item['nama'] == value,
                                orElse: () => {'id': null},
                              )['id'];
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis hewan tidak boleh kosong';
                            }
                            return null;
                          },
                          isEdit: widget.isEdit,
                        ),
                        InputFieldWidget(
                            key: const Key('jumlah_hewan_input'),
                            label: "Jumlah hewan ternak",
                            hint: "Contoh: 20 (satuan ekor)",
                            controller: _jumlahController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah hewan tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Jumlah hewan harus berupa angka';
                              }
                              return null;
                            }),
                        RadioField(
                          key: const Key('status_kandang_radio'),
                          label: 'Status kandang',
                          selectedValue: statusKandang,
                          options: const ['Aktif', 'Tidak aktif'],
                          onChanged: (value) {
                            setState(() {
                              statusKandang = value;
                            });
                          },
                        ),
                        RadioField(
                          key: const Key('jenis_pencatatan_radio'),
                          label: 'Jenis Pencatatan',
                          selectedValue: jenisPencatatan,
                          options: const ['Individu', 'Kolektif'],
                          onChanged: (value) {
                            setState(() {
                              jenisPencatatan = value;
                            });
                          },
                        ),
                        ImagePickerWidget(
                          key: const Key('image_picker_kandang'),
                          label: "Unggah gambar kandang",
                          image: _image,
                          onPickImage: _pickImage,
                        ),
                        InputFieldWidget(
                            key: const Key('deskripsi_kandang_input'),
                            label: "Deskripsi kandang",
                            hint: "Keterangan",
                            controller: _descriptionController,
                            maxLines: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Deskripsi kandang tidak boleh kosong';
                              }
                              return null;
                            }),
                        const SizedBox(height: 16),
                        Text("Pengaturan Notifikasi",
                            style: bold18.copyWith(color: dark1)),
                        const SizedBox(height: 16),
                        RadioField(
                          key: const Key('notifikasi_panen_radio'),
                          label: 'Notifikasi Pengingat Panen',
                          selectedValue: notifikasiPanen,
                          options: const ['Aktif', 'Tidak Aktif'],
                          onChanged: (value) {
                            setState(() {
                              notifikasiPanen = value;
                              selectedTipePanen = '';
                              selectedHariPanen = null;
                              _tanggalNotifikasiPanenController.clear();
                              _waktuNotifikasiPanenController.clear();
                            });
                          },
                        ),
                        if (notifikasiPanen == 'Aktif') ...[
                          DropdownFieldWidget(
                            key: const Key('tipe_notifikasi_dropdown'),
                            label: "Tipe Notifikasi",
                            hint: "Pilih Tipe Notifikasi",
                            items: notificationType.keys.toList(),
                            selectedValue: selectedTipePanen,
                            onChanged: (value) {
                              setState(() {
                                selectedTipePanen = value!;
                                selectedHariPanen = null;
                                _tanggalNotifikasiPanenController.clear();
                              });
                            },
                            validator: (value) {
                              if (notifikasiPanen == 'Aktif' &&
                                  (value == null || value.isEmpty)) {
                                return 'Tipe notifikasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          InputFieldWidget(
                            key: const Key('waktu_notifikasi_input'),
                            label: "Waktu Notifikasi",
                            hint: "Contoh: 08:00",
                            controller: _waktuNotifikasiPanenController,
                            isDisabled: true,
                            suffixIcon: const Icon(Icons.access_time),
                            onSuffixIconTap: () async {
                              TimeOfDay initialTime = TimeOfDay.now();
                              if (_waktuNotifikasiPanenController
                                  .text.isNotEmpty) {
                                final parts = _waktuNotifikasiPanenController
                                    .text
                                    .split(':');
                                if (parts.length == 2) {
                                  final hour = int.tryParse(parts[0]) ?? 0;
                                  final minute = int.tryParse(parts[1]) ?? 0;
                                  initialTime =
                                      TimeOfDay(hour: hour, minute: minute);
                                }
                              }
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  final hour = pickedTime.hour
                                      .toString()
                                      .padLeft(2, '0');
                                  final minute = pickedTime.minute
                                      .toString()
                                      .padLeft(2, '0');
                                  _waktuNotifikasiPanenController.text =
                                      '$hour:$minute';
                                });
                              }
                            },
                            validator: (value) {
                              if (notifikasiPanen == 'Aktif' &&
                                  (value == null || value.isEmpty)) {
                                return 'Waktu notifikasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          if (selectedTipePanen == 'Mingguan')
                            DropdownFieldWidget(
                              key: const Key('hari_notifikasi_dropdown'),
                              label: "Hari Notifikasi",
                              hint: "Pilih Hari Notifikasi",
                              items: dayToInt.keys.toList(),
                              selectedValue: selectedHariPanen,
                              onChanged: (value) {
                                setState(() {
                                  selectedHariPanen = value;
                                });
                              },
                              validator: (value) {
                                if (notifikasiPanen == 'Aktif' &&
                                    selectedTipePanen == 'Mingguan' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Hari notifikasi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          if (selectedTipePanen == 'Bulanan') ...[
                            InputFieldWidget(
                              key: const Key('tanggal_notifikasi_input'),
                              label: "Tanggal Notifikasi",
                              hint: "Contoh: 1 (tanggal dalam bulan)",
                              controller: _tanggalNotifikasiPanenController,
                              isDisabled: true,
                              suffixIcon: const Icon(Icons.calendar_today),
                              onSuffixIconTap: () async {
                                _showDayOfMonthPicker(
                                        context,
                                        int.tryParse(
                                            _waktuNotifikasiPanenController
                                                .text))
                                    .then((pickedDay) {
                                  if (pickedDay != null) {
                                    setState(() {
                                      _tanggalNotifikasiPanenController.text =
                                          pickedDay.toString();
                                    });
                                  }
                                });
                              },
                              validator: (value) {
                                if (notifikasiPanen == 'Aktif' &&
                                    selectedTipePanen == 'Bulanan' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Tanggal notifikasi tidak boleh kosong';
                                }
                                return null;
                              },
                            )
                          ]
                        ],
                        RadioField(
                          key: const Key('notifikasi_nutrisi_radio'),
                          label: 'Notifikasi Pengingat Pemberian Nutrisi',
                          selectedValue: notifikasiNutrisi,
                          options: const ['Aktif', 'Tidak Aktif'],
                          onChanged: (value) {
                            setState(() {
                              notifikasiNutrisi = value;
                              selectedTipeNutrisi = '';
                              selectedHariNutrisi = null;
                              _tanggalNotifikasiNutrisiController.clear();
                              _waktuNotifikasiNutrisiController.clear();
                            });
                          },
                        ),
                        if (notifikasiNutrisi == 'Aktif') ...[
                          DropdownFieldWidget(
                            key: const Key('tipe_notifikasi_nutrisi_dropdown'),
                            label: "Tipe Notifikasi",
                            hint: "Pilih Tipe Notifikasi",
                            items: notificationType.keys.toList(),
                            selectedValue: selectedTipeNutrisi,
                            onChanged: (value) {
                              setState(() {
                                selectedTipeNutrisi = value!;
                                selectedHariNutrisi = null;
                                _tanggalNotifikasiNutrisiController.clear();
                              });
                            },
                            validator: (value) {
                              if (notifikasiNutrisi == 'Aktif' &&
                                  (value == null || value.isEmpty)) {
                                return 'Tipe notifikasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          InputFieldWidget(
                            key: const Key('waktu_notifikasi_nutrisi_input'),
                            label: "Waktu Notifikasi",
                            hint: "Contoh: 08:00",
                            controller: _waktuNotifikasiNutrisiController,
                            isDisabled: true,
                            suffixIcon: const Icon(Icons.access_time),
                            onSuffixIconTap: () async {
                              TimeOfDay initialTime = TimeOfDay.now();
                              if (_waktuNotifikasiNutrisiController
                                  .text.isNotEmpty) {
                                final parts = _waktuNotifikasiNutrisiController
                                    .text
                                    .split(':');
                                if (parts.length == 2) {
                                  final hour = int.tryParse(parts[0]) ?? 0;
                                  final minute = int.tryParse(parts[1]) ?? 0;
                                  initialTime =
                                      TimeOfDay(hour: hour, minute: minute);
                                }
                              }
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: initialTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  final hour = pickedTime.hour
                                      .toString()
                                      .padLeft(2, '0');
                                  final minute = pickedTime.minute
                                      .toString()
                                      .padLeft(2, '0');
                                  _waktuNotifikasiNutrisiController.text =
                                      '$hour:$minute';
                                });
                              }
                            },
                            validator: (value) {
                              if (notifikasiNutrisi == 'Aktif' &&
                                  (value == null || value.isEmpty)) {
                                return 'Waktu notifikasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          if (selectedTipeNutrisi == 'Mingguan')
                            DropdownFieldWidget(
                              key: const Key('hari_notifikasi_nutrisi_dropdown'),
                              label: "Hari Notifikasi",
                              hint: "Pilih Hari Notifikasi",
                              items: dayToInt.keys.toList(),
                              selectedValue: selectedHariNutrisi,
                              onChanged: (value) {
                                setState(() {
                                  selectedHariNutrisi = value;
                                });
                              },
                              validator: (value) {
                                if (notifikasiNutrisi == 'Aktif' &&
                                    selectedTipeNutrisi == 'Mingguan' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Hari notifikasi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          if (selectedTipeNutrisi == 'Bulanan')
                            InputFieldWidget(
                              key: const Key('tanggal_notifikasi_nutrisi_input'),
                              label: "Tanggal Notifikasi",
                              hint: "Contoh: 1 (tanggal dalam bulan)",
                              controller: _tanggalNotifikasiNutrisiController,
                              isDisabled: true,
                              suffixIcon: const Icon(Icons.calendar_today),
                              onSuffixIconTap: () async {
                                _showDayOfMonthPicker(
                                        context,
                                        int.tryParse(
                                            _waktuNotifikasiNutrisiController
                                                .text))
                                    .then((pickedDay) {
                                  if (pickedDay != null) {
                                    setState(() {
                                      _tanggalNotifikasiNutrisiController.text =
                                          pickedDay.toString();
                                    });
                                  }
                                });
                              },
                              validator: (value) {
                                if (notifikasiNutrisi == 'Aktif' &&
                                    selectedTipeNutrisi == 'Bulanan' &&
                                    (value == null || value.isEmpty)) {
                                  return 'Tanggal notifikasi tidak boleh kosong';
                                }
                                return null;
                              },
                            )
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CustomButton(
                onPressed: _submitForm,
                backgroundColor: green1,
                textStyle: semibold16,
                textColor: white,
                isLoading: _isLoading,
                key: const Key('submit_kandang_button'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
