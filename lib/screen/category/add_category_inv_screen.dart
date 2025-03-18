import 'package:flutter/material.dart';

class AddCategoryInvScreen extends StatefulWidget {
  const AddCategoryInvScreen({super.key});

  @override
  State<AddCategoryInvScreen> createState() => _AddCategoryInvScreenState();
}

class _AddCategoryInvScreenState extends State<AddCategoryInvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Category Inventory Page")),
      body: const Center(child: Text("This is the add category inventory screen")),
    );
  }
}