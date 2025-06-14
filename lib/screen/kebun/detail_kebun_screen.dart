import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/schedule_unit_notification_service.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailKebunScreen extends StatefulWidget {
  final String? idKebun;

  const DetailKebunScreen({super.key, this.idKebun});

  @override
  State<DetailKebunScreen> createState() => _DetailKebunScreenState();
}

class _DetailKebunScreenState extends State<DetailKebunScreen> {
  final UnitBudidayaService _unitBudidayaService = UnitBudidayaService();
  final ScheduleUnitNotificationService _scheduleUnitNotification =
      ScheduleUnitNotificationService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _kebun;
  List<dynamic>? _tanamanList;
  Map<String, dynamic> _notificationPanen = {};
  Map<String, dynamic> _notificationNutrisi = {};
  String? _userRole;
  final Map<String, String?> dayToInt = {
    '1': 'Senin',
    '2': 'Selasa',
    '3': 'Rabu',
    '4': 'Kamis',
    '5': 'Jumat',
    '6': 'Sabtu',
    '7': 'Minggu',
  };
  final Map<String, String> notificationType = {
    'daily': 'Harian',
    'weekly': 'Mingguan',
    'monthly': 'Bulanan',
  };

  Future<void> _fetchData() async {
    try {
      final role = await _authService.getUserRole();
      final response =
          await _unitBudidayaService.getUnitBudidayaById(widget.idKebun!);
      setState(() {
        _userRole = role;
        _kebun = response['data']['unitBudidaya'];
        _tanamanList = response['data']['objekBudidaya'];
      });

      final notification = await _scheduleUnitNotification
          .getScheduleUnitNotificationByUnitBudidaya(widget.idKebun!);
      setState(() {
        _notificationPanen = (notification['data'] as List).firstWhere(
              (item) => item['tipeLaporan'] == 'panen',
              orElse: () => null,
            ) ??
            {};
        _notificationNutrisi = (notification['data'] as List).firstWhere(
              (item) => item['tipeLaporan'] == 'vitamin',
              orElse: () => null,
            ) ??
            {};
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteData() async {
    try {
      final response =
          await _unitBudidayaService.deleteUnitBudidaya(widget.idKebun ?? '');
      if (response['status']) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
            title: 'Daftar Kebun',
            greeting: 'Detail Kebun',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DottedBorder(
                    color: green1,
                    strokeWidth: 1.5,
                    dashPattern: const [6, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ImageBuilder(
                        url: _kebun?['gambar'] ?? '',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informasi Kebun",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama kebun", _kebun?['nama'] ?? ''),
                      infoItem("Lokasi kebun", _kebun?['lokasi'] ?? ''),
                      infoItem("Luas kebun", "${_kebun?['luas'] ?? ''} m2"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status kebun",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kebun?['status'] == true
                                    ? green2.withValues(alpha: .1)
                                    : red.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _kebun?['status'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: _kebun?['status'] == true
                                    ? regular12.copyWith(color: green2)
                                    : regular12.copyWith(color: red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem("Jumlah Tanaman",
                          _kebun?['jumlah']?.toString() ?? ''),
                      infoItem(
                          "Tanggal didaftarkan",
                          _kebun?['createdAt'] != null
                              ? DateFormat('EEEE, dd MMMM yyyy').format(
                                  DateTime.tryParse(_kebun?['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      infoItem(
                          "Waktu didaftarkan",
                          _kebun?['createdAt'] != null
                              ? DateFormat('HH:mm').format(
                                  DateTime.tryParse(_kebun?['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      const SizedBox(height: 8),
                      Text("Deskripsi kebun",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _kebun?['deskripsi'] ?? 'Tidak ada deskripsi',
                        style: regular14.copyWith(color: dark2),
                      ),
                      const SizedBox(height: 16),
                      if (_notificationPanen.isNotEmpty ||
                          _notificationNutrisi.isNotEmpty) ...[
                        Text("Pengaturan Notifikasi",
                            style: bold18.copyWith(color: dark1)),
                        const SizedBox(height: 12),
                        if (_notificationPanen.isNotEmpty) ...[
                          Text(
                            "Notifikasi Panen",
                            style: bold16.copyWith(color: dark1),
                          ),
                          infoItem("Jadwal Pengiriman",
                              _notificationPanen['notificationType']),
                          infoItem(
                            "Waktu Pengiriman",
                            _notificationPanen['scheduledTime'] != null
                                ? DateFormat('HH:mm').format(
                                    DateFormat('HH:mm:ss').parse(
                                      _notificationPanen['scheduledTime'],
                                    ),
                                  )
                                : '',
                          ),
                          if (_notificationPanen['notificationType'] ==
                              'weekly')
                            infoItem(
                                "Hari Pengiriman",
                                dayToInt[_notificationPanen['dayOfWeek']
                                            ?.toString() ??
                                        ''] ??
                                    ''),
                          if (_notificationPanen['notificationType'] ==
                              'monthly')
                            infoItem(
                                "Tanggal Pengiriman",
                                _notificationPanen['dayOfMonth']?.toString() ??
                                    ''),
                        ],
                        if (_notificationNutrisi.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            "Notifikasi Nutrisi",
                            style: bold16.copyWith(color: dark1),
                          ),
                          infoItem("Jadwal Pengiriman",
                              _notificationNutrisi['notificationType']),
                          infoItem(
                            "Waktu Pengiriman",
                            _notificationNutrisi['scheduledTime'] != null
                                ? DateFormat('HH:mm').format(
                                    DateFormat('HH:mm:ss').parse(
                                      _notificationNutrisi['scheduledTime'],
                                    ),
                                  )
                                : '',
                          ),
                          if (_notificationNutrisi['notificationType'] ==
                              'weekly')
                            infoItem(
                                "Hari Pengiriman",
                                dayToInt[_notificationNutrisi['dayOfWeek']
                                            ?.toString() ??
                                        ''] ??
                                    ''),
                          if (_notificationNutrisi['notificationType'] ==
                              'monthly')
                            infoItem(
                                "Tanggal Pengiriman",
                                _notificationNutrisi['dayOfMonth']
                                        ?.toString() ??
                                    ''),
                        ],
                      ]
                    ],
                  ),
                ),
                ListItem(
                  title: 'Daftar Tanaman',
                  type: 'basic',
                  items: (_tanamanList ?? [])
                      .map((tanaman) => {
                            'name': tanaman['namaId'],
                            'icon': tanaman['UnitBudidaya']['JenisBudidaya']
                                ['gambar'],
                            'category': tanaman['UnitBudidaya']['JenisBudidaya']
                                ['nama'],
                            'id': tanaman['id'],
                          })
                      .toList(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _userRole != 'pjawab'
          ? null
          : SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomButton(
                      onPressed: () {
                        context.push('/tambah-kebun',
                            extra: AddKebunScreen(
                              isEdit: true,
                              idKebun: widget.idKebun,
                              onKebunAdded: () => _fetchData(),
                            ));
                      },
                      buttonText: 'Ubah Data',
                      backgroundColor: yellow2,
                      textStyle: semibold16,
                      textColor: white,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                                'Apakah Anda yakin ingin menghapus kebun ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
            
                        if (confirm == true) {
                          await _deleteData();
                        }
                      },
                      buttonText: 'Hapus Data',
                      backgroundColor: red,
                      textStyle: semibold16,
                      textColor: white,
                    ),
                  ],
                ),
              ),
          ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: medium14.copyWith(color: dark1)),
          Text(value, style: regular14.copyWith(color: dark2)),
        ],
      ),
    );
  }
}
