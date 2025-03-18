import 'package:flutter/material.dart';

class DetailGardenScreen extends StatelessWidget {
  const DetailGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Garden Page")),
      body: const Center(child: Text("This is the detail garden screen")),
    );
  }
}