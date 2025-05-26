import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_farming_app/service/auth_service.dart';

class FcmService {
  final AuthService _authService = AuthService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  FcmService(this._flutterLocalNotificationsPlugin);

  Future<void> getTokenAndSendToServer() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("Current FCM Token: $token");
      if (token != null) {
        await _updateFcmTokenOnServer(token);
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  Future<void> _updateFcmTokenOnServer(String token) async {
    print("Updating FCM token on server: $token");
    try {
      final response = await _authService.updateFcm(token);

      if (response['status'] == true) {
        print("FCM token updated successfully on server.");
      } else {
        print("Failed to update FCM token: ${response['message']}");
      }
    } catch (e) {
      print("Error updating FCM token on server: $e");
    }
  }

  void _setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received!');
      print('Message Id: ${message.messageId} data: ${message.data}');
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        print('Notification Title: ${notification.title}');
        print('Notification Body: ${notification.body}');

        _showLocalNotification(
          notification.hashCode,
          notification.title ?? 'Notifikasi Baru',
          notification.body ?? 'Anda memiliki pesan baru',
          jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background!');
      print('Message Id: ${message.messageId} data: ${message.data}');
      _handleNotificationInteraction(message.data, "background_tap");
    });
  }

  Future<void> checkInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('FCM App opened from terminated state via Notification!');
      print(
          'Message Id: ${initialMessage.messageId} data: ${initialMessage.data}');
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
    print('Handling notification interaction from $source with data: $data');
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
    try {
      await _firebaseMessaging.deleteToken();
      print("FCM Token deleted successfully.");
      await _updateFcmTokenOnServer("");
    } catch (e) {
      print("Error deleting FCM token: $e");
    }
  }

  Future<void> initFCM() async {
    await getTokenAndSendToServer();
    _setupFCMListeners();

    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print("FCM Token Refreshed: $newToken");
      _updateFcmTokenOnServer(newToken);
    });
  }
}
