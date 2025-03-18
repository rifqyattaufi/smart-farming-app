import 'package:flutter/material.dart';

class DetailPetScreen extends StatelessWidget {
  const DetailPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail pet Page")),
      body: const Center(child: Text("This is the detail pet screen")),
    );
  }
}