import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: AppBar(
              backgroundColor: white,
              leadingWidth: 0,
              titleSpacing: 0,
              title: const Text("Notification Page"))),
      body: const SafeArea(
          child: Center(child: Text("This is the Notification screen"))),
    );
  }
}
