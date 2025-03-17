import 'package:flutter/material.dart';
import 'package:smart_farming_app/screen/detail_item_screen.dart';
import 'package:smart_farming_app/theme.dart';

class HistoryScreen extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const HistoryScreen({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item['name'] ?? 'Unknown',
                style: semibold16.copyWith(color: dark1),
              ),
              subtitle: Text(
                "${item['date'] ?? 'Unknown'} | ${item['time'] ?? 'Unknown'}",
                style: regular14.copyWith(color: dark2),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailItemScreen(item: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
