import 'package:flutter/material.dart';

class DetailGardenScreen extends StatelessWidget {
  const DetailGardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Garden Page")),
      body: Center(child: Text("This is the detail garden screen")),
    );
  }
}