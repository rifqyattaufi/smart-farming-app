import 'dart:convert';

class NotifikasiModel {
  final String id;
  final String title;
  final String message;
  final DateTime receivedAt;
  bool isRead;
  final String? notificationType;
  final String? payload;

  NotifikasiModel({
    required this.id,
    required this.title,
    required this.message,
    required this.receivedAt,
    this.isRead = false,
    this.notificationType,
    this.payload,
  });

  factory NotifikasiModel.fromMap(Map<String, dynamic> map) {
    return NotifikasiModel(
      id: map['id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      receivedAt: DateTime.parse(map['received_at'] as String),
      isRead: map['isRead'] == 1,
      notificationType: map['notification_type'] as String?,
      payload: map['payload'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'received_at': receivedAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'notification_type': notificationType,
      'payload': payload,
    };
  }

  Map<String, dynamic>? get payloadAsMap {
    if (payload == null || payload!.isEmpty) return null;
    try {
      return jsonDecode(payload!);
    } catch (e) {
      print('Error decoding payload: $e');
      return null;
    }
  }
}
