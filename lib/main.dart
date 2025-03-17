import 'package:flutter/material.dart';
import 'package:smart_farming_app/screen/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Smart Farming App',
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
