import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/service/global_notification_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class AddGlobalNotification extends StatefulWidget {
  final String? id;
  final bool isUpdate;

  const AddGlobalNotification({
    super.key,
    this.id,
    this.isUpdate = false,
  });

  @override
  State<AddGlobalNotification> createState() => _AddGlobalNotificationState();
}

class _AddGlobalNotificationState extends State<AddGlobalNotification> {
  final GlobalNotificationService _globalNotificationService =
      GlobalNotificationService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController _waktuNotifikasi = TextEditingController();
  final TextEditingController _tanggalNotifikasi = TextEditingController();
  String selectedType = "";
  DateTime? selectedDate;
  String selectedRole = "";
  String isActive = "Aktif";

  final Map<String, String> targetRole = {
    'Semua Pengguna': 'all',
    'Petugas': 'petugas',
    'Inventor': 'inventor',
    'Penanggung Jawab': 'pjawab'
  };

  Future<void> _submitForm() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data = {
        'title': titleController.text,
        'messageTemplate': messageController.text,
        'targetRole': targetRole[selectedRole],
        'isActive': isActive == "Aktif" ? true : false,
        'notificationType': selectedType == "Berulang" ? 'repeat' : 'once',
        'scheduledTime': _waktuNotifikasi.text,
        'scheduledDate':
            selectedType == 'Sekali' ? selectedDate!.toString() : null,
      };

      Map<String, dynamic>? response;

      if (widget.isUpdate) {
        data['id'] = widget.id;
        response = await _globalNotificationService.updateGlobalNotification(
          data,
        );
      } else {
        response =
            await _globalNotificationService.createGLobalNotification(data);
      }

      if (response['status']) {
        showAppToast(
          context,
          widget.isUpdate
              ? 'Berhasil memperbarui notifikasi global'
              : 'Berhasil menambahkan notifikasi global',
          isError: false,
        );
        Navigator.pop(context, true);
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }

      // print(data);
    } catch (e) {
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _globalNotificationService
          .getGlobalNotificationsById(widget.id!);

      if (response['status']) {
        final data = response['data'];
        titleController.text = data['title'] ?? '';
        messageController.text = data['messageTemplate'] ?? '';
        selectedRole = targetRole.keys.firstWhere(
            (key) => targetRole[key] == data['targetRole'],
            orElse: () => 'Semua Pengguna');
        isActive = data['isActive'] ? 'Aktif' : 'Tidak Aktif';
        selectedType =
            data['notificationType'] == 'repeat' ? 'Berulang' : 'Sekali';
        if (data['scheduledTime'] != null) {
          final timeParts = data['scheduledTime'].split(':');
          if (timeParts.length >= 2) {
            _waktuNotifikasi.text = '${timeParts[0]}:${timeParts[1]}';
          } else {
            _waktuNotifikasi.text = data['scheduledTime'];
          }
        } else {
          _waktuNotifikasi.text = '';
        }
        if (data['scheduledDate'] != null) {
          selectedDate = DateTime.parse(data['scheduledDate']);
          _tanggalNotifikasi.text =
              DateFormat('EEEE, dd MMMM yyyy').format(selectedDate!);
        }
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

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
            backgroundColor: Colors.white,
            leadingWidth: 0,
            titleSpacing: 0,
            elevation: 0,
            toolbarHeight: 80,
            title: Header(
              headerType: HeaderType.back,
              title: "Manajemen Notifikasi Global",
              greeting: widget.isUpdate
                  ? 'Update Notifikasi Global'
                  : 'Tambah Notifikasi Global',
            ),
          )),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputFieldWidget(
                      label: "Judul Notifikasi",
                      hint: "Contoh: Pemberitahuan Penting",
                      controller: titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    InputFieldWidget(
                        label: "Pesan Notifikasi",
                        hint: "Contoh: Akan ada pemeliharaan sistem siang ini",
                        controller: messageController,
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pesan tidak boleh kosong';
                          }
                          return null;
                        }),
                    DropdownFieldWidget(
                      label: "Target Pengguna",
                      hint: "Pilih pengguna yang akan dituju",
                      items: targetRole.keys.toList(),
                      selectedValue: selectedRole,
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Target pengguna tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    RadioField(
                      label: "Status Notifikasi",
                      selectedValue: isActive,
                      options: const ['Aktif', 'Tidak Aktif'],
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                    RadioField(
                      label: "Tipe Notifikasi",
                      selectedValue: selectedType,
                      options: const ['Berulang', 'Sekali'],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    InputFieldWidget(
                      label: "Waktu Notifikasi",
                      hint: "Contoh: 08:00",
                      controller: _waktuNotifikasi,
                      isDisabled: true,
                      suffixIcon: const Icon(Icons.access_time),
                      onSuffixIconTap: () async {
                        TimeOfDay initialTime = TimeOfDay.now();
                        if (_waktuNotifikasi.text.isNotEmpty) {
                          final parts = _waktuNotifikasi.text.split(':');
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
                            _waktuNotifikasi.text = '$hour:$minute';
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Waktu notifikasi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    if (selectedType == 'Sekali')
                      InputFieldWidget(
                        label: "Tanggal Notifikasi",
                        hint: "Pilih tanggal untuk notifikasi sekali",
                        controller: _tanggalNotifikasi,
                        isDisabled: true,
                        suffixIcon: const Icon(Icons.calendar_today),
                        onSuffixIconTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              _tanggalNotifikasi.text =
                                  DateFormat('EEEE, dd MMMM yyyy')
                                      .format(pickedDate);
                            });
                          }
                        },
                        validator: (value) {
                          if (selectedType == "Sekali" &&
                              (value == null || value.isEmpty)) {
                            return 'Tanggal notifikasi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                  ]),
            )),
      )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
