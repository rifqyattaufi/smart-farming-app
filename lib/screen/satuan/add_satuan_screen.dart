import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddSatuanScreen extends StatefulWidget {
  const AddSatuanScreen({super.key});

  @override
  _AddSatuanScreenState createState() => _AddSatuanScreenState();
}

class _AddSatuanScreenState extends State<AddSatuanScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lambangController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(
            headerType: HeaderType.menu,
            title: 'Manajemen Satuan',
            greeting: 'Tambah Satuan'),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFieldWidget(
                label: "Nama satuan",
                hint: "Contoh: Kilogram",
                controller: _nameController,
              ),
              InputFieldWidget(
                label: "Lambang satuan",
                hint: "Contoh: Kg",
                controller: _lambangController,
              ),
              const SizedBox(height: 450),
              CustomButton(
                onPressed: () {
                  // Your action here
                },
                backgroundColor: green1,
                textStyle: semibold16,
                textColor: white,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ]),
    );
  }
}
