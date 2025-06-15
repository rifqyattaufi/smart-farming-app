import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/notifications/add_global_notification.dart';
import 'package:smart_farming_app/screen/notifications/detail_notif_screen.dart';
import 'package:smart_farming_app/service/global_notification_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/newest.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class NotificationManagementScreen extends StatefulWidget {
  const NotificationManagementScreen({super.key});

  @override
  State<NotificationManagementScreen> createState() =>
      _NotificationManagementScreenState();
}

class _NotificationManagementScreenState
    extends State<NotificationManagementScreen> {
  final GlobalNotificationService _globalNotificationService =
      GlobalNotificationService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future _searchNotifications(String query) async {
    // Implement search logic here
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _globalNotificationService.getGlobalNotifications();
    if (response['status']) {
      setState(() {
        _notifications = List<Map<String, dynamic>>.from(
          (response['data'] as List).map((item) => {
                'text': item['title'],
                'action': item['notificationType'].toString().toUpperCase(),
                'time': item['notificationType'] == 'repeat'
                    ? (item['scheduledTime'] as String).substring(0, 5)
                    : ("${DateFormat("d MMMM yyyy |").format(DateTime.parse(item['scheduledDate']))} ${(item['scheduledTime'] as String).substring(0, 5)}"),
                'isActive': item['isActive'],
                'id': item['id'],
              }),
        );
      });
    } else {
      if (mounted) {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    }

    setState(() {
      _isLoading = false;
    });
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
          surfaceTintColor: white,
          scrolledUnderElevation: 0,
          toolbarHeight: 80,
          title: const Header(
            headerType: HeaderType.back,
            title: 'Pengaturan Lainnya',
            greeting: "Manajemen Notifikasi Global",
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          key: const Key('add_notification_button'),
          onPressed: () {
            context
                .push('/add-global-notification',
                    extra: const AddGlobalNotification(
                      isUpdate: false,
                    ))
                .then((_) {
              _fetchNotifications();
            });
          },
          backgroundColor: green1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: SearchField(
                controller: _searchController,
                onChanged: _searchNotifications,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      color: green2,
                      backgroundColor: white,
                      child: ListView(
                        children: [
                          NewestReports(
                            key: const Key('notification_list'),
                            reports: _notifications,
                            onItemTap: (context, item) {
                              final id = item['id'] ?? '';
                              context
                                  .push('/detail-global-notification',
                                      extra: DetailNotifScreen(id: id))
                                  .then((_) {
                                _fetchNotifications();
                              });
                            },
                            showIcon: false,
                            mode: NewestReportsMode.log,
                            titleTextStyle: bold18.copyWith(color: dark1),
                            reportTextStyle: medium12.copyWith(color: dark1),
                            timeTextStyle: regular12.copyWith(color: dark2),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
