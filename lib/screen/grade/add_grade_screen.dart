import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/grade_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class AddGradeScreen extends StatefulWidget {
  final VoidCallback? onGradeAdded;
  final bool isUpdate;
  final String? id;
  final String? nama;
  final String? deskripsi;

  const AddGradeScreen({
    super.key,
    this.onGradeAdded,
    this.isUpdate = false,
    this.id,
    this.nama,
    this.deskripsi,
  });

  @override
  _AddGradeScreenState createState() => _AddGradeScreenState();
}

class _AddGradeScreenState extends State<AddGradeScreen> {
  final GradeService _gradeService = GradeService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _nameController.text = widget.nama ?? '';
      _deskripsiController.text = widget.deskripsi ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      final data = {
        'nama': _nameController.text,
        'deskripsi': _deskripsiController.text,
      };

      Map<String, dynamic>? response;

      if (widget.isUpdate) {
        response = await _gradeService.updateGrade(widget.id!, data);
      } else {
        response = await _gradeService.createGrade(data);
      }

      if (!mounted) return;

      if (response['status'] == true) {
        if (widget.onGradeAdded != null) {
          widget.onGradeAdded!();
        }

        showAppToast(
          context,
          widget.isUpdate
              ? 'Berhasil memperbarui data grade hasil panen'
              : 'Berhasil menambahkan data grade hasil panen',
          isError: false,
        );

        setState(() {
          isLoading = false;
        });

        Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false;
        });

        // Tampilkan pesan error yang lebih spesifik
        String errorMessage =
            response['message'] ?? 'Terjadi kesalahan tidak diketahui';

        showAppToast(context, errorMessage, isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
          title: 'Error Tidak Terduga 😢');
    }
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
          title: Header(
              headerType: HeaderType.back,
              title: 'Manajemen Grade Hasil Panen',
              greeting: widget.isUpdate
                  ? 'Edit Grade Hasil Panen'
                  : 'Tambah Grade Hasil Panen'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                    label: "Nama grade hasil panen",
                    hint: "Contoh: Grade A",
                    controller: _nameController,
                    key: const Key('nama_grade_input'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama grade hasil panen tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InputFieldWidget(
                    label: "Deskripsi grade hasil panen",
                    hint: "Keterangan",
                    controller: _deskripsiController,
                    key: const Key('deskripsi_grade_input'),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi grade hasil panen tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            onPressed: _submitForm,
            buttonText: widget.isUpdate ? 'Simpan Perubahan' : 'Tambah Grade',
            backgroundColor: green1,
            textStyle: semibold16,
            textColor: white,
            isLoading: isLoading,
            key: const Key('submit_grade_button'),
          ),
        ),
      ),
    );
  }
}
