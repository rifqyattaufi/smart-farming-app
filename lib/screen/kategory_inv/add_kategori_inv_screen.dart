import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddKategoriInvScreen extends StatefulWidget {
  const AddKategoriInvScreen({super.key});

  @override
  _AddKategoriInvScreenState createState() => _AddKategoriInvScreenState();
}

class _AddKategoriInvScreenState extends State<AddKategoriInvScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(
            headerType: HeaderType.menu,
            title: 'Manajemen Kategori Inventaris',
            greeting: 'Tambah Kategori Inventaris'),
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFieldWidget(
                label: "Nama kategori inventaris",
                hint: "Contoh: Bibit tanaman",
                controller: _nameController,
              ),
              const SizedBox(height: 520),
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
