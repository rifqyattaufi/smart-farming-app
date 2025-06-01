import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/image_service.dart';
import 'package:smart_farming_app/service/user_service.dart';
import 'dart:io';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/profile_picker.dart';

class AddUserScreen extends StatefulWidget {
  final bool? isEdit;
  final String? id;

  const AddUserScreen({super.key, this.isEdit, this.id});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final ImageService _imageService = ImageService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? selectedLocation;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _imageUrl;

  File? _selectedImage;

  final Map<String, String> roleMap = {
    "Penanggung Jawab": "pjawab",
    "Petugas Pelaporan": "petugas",
    "Inventor RFC": "inventor",
  };

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Buka Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                    _imageUrl = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _selectedImage = File(pickedFile.path);
                    _imageUrl = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'role': roleMap[selectedLocation] ?? '',
        'name': _namaController.text,
        'email': _emailController.text,
        'phone': _nomorController.text,
      };

      if (_selectedImage != null) {
        final imageUploadResponse =
            await _imageService.uploadImage(_selectedImage!);
        if (imageUploadResponse['status'] == true &&
            imageUploadResponse['data'] != null) {
          data['avatarUrl'] = imageUploadResponse['data'];
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Gagal mengunggah gambar: ${imageUploadResponse['message']}'),
                  backgroundColor: Colors.red),
            );
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
      }

      Map<String, dynamic>? response;

      if (widget.isEdit ?? false) {
        if (widget.id != null) {
          response = await _userService.updateUser(
            widget.id!,
            data,
          );
        } else {
          response = await _userService.updateUser(
            (await _authService.getUser())!['id'],
            data,
          );
          if (response['status'] == true) {
            await _secureStorage.delete(key: 'user');
            await _secureStorage.write(
                key: 'user', value: json.encode(response['data']));
          }
        }
      } else {
        data['password'] = _emailController.text;
        data['confirmPassword'] = _emailController.text;
        response = await _authService.register(
          data,
        );
      }

      if (response['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengguna berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
        Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Gagal menambahkan pengguna: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan pengguna: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? response;

      if (widget.id != null) {
        response = await _userService.getUserById(widget.id!);
      } else {
        final loggedUser = await _authService.getUser();
        response = await _userService.getUserById(loggedUser!['id']);
      }
      if (response['status'] == true) {
        final userData = response['data'];
        setState(() {
          selectedLocation = roleMap.entries
              .firstWhere((entry) => entry.value == userData['role'],
                  orElse: () => const MapEntry('', ''))
              .key;
          _namaController.text = userData['name'];
          _emailController.text = userData['email'];
          _nomorController.text = userData['phone'];
          _imageUrl = userData['avatarUrl'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengguna: ${response['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data pengguna: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomorController = TextEditingController();

  @override
  void initState() {
    if (widget.isEdit ?? false) {
      _fetchData();
    }
    super.initState();
  }

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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ProfileImagePicker(
                          image: _selectedImage,
                          imageUrl: _imageUrl,
                          onPickImage: (ctx) => _pickImage(ctx),
                          isDisabled:
                              (widget.isEdit ?? false) && widget.id != null,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Role tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    InputFieldWidget(
                        label: "Nama pengguna",
                        hint: "Contoh: James Doe",
                        controller: _namaController,
                        isDisabled:
                            (widget.isEdit ?? false) && widget.id != null,
                        isGrayed: (widget.isEdit ?? false) && widget.id != null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama pengguna tidak boleh kosong';
                          }
                          return null;
                        }),
                    InputFieldWidget(
                      label: "Email pengguna",
                      hint: "Contoh: example@mail.com",
                      controller: _emailController,
                      isDisabled: (widget.isEdit ?? false) && widget.id != null,
                      isGrayed: (widget.isEdit ?? false) && widget.id != null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email pengguna tidak boleh kosong';
                        }
                        // Simple email validation
                        final emailRegex = RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    InputFieldWidget(
                      label: "Nomor telepon",
                      hint: "Contoh: 08**********",
                      controller: _nomorController,
                      isDisabled: (widget.isEdit ?? false) && widget.id != null,
                      isGrayed: (widget.isEdit ?? false) && widget.id != null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        // Simple phone number validation
                        final phoneRegex = RegExp(r'^\d{10,15}$');
                        if (!phoneRegex.hasMatch(value)) {
                          return 'Format nomor telepon tidak valid';
                        }
                        return null;
                      },
                    ),
                    if (!(widget.isEdit ?? false))
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan:',
                            style: medium14.copyWith(color: dark1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- Password untuk pengguna baru adalah email pengguna.\n'
                            '- Pastikan untuk mengubah password setelah akun dibuat.',
                            style: regular12.copyWith(color: dark1),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            onPressed: () {
              // Your action here
            },
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
          ),
        ));
  }
}
