import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/profile_picker.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  String? selectedLocation;

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  bool _isPasswordVisible = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              title: 'Manajemen Pengguna',
              greeting: 'Tambah Pengguna'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileImagePicker(
                      image: _selectedImage,
                      onPickImage: _pickImage,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownFieldWidget(
                  label: "Pilih role",
                  hint: "Pilih role",
                  items: const [
                    "Penanggung Jawab",
                    "Petugas Pelaporan",
                    "Inventor RFC"
                  ],
                  selectedValue: selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      selectedLocation = value;
                    });
                  },
                ),
                InputFieldWidget(
                    label: "Nama pengguna",
                    hint: "Contoh: James Doe",
                    controller: _namaController),
                InputFieldWidget(
                    label: "Email pengguna",
                    hint: "Contoh: example@mail.com",
                    controller: _emailController),
                InputFieldWidget(
                    label: "Nomor telepon",
                    hint: "Contoh: 08**********",
                    controller: _nomorController),
                InputFieldWidget(
                  label: "Masukkan Password",
                  hint: "Contoh: password",
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onSuffixIconTap: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan:',
                      style: medium14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '- Password minimal 8 karakter.\n'
                      '- Password terdiri dari kombinasi huruf, angka, dan simbol.\n'
                      '- Kosongi kolom jika ingin mendapat password default dari sistem.',
                      style: regular12.copyWith(color: dark1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
        ),
      ),
    );
  }
}
