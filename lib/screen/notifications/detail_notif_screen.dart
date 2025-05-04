import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';

class DetailNotifScreen extends StatelessWidget {
  final String title;
  final String date;
  final String message;

  const DetailNotifScreen({
    super.key,
    required this.title,
    required this.date,
    required this.message,
  });

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
            title: 'Notifikasi',
            greeting: 'Detail Notifikasi',
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
                      Text(
                        title,
                        style: bold18.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: medium14.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        style: medium14.copyWith(color: dark1),
                      ),
                      const SizedBox(height: 20),
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
