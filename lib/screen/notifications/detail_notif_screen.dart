import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/notifications/add_global_notification.dart';
import 'package:smart_farming_app/service/global_notification_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';

class DetailNotifScreen extends StatefulWidget {
  final String id;

  const DetailNotifScreen({
    super.key,
    required this.id,
  });

  @override
  State<DetailNotifScreen> createState() => _DetailNotifScreenState();
}

class _DetailNotifScreenState extends State<DetailNotifScreen> {
  final GlobalNotificationService _globalNotificationService =
      GlobalNotificationService();

  bool _isLoading = true;

  Map<String, dynamic>? _notificationData;

  Future<void> fetchData() async {
    try {
      final response = await _globalNotificationService
          .getGlobalNotificationsById(widget.id);

      if (response['status']) {
        setState(() {
          _notificationData = response['data'];
        });
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal mengambil data notifikasi');
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
    fetchData();
    super.initState();
  }

  String _formatTime(dynamic time) {
    if (time == null) return 'Unknown Time';
    try {
      return DateFormat('EE, d MMMM yyyy | HH:mm').format(DateTime.parse(time));
    } catch (e) {
      return 'Unknown Time';
    }
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
            title: 'Management Notifikasi',
            greeting: 'Detail Notifikasi Global',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _notificationData?['title'] ?? "-",
                              style: bold18.copyWith(color: dark1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _notificationData?['messageTemplate'] ?? "-",
                              style: medium14.copyWith(color: dark1),
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            infoItem("Target Pengguna",
                                _notificationData?['targetRole'] ?? "-"),
                            infoItem(
                                "Status Notifikasi",
                                _notificationData?['isActive'] == true
                                    ? "Aktif"
                                    : "Tidak Aktif"),
                            infoItem("Tipe Notifikasi",
                                _notificationData?['notificationType'] ?? "-"),
                            infoItem("Waktu Notifikasi",
                                _notificationData?['scheduledTime'] ?? "-"),
                            if (_notificationData?['scheduledDate'] != null)
                              infoItem(
                                "Tanggal Notifikasi",
                                _notificationData?['scheduledDate'] != null
                                    ? _formatTime(
                                        _notificationData!['scheduledDate'])
                                    : "-",
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                key: const Key('edit_notification_button'),
                onPressed: () {
                  context
                      .push('/add-global-notification',
                          extra: AddGlobalNotification(
                            isUpdate: true,
                            id: widget.id,
                          ))
                      .then((value) {
                    fetchData();
                  });
                },
                buttonText: "Ubah Data",
                backgroundColor: yellow2,
                textStyle: semibold16.copyWith(color: white),
              ),
              const SizedBox(height: 12),
              CustomButton(
                key: const Key('delete_notification_button'),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi"),
                        content: const Text(
                            "Apakah Anda yakin ingin menghapus notifikasi ini?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Hapus"),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await _globalNotificationService
                        .deleteGlobalNotification(widget.id);
                    showAppToast(
                      context,
                      'Notifikasi berhasil dihapus',
                      isError: false,
                    );
                    context.pop();
                  }
                },
                buttonText: "Hapus Data",
                backgroundColor: red,
                textStyle: semibold16.copyWith(color: white),
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
