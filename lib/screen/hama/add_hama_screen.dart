import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddHamaScreen extends StatefulWidget {
  const AddHamaScreen({super.key});

  @override
  _AddHamaScreenState createState() => _AddHamaScreenState();
}

class _AddHamaScreenState extends State<AddHamaScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: white,
          leadingWidth: 0,
          titleSpacing: 0,
          elevation: 0,
          toolbarHeight: 80,
          title: const Header(
              headerType: HeaderType.back,
              title: 'Laporan Hama',
              greeting: 'Tambah Hama'),
        ),
      ),
      body: SafeArea(
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputFieldWidget(
                  label: "Nama hama",
                  hint: "Contoh: Tikus",
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
      ),
    );
  }
}
