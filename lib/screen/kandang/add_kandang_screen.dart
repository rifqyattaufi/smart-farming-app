import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/service/objek_budidaya_service.dart';
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
  AddKandangScreenState createState() => AddKandangScreenState();
}

class AddKandangScreenState extends State<AddKandangScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final ObjekBudidayaService _objekBudidayaService = ObjekBudidayaService();
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
  String? initialJumlahHewan;
  List<Map<String, dynamic>> jenisHewanList = [];
  List<Map<String, dynamic>> allObjekBudidaya = [];
  bool isLoadingObjek = false;
  int totalExistingObjek = 0; // Track total existing objects
  Timer? _debounceTimer;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _kapasitasController = TextEditingController();
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
        _kapasitasController.text = data['kapasitas']?.toString() ?? '';
        _jumlahController.text = data['jumlah']?.toString() ?? '';
        initialJumlahHewan = data['jumlah']?.toString();
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

  Future<void> _fetchObjekBudidaya() async {
    if (widget.idKandang == null) return;

    setState(() {
      isLoadingObjek = true;
    });

    try {
      final response = await _objekBudidayaService
          .getObjekBudidayaByUnitBudidaya(widget.idKandang!);

      if (response['status'] && response['data'] != null) {
        final List<dynamic> existingObjek = response['data'];
        final int capacity = int.tryParse(_kapasitasController.text) ?? 0;

        // Store total existing objects
        totalExistingObjek = existingObjek.length;

        // Create grid items based on capacity
        List<Map<String, dynamic>> gridItems = [];

        // Get jenis budidaya name for slot naming
        String jenisNama = '';
        if (selectedJenisHewan != null && jenisHewanList.isNotEmpty) {
          final jenis = jenisHewanList.firstWhere(
            (item) => item['id'] == selectedJenisHewan,
            orElse: () => {'nama': 'Hewan'},
          );
          jenisNama = jenis['nama'] ?? 'Hewan';
        }

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
              'name': objek['namaId'],
              'gambar': objek['gambar'],
              'isAvailable': true,
              'slotNumber': slotNumber,
            };
          }
        }

        // Create grid items only for empty slots
        for (int i = 1; i <= capacity; i++) {
          if (!slotMap.containsKey(i)) {
            // Slot is empty - create placeholder that can be clicked
            gridItems.add({
              'id': null,
              'namaId': '$jenisNama#$i',
              'name': '$jenisNama#$i',
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
          allObjekBudidaya = [];
          isLoadingObjek = false;
        });
      }
    } catch (e) {
      setState(() {
        allObjekBudidaya = [];
        isLoadingObjek = false;
      });
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  void _debouncedRefreshObjek() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (widget.isEdit &&
          widget.idKandang != null &&
          jenisPencatatan == 'Individu') {
        _fetchObjekBudidaya();
      }
    });
  }

  Widget _buildObjekGrid() {
    if (isLoadingObjek) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark4.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dark3.withValues(alpha: 0.3)),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (allObjekBudidaya.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: dark3.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: dark3.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: dark3, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Semua slot terisi atau belum ada slot kosong',
                style: medium12.copyWith(color: dark3),
              ),
            ),
          ],
        ),
      );
    }

    // Count existing animals from database vs available slots
    final capacity = int.tryParse(_kapasitasController.text) ?? 0;
    final availableSlots = allObjekBudidaya.length; // This is empty slots count
    final filledSlots = totalExistingObjek; // Use the stored count

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show capacity info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: blue1.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: blue1.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: blue1, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kapasitas: $capacity slot | Terisi: $filledSlots hewan | Kosong: $availableSlots slot',
                  style: medium12.copyWith(color: blue1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: allObjekBudidaya.length,
          itemBuilder: (context, index) {
            final objek = allObjekBudidaya[index];

            return GestureDetector(
              onTap: isLoadingObjek
                  ? null
                  : () {
                      _createObjekBudidaya(objek['namaId']);
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: green1.withValues(alpha: 0.1),
                  border: Border.all(
                    color: green1,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: green1,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        objek['namaId']?.toString() ?? 'Slot ${index + 1}',
                        style: regular10.copyWith(
                          color: green1,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _getJenisHewan();
    if (widget.isEdit) {
      _fetchKandang().then((_) {
        if (mounted && jenisPencatatan == 'Individu') {
          _fetchObjekBudidaya();
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      // Additional validation for notification data
      if (notifikasiPanen == 'Aktif') {
        if (selectedTipePanen.isEmpty ||
            _waktuNotifikasiPanenController.text.isEmpty) {
          showAppToast(context, 'Data notifikasi panen tidak lengkap');
          return;
        }
        if (selectedTipePanen == 'Mingguan' && selectedHariPanen == null) {
          showAppToast(context, 'Pilih hari notifikasi untuk tipe mingguan');
          return;
        }
        if (selectedTipePanen == 'Bulanan' &&
            _tanggalNotifikasiPanenController.text.isEmpty) {
          showAppToast(context, 'Pilih tanggal notifikasi untuk tipe bulanan');
          return;
        }
      }

      if (notifikasiNutrisi == 'Aktif') {
        if (selectedTipeNutrisi.isEmpty ||
            _waktuNotifikasiNutrisiController.text.isEmpty) {
          showAppToast(context, 'Data notifikasi nutrisi tidak lengkap');
          return;
        }
        if (selectedTipeNutrisi == 'Mingguan' && selectedHariNutrisi == null) {
          showAppToast(context, 'Pilih hari notifikasi untuk tipe mingguan');
          return;
        }
        if (selectedTipeNutrisi == 'Bulanan' &&
            _tanggalNotifikasiNutrisiController.text.isEmpty) {
          showAppToast(context, 'Pilih tanggal notifikasi untuk tipe bulanan');
          return;
        }
      }

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
        'kapasitas': _kapasitasController.text.isEmpty
            ? null
            : int.tryParse(_kapasitasController.text),
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
                  'dayOfMonth': selectedTipePanen == 'Bulanan'
                      ? (int.tryParse(
                          _tanggalNotifikasiPanenController.text.isEmpty
                              ? '0'
                              : _tanggalNotifikasiPanenController.text))
                      : null,
                  'dayOfWeek': selectedTipePanen == 'Mingguan'
                      ? dayToInt[selectedHariPanen]
                      : null,
                }
              : null,
          'vitamin': notifikasiNutrisi == 'Aktif'
              ? {
                  'isActive': true,
                  'notificationType': notificationType[selectedTipeNutrisi],
                  'scheduledTime': _waktuNotifikasiNutrisiController.text,
                  'dayOfMonth': selectedTipeNutrisi == 'Bulanan'
                      ? (int.tryParse(
                          _tanggalNotifikasiNutrisiController.text.isEmpty
                              ? '0'
                              : _tanggalNotifikasiNutrisiController.text))
                      : null,
                  'dayOfWeek': selectedTipeNutrisi == 'Mingguan'
                      ? dayToInt[selectedHariNutrisi]
                      : null,
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

  Future<void> _createObjekBudidaya(String namaId) async {
    print('_createObjekBudidaya called with namaId: $namaId');

    setState(() {
      isLoadingObjek = true;
    });

    try {
      final response = await _objekBudidayaService.createObjekBudidaya({
        'unitBudidayaId': widget.idKandang,
        'namaId': namaId,
        'jenisBudidayaId': selectedJenisHewan,
      });

      print(
          'Create objek response: ${response['status']}, message: ${response['message']}');

      if (response['status']) {
        // Simply increment the jumlah controller by 1
        final currentJumlah = int.tryParse(_jumlahController.text) ?? 0;
        final newJumlah = currentJumlah + 1;

        // Update totalExistingObjek for validation
        totalExistingObjek = newJumlah;

        setState(() {
          _jumlahController.text = newJumlah.toString();
        });

        print('Updated jumlah from $currentJumlah to $newJumlah');

        // Refresh the grid after successful creation
        await _fetchObjekBudidaya();

        showAppToast(
          context,
          'Berhasil menambahkan $namaId',
          isError: false,
        );
      } else {
        setState(() {
          isLoadingObjek = false;
        });
        showAppToast(context, response['message'] ?? 'Gagal menambahkan objek');
      }
    } catch (e) {
      print('Error in _createObjekBudidaya: $e');
      setState(() {
        isLoadingObjek = false;
      });
      showAppToast(context, 'Terjadi kesalahan: $e');
    }
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
                            hint: "Contoh: 30.5m²",
                            controller: _sizeController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Luas kandang tidak boleh kosong';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Luas kandang harus berupa angka';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Luas kandang harus lebih dari 0';
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
                            // Refresh objek grid when jenis hewan changes
                            _debouncedRefreshObjek();
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
                            label: "Kapasitas Kandang",
                            hint: "Contoh: 50",
                            controller: _kapasitasController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              // Refresh objek grid when capacity changes (debounced)
                              _debouncedRefreshObjek();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kapasitas kandang tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Kapasitas kandang harus berupa angka';
                              }
                              final capacity = int.parse(value);
                              if (capacity <= 0) {
                                return 'Kapasitas kandang harus lebih dari 0';
                              }

                              // Validate capacity against current animal count when editing individual type
                              if (widget.isEdit &&
                                  jenisPencatatan == 'Individu') {
                                // Use totalExistingObjek which contains the actual count of animals
                                if (capacity < totalExistingObjek) {
                                  return 'Kapasitas tidak boleh kurang dari jumlah hewan saat ini ($totalExistingObjek ekor)';
                                }
                              }

                              return null;
                            }),
                        InputFieldWidget(
                            key: const Key('jumlah_hewan_input'),
                            label: "Jumlah hewan ternak",
                            hint: "Contoh: 20 (satuan ekor)",
                            controller: _jumlahController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            isDisabled: initialJumlahHewan == null ||
                                    double.tryParse(initialJumlahHewan ?? '') ==
                                        0
                                ? false
                                : true,
                            isGrayed: initialJumlahHewan == null ||
                                    double.tryParse(initialJumlahHewan ?? '') ==
                                        0
                                ? false
                                : true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah hewan tidak boleh kosong';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Jumlah hewan harus berupa angka';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Jumlah hewan harus lebih dari 0';
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
                            // Refresh objek grid when type changes to/from individual
                            if (value == 'Individu') {
                              _debouncedRefreshObjek();
                            } else {
                              // Clear grid data when switching to kolektif
                              setState(() {
                                allObjekBudidaya.clear();
                              });
                            }
                          },
                        ),
                        ImagePickerWidget(
                          key: const Key('image_picker_kandang'),
                          label: "Unggah gambar kandang",
                          image: _image,
                          imageUrl: imageUrl['data'],
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
                        if (widget.isEdit && jenisPencatatan == 'Individu') ...[
                          Text("Daftar Slot Kandang Kosong",
                              style: bold18.copyWith(color: dark1)),
                          const SizedBox(height: 8),
                          Text(
                            "Grid ini menampilkan slot kosong yang tersedia. Klik slot untuk menambahkan hewan baru dengan nama yang sesuai.",
                            style: regular12.copyWith(color: dark2),
                          ),
                          const SizedBox(height: 12),
                          _buildObjekGrid(),
                          const SizedBox(height: 16),
                        ],
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
                                            _tanggalNotifikasiPanenController
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
                              key:
                                  const Key('hari_notifikasi_nutrisi_dropdown'),
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
                              key:
                                  const Key('tanggal_notifikasi_nutrisi_input'),
                              label: "Tanggal Notifikasi",
                              hint: "Contoh: 1 (tanggal dalam bulan)",
                              controller: _tanggalNotifikasiNutrisiController,
                              isDisabled: true,
                              suffixIcon: const Icon(Icons.calendar_today),
                              onSuffixIconTap: () async {
                                _showDayOfMonthPicker(
                                        context,
                                        int.tryParse(
                                            _tanggalNotifikasiNutrisiController
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
                textStyle: semibold16.copyWith(color: white),
                isLoading: _isLoading,
                key: const Key('submit_kandang_button'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
