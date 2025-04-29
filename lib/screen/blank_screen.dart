import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';

class BlankScreen extends StatefulWidget {
  const BlankScreen({super.key});

  @override
  State<BlankScreen> createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,title: const Text("Blank Page"))),
      body: const SafeArea(child: Center(child: Text("This is the Blank screen"))),
    );
  }
}
