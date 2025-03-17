import 'package:flutter/material.dart';

class DetailPetScreen extends StatelessWidget {
  const DetailPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail pet Page")),
      body: Center(child: Text("This is the detail pet screen")),
    );
  }
}