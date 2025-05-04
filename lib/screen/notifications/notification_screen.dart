import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> allNotifications = [
    NotificationItem(
      title: "Pengingat Harian",
      date: "Senin, 03 Februari 2025 08.20",
      message:
          "Hai, siap melaporkan kegiatan hari ini?\nPantau kebun & ternakmu agar tetap optimal.",
    ),
    NotificationItem(
      title: "Pengingat Harian",
      date: "Senin, 10 Februari 2025 08.20",
      message:
          "Selamat datang kembali!\nJangan lupa laporkan aktivitas hari ini ya!",
    ),
    NotificationItem(
      title: "Selamat Datang!",
      date: "Senin, 17 Februari 2025 08.20",
      message:
          "Mari mulai kelola kebun dan ternakmu dengan lebih mudah dan efisien.",
    ),
  ];

  final NotificationItem latestNotification = NotificationItem(
    title: "Pengingat Harian",
    date: "Senin, 17 Februari 2025 08.20",
    message:
        "Satu langkah kecil, dampak besar untuk pertanian dan peternakanmu. Waktunya isi laporan harian!",
  );

  TextEditingController searchController = TextEditingController();

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
            title: 'Menu Aplikasi',
            greeting: 'Notifikasi',
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                      Text("Notifikasi Terbaru",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tandai telah dibaca",
                          style: medium14.copyWith(
                              color: green1,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          context.push('/detail-notifikasi', extra: {
                            'title': latestNotification.title,
                            'date': latestNotification.date,
                            'message': latestNotification.message,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: green2.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(latestNotification.title,
                                      style: medium16.copyWith(color: dark1)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: green2.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      latestNotification.date,
                                      style: regular12.copyWith(color: green2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(latestNotification.message,
                                  style: medium14.copyWith(color: dark1)),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      const SizedBox(height: 12),
                      Text("Semua Notifikasi",
                          style: bold18.copyWith(color: dark1)),
                      const SizedBox(height: 8),
                      ...allNotifications.map((notif) => InkWell(
                            onTap: () {
                              context.push('/detail-notifikasi', extra: {
                                'title': notif.title,
                                'date': notif.date,
                                'message': notif.message,
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(notif.title,
                                              style: medium16.copyWith(
                                                  color: dark1)),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  green2.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              notif.date,
                                              style: regular12.copyWith(
                                                  color: green2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(notif.message,
                                          style:
                                              medium14.copyWith(color: dark1)),
                                    ],
                                  ),
                                ),
                                const Divider(height: 24),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String date;
  final String message;

  NotificationItem({
    required this.title,
    required this.date,
    required this.message,
  });
}
