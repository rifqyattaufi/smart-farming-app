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

class AddKebunScreen extends StatefulWidget {
  final VoidCallback? onKebunAdded;
  final bool isEdit;
  final String? idKebun;

  const AddKebunScreen(
      {super.key, this.onKebunAdded, this.isEdit = false, this.idKebun});

  @override
  _AddKebunScreenState createState() => _AddKebunScreenState();
}

class _AddKebunScreenState extends State<AddKebunScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final ScheduleUnitNotificationService _scheduleUnitNotification =
      ScheduleUnitNotificationService();
  final ImageService _imageService = ImageService();

  final _formKey = GlobalKey<FormState>();
  String? selectedJenisTanaman;
  String statusKebun = 'Aktif';
  List<Map<String, dynamic>> jenisTanamanList = [];
  String notifikasiPanen = 'Tidak Aktif';
  String notifikasiNutrisi = 'Tidak Aktif';
  String? selectedHariPanen;
  String? selectedHariNutrisi;
  String? initialJumlahTanaman;

  File? _image;
  final picker = ImagePicker();
  bool _isPickingImage = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _waktuNotifikasiPanenController =
      TextEditingController();
  final TextEditingController _waktuNotifikasiNutrisiController =
      TextEditingController();
  final TextEditingController _tanggalNotifikasiPanenController =
      TextEditingController();
  final TextEditingController _tanggalNotifikasiNutrisiController =
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

  String? panenId;
  String? nutrisiId;

  Future<void> _pickImage(BuildContext context) async {
    if (_isPickingImage) return;

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
              key: const Key('camera_option'),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                await _handleImagePick(context, ImageSource.camera);
              },
            ),
            ListTile(
              key: const Key('gallery_option'),
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _handleImagePick(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImagePick(
      BuildContext context, ImageSource source) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  Future<void> _getJenisTanaman() async {
    final response =
        await _jenisBudidayaService.getJenisBudidayaByTipe('tumbuhan');
    if (response['status'] == true) {
      final List<dynamic> data = response['data'];
      setState(() {
        jenisTanamanList = data.map((item) {
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

  Future<void> _fetchKebun() async {
    final response =
        await _unitBudidayaService.getUnitBudidayaById(widget.idKebun!);

    if (response['status'] == true) {
      final data = response['data']['unitBudidaya'];
      setState(() {
        _nameController.text = data['nama'];
        _locationController.text = data['lokasi'];
        _sizeController.text = data['luas'].toString();
        _jumlahController.text = data['jumlah'].toString();
        initialJumlahTanaman = data['jumlah'].toString();
        statusKebun = data['status'] ? 'Aktif' : 'Tidak Aktif';
        _descriptionController.text = data['deskripsi'];
        selectedJenisTanaman = data['JenisBudidayaId'].toString();
        imageUrl = {'data': data['gambar']};
      });

      final notifikasi = await _scheduleUnitNotification
          .getScheduleUnitNotificationByUnitBudidaya(widget.idKebun ?? '');
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
    _getJenisTanaman();
    if (widget.isEdit) {
      _fetchKebun();
    }
  }

  Future<void> _submitKebun() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (_image == null && !widget.isEdit) {
        showAppToast(context,
            'Gambar kebun tidak boleh kosong. Silakan unggah gambar kebun.');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      if (_image != null) {
        imageUrl = await _imageService.uploadImage(_image!);
      }

      final data = {
        'jenisBudidayaId': selectedJenisTanaman,
        'nama': _nameController.text,
        'lokasi': _locationController.text,
        'tipe': 'individu',
        'luas': _sizeController.text,
        'jumlah': _jumlahController.text,
        'status': statusKebun == 'Aktif',
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

      Map<String, dynamic> response;

      if (widget.isEdit) {
        data['id'] = widget.idKebun;
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
        if (widget.onKebunAdded != null) {
          widget.onKebunAdded!();
        }

        showAppToast(
          context,
          widget.isEdit
              ? 'Berhasil memperbarui data kebun'
              : 'Berhasil menambahkan data kebun',
          isError: false,
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });

        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
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
                key: const Key('cancel_button'),
                child: const Text('Batal'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                key: const Key('select_button'),
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
              title: 'Manajemen Kebun',
              greeting: widget.isEdit ? 'Edit Kebun' : 'Tambah Kebun'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                    key: const Key('nama_kebun'),
                    label: "Nama kebun",
                    hint: "Contoh: Kebun A",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Kebun tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                      key: const Key('lokasi_kebun'),
                      label: "Lokasi kebun",
                      hint: "Contoh: Rooftop",
                      controller: _locationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi Kebun tidak boleh kosong';
                        }
                        return null;
                      }),
                  InputFieldWidget(
                    key: const Key('luas_kebun'),
                    label: "Luas kebun",
                    hint: "Contoh: 30 m²",
                    controller: _sizeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Luas Kebun tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Luas Kebun harus berupa angka';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Luas Kebun harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  DropdownFieldWidget(
                    key: const Key('jenis_tanaman'),
                    label: "Pilih jenis tanaman yang ditanam",
                    hint: "Pilih jenis tanaman",
                    items: jenisTanamanList
                        .map((item) => item['nama'] as String)
                        .toList(),
                    selectedValue: jenisTanamanList.firstWhere(
                      (item) => item['id'] == selectedJenisTanaman,
                      orElse: () => {'nama': null},
                    )['nama'],
                    onChanged: (value) {
                      setState(() {
                        selectedJenisTanaman = jenisTanamanList.firstWhere(
                          (item) => item['nama'] == value,
                          orElse: () => {'id': null},
                        )['id']; // Simpan id dari item yang dipilih
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jenis tanaman tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                    key: const Key('jumlah_tanaman'),
                    label: "Jumlah tanaman",
                    hint: "Contoh: 20 (satuan tanaman)",
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    isDisabled: initialJumlahTanaman == null ||
                            int.tryParse(initialJumlahTanaman ?? '') == 0
                        ? false
                        : true,
                    isGrayed: initialJumlahTanaman == null ||
                            int.tryParse(initialJumlahTanaman ?? '') == 0
                        ? false
                        : true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tanaman tidak boleh kosong';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Jumlah tanaman harus berupa angka';
                      }
                      if (int.parse(value) <= 0) {
                        return 'Jumlah tanaman harus lebih besar dari 0';
                      }
                      return null;
                    },
                  ),
                  RadioField(
                    key: const Key('status_kebun'),
                    label: 'Status kebun',
                    selectedValue: statusKebun,
                    options: const ['Aktif', 'Tidak aktif'],
                    onChanged: (value) {
                      setState(() {
                        statusKebun = value;
                      });
                    },
                  ),
                  ImagePickerWidget(
                    key: const Key('image_picker_kebun'),
                    label: "Unggah gambar kebun",
                    image: _image,
                    imageUrl: imageUrl['data'],
                    onPickImage: _pickImage,
                  ),
                  InputFieldWidget(
                    key: const Key('deskripsi_kebun'),
                    label: "Deskripsi kebun",
                    hint: "Keterangan",
                    controller: _descriptionController,
                    maxLines: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi kebun tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text("Pengaturan Notifikasi",
                      style: bold18.copyWith(color: dark1)),
                  const SizedBox(height: 16),
                  RadioField(
                    key: const Key('notifikasi_panen'),
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
                      key: const Key('tipe_notifikasi_panen'),
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
                      key: const Key('waktu_notifikasi_panen'),
                      label: "Waktu Notifikasi",
                      hint: "Contoh: 08:00",
                      controller: _waktuNotifikasiPanenController,
                      isDisabled: true,
                      suffixIcon: const Icon(Icons.access_time),
                      onSuffixIconTap: () async {
                        TimeOfDay initialTime = TimeOfDay.now();
                        if (_waktuNotifikasiPanenController.text.isNotEmpty) {
                          final parts =
                              _waktuNotifikasiPanenController.text.split(':');
                          if (parts.length == 2) {
                            final hour = int.tryParse(parts[0]) ?? 0;
                            final minute = int.tryParse(parts[1]) ?? 0;
                            initialTime = TimeOfDay(hour: hour, minute: minute);
                          }
                        }
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            final hour =
                                pickedTime.hour.toString().padLeft(2, '0');
                            final minute =
                                pickedTime.minute.toString().padLeft(2, '0');
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
                        key: const Key('hari_notifikasi_panen'),
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
                        key: const Key('tanggal_notifikasi_panen'),
                        label: "Tanggal Notifikasi",
                        hint: "Contoh: 1 (tanggal dalam bulan)",
                        controller: _tanggalNotifikasiPanenController,
                        isDisabled: true,
                        suffixIcon: const Icon(Icons.calendar_today),
                        onSuffixIconTap: () async {
                          _showDayOfMonthPicker(
                                  context,
                                  int.tryParse(
                                      _waktuNotifikasiPanenController.text))
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
                    key: const Key('notifikasi_nutrisi'),
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
                      key: const Key('tipe_notifikasi_nutrisi'),
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
                      key: const Key('waktu_notifikasi_nutrisi'),
                      label: "Waktu Notifikasi",
                      hint: "Contoh: 08:00",
                      controller: _waktuNotifikasiNutrisiController,
                      isDisabled: true,
                      suffixIcon: const Icon(Icons.access_time),
                      onSuffixIconTap: () async {
                        TimeOfDay initialTime = TimeOfDay.now();
                        if (_waktuNotifikasiNutrisiController.text.isNotEmpty) {
                          final parts =
                              _waktuNotifikasiNutrisiController.text.split(':');
                          if (parts.length == 2) {
                            final hour = int.tryParse(parts[0]) ?? 0;
                            final minute = int.tryParse(parts[1]) ?? 0;
                            initialTime = TimeOfDay(hour: hour, minute: minute);
                          }
                        }
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialTime,
                        );
                        if (pickedTime != null) {
                          setState(() {
                            final hour =
                                pickedTime.hour.toString().padLeft(2, '0');
                            final minute =
                                pickedTime.minute.toString().padLeft(2, '0');
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
                        key: const Key('hari_notifikasi_nutrisi'),
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
                        key: const Key('tanggal_notifikasi_nutrisi'),
                        label: "Tanggal Notifikasi",
                        hint: "Contoh: 1 (tanggal dalam bulan)",
                        controller: _tanggalNotifikasiNutrisiController,
                        isDisabled: true,
                        suffixIcon: const Icon(Icons.calendar_today),
                        onSuffixIconTap: () async {
                          _showDayOfMonthPicker(
                                  context,
                                  int.tryParse(
                                      _waktuNotifikasiNutrisiController.text))
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            onPressed: _submitKebun,
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: _isLoading,
            key: const Key('submit_kebun'),
          ),
        ),
      ),
    );
  }
}
