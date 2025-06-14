import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_farming_app/model/notifikasi_model.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/database_helper.dart';

class FcmService {
  final AuthService _authService = AuthService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  FcmService(this._flutterLocalNotificationsPlugin);

  Future<void> getTokenAndSendToServer() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _updateFcmTokenOnServer(token);
    }
  }

  Future<void> _updateFcmTokenOnServer(String token) async {
    await _authService.updateFcm(token);
  }

  Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    if (message.messageId == null) {
      return;
    }

    if (message.notification == null) {
      return;
    }

    final notifikasi = NotifikasiModel(
      id: message.messageId!,
      title: message.notification?.title ?? 'Notifikasi Baru',
      message: message.notification?.body ?? 'Anda memiliki pesan baru',
      receivedAt: message.sentTime ?? DateTime.now(),
      isRead: false,
      notificationType: message.data['notificationType'] as String?,
      payload: jsonEncode(message.data),
    );

    await _dbHelper.insertNotification(notifikasi);
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _saveNotificationToDatabase(message);

      RemoteNotification? notification = message.notification;

      if (notification != null) {
        _showLocalNotification(
          notification.hashCode,
          notification.title ?? 'Notifikasi Baru',
          notification.body ?? 'Anda memiliki pesan baru',
          jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationInteraction(message.data, "background_tap");
    });
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationInteraction(initialMessage.data, "terminated_tap");
    }
  }

  Future<void> _showLocalNotification(
      int id, String title, String body, String payload) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            'smart_farming_default_channel_id', 'Smart Farming Notifications',
            channelDescription:
                'Default channel for Smart Farming notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon');

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Fungsi untuk menangani interaksi notifikasi (tap)
  void _handleNotificationInteraction(
      Map<String, dynamic> data, String source) {
    // TODO: Implementasikan logika navigasi atau aksi berdasarkan `data`
    // Contoh:
    // final String? notificationType = data['notificationType'];
    // final String? unitBudidayaId = data['unitBudidayaId'];
    // if (notificationType == 'UNIT_SCHEDULE' && unitBudidayaId != null) {
    //   // Navigasi ke halaman detail unit budidaya
    //   // Get.toNamed('/unitDetail', arguments: {'unitId': unitBudidayaId});
    //   print("Navigate to unit detail: $unitBudidayaId");
    // } else {
    //   // Navigasi ke halaman default atau home
    //   print("Navigate to home or default screen.");
    // }
  }

  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    await _updateFcmTokenOnServer("");
  }

  Future<void> initFCM() async {
    await getTokenAndSendToServer();
    _setupFCMListeners();

    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      _updateFcmTokenOnServer(newToken);
    });
  }
}
