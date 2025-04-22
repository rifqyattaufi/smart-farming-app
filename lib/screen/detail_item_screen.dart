import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class DetailItemScreen extends StatelessWidget {
  final Map<String, String> item;

  const DetailItemScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['name'] ?? 'Detail'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'] ?? 'Unknown',
              style: bold18.copyWith(color: dark1),
            ),
            const SizedBox(height: 8),
            Text(
              "Tanggal: ${item['date'] ?? 'Unknown'}",
              style: semibold14.copyWith(color: dark2),
            ),
            const SizedBox(height: 4),
            Text(
              "Waktu: ${item['time'] ?? 'Unknown'}",
              style: semibold14.copyWith(color: dark2),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Kembali"),
            ),
          ],
        ),
      ),
    );
  }
}
