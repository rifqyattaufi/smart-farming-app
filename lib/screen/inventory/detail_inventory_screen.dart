import 'package:flutter/material.dart';

class DetailInventoryScreen extends StatelessWidget {
  const DetailInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Inventory Page")),
      body: Center(child: Text("This is the detail inventory screen")),
    );
  }
}