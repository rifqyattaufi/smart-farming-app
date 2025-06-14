import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/utils/app_utils.dart';

class AddHamaScreen extends StatefulWidget {
  final VoidCallback? onHamaAdded;
  final bool isEdit;
  final String? id;
  final String? nama;

  const AddHamaScreen({
    super.key,
    this.onHamaAdded,
    this.isEdit = false,
    this.id,
    this.nama,
  });

  @override
  _AddHamaScreenState createState() => _AddHamaScreenState();
}

class _AddHamaScreenState extends State<AddHamaScreen> {
  final HamaService _hamaService = HamaService();

  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.nama != null) {
      _nameController.text = widget.nama!;
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final dataPayload = {
      'nama': _nameController.text,
    };

    Map<String, dynamic> response;

    try {
      if (widget.isEdit) {
        if (widget.id == null) {
          if (mounted) {
            showAppToast(context, 'ID jenis hama tidak ditemukan');
            setState(() => _isLoading = false);
          }
          return;
        }
        response = await _hamaService.updateJenisHama(widget.id!, dataPayload);
      } else {
        response = await _hamaService.createJenisHama(dataPayload);
      }

      if (!mounted) return;

      if (response['status'] == true) {
        widget.onHamaAdded?.call();

        showAppToast(
            context,
            widget.isEdit
                ? 'Berhasil memperbarui data jenis hama'
                : 'Berhasil menambahkan data jenis hama',
            isError: false);
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });

        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
              title: 'Manajemen Jenis Hama',
              greeting:
                  widget.isEdit ? 'Edit Jenis Hama' : 'Tambah Jenis Hama'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputFieldWidget(
                    label: "Nama Jenis Hama",
                    hint: "Contoh: Tikus",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama jenis hama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
            buttonText: widget.isEdit ? 'Simpan Perubahan' : 'Tambah Jenis Hama',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
