import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/schedule_unit_notification_service.dart';
import 'package:smart_farming_app/service/unit_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailKandangScreen extends StatefulWidget {
  final String? idKandang;

  const DetailKandangScreen({super.key, this.idKandang});

  @override
  State<DetailKandangScreen> createState() => _DetailKandangScreenState();
}

class _DetailKandangScreenState extends State<DetailKandangScreen> {
  final _unitBudidayaService = UnitBudidayaService();
  final ScheduleUnitNotificationService _scheduleUnitNotification =
      ScheduleUnitNotificationService();
  final AuthService _authService = AuthService();

  Map<String, dynamic> _kandang = {};
  List<dynamic> _ternakList = [];
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
      final response = await _unitBudidayaService
          .getUnitBudidayaById(widget.idKandang ?? '');
      final role = await _authService.getUserRole();
      setState(() {
        _kandang = response['data']['unitBudidaya'];
        _ternakList = response['data']['objekBudidaya'];
        _userRole = role;
      });

      final notification = await _scheduleUnitNotification
          .getScheduleUnitNotificationByUnitBudidaya(widget.idKandang ?? '');
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
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
  }

  Future<void> _deleteData() async {
    try {
      final response =
          await _unitBudidayaService.deleteUnitBudidaya(widget.idKandang ?? '');
      if (response['status']) {
        context.pop();
        showAppToast(
          context,
          'Berhasil menghapus data kandang',
          isError: false,
        );
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      setState(() {});
      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
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
            title: 'Daftar Kandang',
            greeting: 'Detail Kandang',
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
                          url: _kandang['gambar'] ?? '',
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Informasi Kandang",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 12),
                      infoItem("Nama kandang", _kandang['nama'] ?? ''),
                      infoItem("Lokasi kandang", _kandang['lokasi'] ?? ''),
                      infoItem("Luas kandang", "${_kandang['luas']} m2"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status kandang",
                                style: medium14.copyWith(color: dark1)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kandang['status'] == true
                                    ? green2.withValues(alpha: .1)
                                    : red.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                _kandang['status'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: _kandang['status'] == true
                                    ? regular12.copyWith(color: green2)
                                    : regular12.copyWith(color: red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      infoItem("Tipe kandang", _kandang['tipe'] ?? ''),
                      infoItem(
                          "Jumlah Hewan", _kandang['jumlah']?.toString() ?? ''),
                      infoItem(
                          "Tanggal didaftarkan",
                          _kandang['createdAt'] != null
                              ? DateFormat('EEEE, dd MMMM yyyy').format(
                                  DateTime.tryParse(_kandang['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      infoItem(
                          "Waktu didaftarkan",
                          _kandang['createdAt'] != null
                              ? DateFormat('HH:mm').format(
                                  DateTime.tryParse(_kandang['createdAt']) ??
                                      DateTime(0))
                              : 'Unknown time'),
                      const SizedBox(height: 8),
                      Text("Deskripsi kandang",
                          style: medium14.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      Text(
                        _kandang['deskripsi'] ?? 'Tidak ada deskripsi',
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
                if (_kandang['tipe'] == "individu")
                  ListItem(
                    key: const Key('list_ternak'),
                    title: 'Daftar Ternak',
                    type: 'basic',
                    items: _ternakList
                        .map((ternak) => {
                              'name': ternak['namaId'],
                              'category': ternak['UnitBudidaya']
                                  ['JenisBudidaya']['nama'],
                              'icon': ternak['UnitBudidaya']['JenisBudidaya']
                                  ['gambar'],
                              'id': ternak['id'],
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
                      key: const Key('ubah_data_kandang_button'),
                      onPressed: () {
                        context.push('/tambah-kandang',
                            extra: AddKandangScreen(
                              isEdit: true,
                              idKandang: widget.idKandang,
                              onKandangAdded: () => _fetchData(),
                            ));
                      },
                      buttonText: 'Ubah Data',
                      backgroundColor: yellow2,
                      textStyle: semibold16,
                      textColor: white,
                    ),
                    const SizedBox(height: 12), // Jarak antara tombol
                    CustomButton(
                      key: const Key('hapus_data_kandang_button'),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi'),
                            content: const Text(
                                'Apakah Anda yakin ingin menghapus kandang ini?'),
                            actions: [
                              TextButton(
                                key: const Key('cancelButton'),
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                key: const Key('deleteButton'),
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
