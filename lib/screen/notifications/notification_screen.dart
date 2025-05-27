import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/model/notifikasi_model.dart';
import 'package:smart_farming_app/service/database_helper.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/search_field.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<NotifikasiModel> _unreadNotifications = [];
  List<NotifikasiModel> _allNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final unread = await _dbHelper.getUnreadNotifications();
      final all = await _dbHelper.getReadNotifications();
      if (mounted) {
        setState(() {
          _unreadNotifications = unread;
          _allNotifications = all;
        });
      }
    } catch (e) {
      print('Gagal mengambil notifikasi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final unreadIds = _unreadNotifications.map((n) => n.id).toList();

      if (unreadIds.isNotEmpty) {
        await _dbHelper.markAllAsRead();
        print('Semua notifikasi telah ditandai sebagai dibaca');
        await _fetchNotifications();
      }
    } catch (e) {
      print('Gagal menandai semua notifikasi sebagai dibaca: ${e.toString()}');
    }
  }

  Future<void> _deleteAllReadNotifications() async {
    try {
      await _dbHelper.deleteReadNotifications();
      print('Semua notifikasi telah dihapus');
      await _fetchNotifications();
    } catch (e) {
      print('Gagal menghapus semua notifikasi: ${e.toString()}');
    }
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        await _markAllAsRead();
      },
      child: Scaffold(
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _unreadNotifications.isEmpty && _allNotifications.isEmpty
                ? const Center(
                    child: Text("No Notification Found",
                        textAlign: TextAlign.center),
                  )
                : SafeArea(
                    child: Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        color: green2,
                        backgroundColor: white,
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_unreadNotifications.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Notifikasi Terbaru",
                                                style: bold18.copyWith(
                                                    color: dark1)),
                                            // GestureDetector(
                                            //   onTap: () async {
                                            //     await _markAllAsRead();
                                            //   },
                                            //   child: Align(
                                            //     alignment:
                                            //         Alignment.centerLeft,
                                            //     child: Text(
                                            //       "Tandai telah dibaca",
                                            //       style: medium14.copyWith(
                                            //           color: green1,
                                            //           decoration:
                                            //               TextDecoration
                                            //                   .underline),
                                            //     ),
                                            //   ),
                                            // ),
                                            IconButton(
                                              onPressed: () async {
                                                await _markAllAsRead();
                                              },
                                              icon: Icon(
                                                Icons.done_all,
                                                color: green1,
                                              ),
                                              iconSize: 20,
                                            ),
                                          ],
                                        ),
                                        ..._unreadNotifications.map(
                                          (notif) => InkWell(
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: green2.withValues(
                                                    alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          notif.title,
                                                          style:
                                                              medium16.copyWith(
                                                                  color: dark1),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              green2.withValues(
                                                                  alpha: 0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                        ),
                                                        child: Text(
                                                          formatDate(
                                                              notif.receivedAt),
                                                          style: regular12
                                                              .copyWith(
                                                                  color:
                                                                      green2),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(notif.message,
                                                      style: medium14.copyWith(
                                                          color: dark1)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_allNotifications.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      children: [
                                        if (_unreadNotifications.isNotEmpty)
                                          const Divider(),
                                        const SizedBox(width: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Semua Notifikasi",
                                                style: bold18.copyWith(
                                                    color: dark1)),
                                            IconButton(
                                              onPressed:
                                                  _deleteAllReadNotifications,
                                              icon: Icon(
                                                Icons.delete_forever,
                                                color: red,
                                              ),
                                              iconSize: 20,
                                            ),
                                          ],
                                        ),
                                        ..._allNotifications.map((notif) =>
                                            InkWell(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                notif.title,
                                                                style: medium16
                                                                    .copyWith(
                                                                        color:
                                                                            dark1),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 8),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: green2
                                                                    .withValues(
                                                                        alpha:
                                                                            0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                              ),
                                                              child: Text(
                                                                formatDate(notif
                                                                    .receivedAt),
                                                                style: regular12
                                                                    .copyWith(
                                                                        color:
                                                                            green2),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(notif.message,
                                                            style: medium14
                                                                .copyWith(
                                                                    color:
                                                                        dark1)),
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
                    ),
                  ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat("EEEE, dd MMMM yyyy HH.mm").format(date);
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
