import 'package:flutter/material.dart';

class DetailPlantScreen extends StatelessWidget {
  const DetailPlantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail pet Page")),
      body: Center(child: Text("This is the detail pet screen")),
    );
  }
}
