import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/kategori_inv_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddKategoriInvScreen extends StatefulWidget {
  final VoidCallback? onKategoriInvAdded;
  final bool isUpdate;
  final String? id;
  final String? nama;

  const AddKategoriInvScreen({
    super.key,
    this.onKategoriInvAdded,
    this.isUpdate = false,
    this.id,
    this.nama,
  });

  @override
  _AddKategoriInvScreenState createState() => _AddKategoriInvScreenState();
}

class _AddKategoriInvScreenState extends State<AddKategoriInvScreen> {
  final KategoriInvService _kategoriInvService = KategoriInvService();

  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _nameController.text = widget.nama ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        isLoading = true;
      });

      final data = {
        'nama': _nameController.text,
      };

      Map<String, dynamic>? response;

      if (widget.isUpdate) {
        response = await _kategoriInvService.updateKategoriInventaris(
            widget.id!, data);
      } else {
        response = await _kategoriInvService.createKategoriInventaris(data);
      }

      if (response['status'] == true) {
        if (widget.onKategoriInvAdded != null) {
          widget.onKategoriInvAdded!();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isUpdate
                  ? 'Berhasil memperbarui data kategori inventaris'
                  : 'Berhasil menambahkan data kategori inventaris'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Terjadi kesalahan saat menambahkan: $e'),
            backgroundColor: Colors.red),
      );
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
              title: 'Manajemen Kategori Inventaris',
              greeting: widget.isUpdate
                  ? 'Edit Kategori Inventaris'
                  : 'Tambah Kategori Inventaris'),
        ),
      ),
      body: SafeArea(
        child: ListView(children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputFieldWidget(
                    label: "Nama kategori inventaris",
                    hint: "Contoh: Bibit tanaman",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama kategori inventaris tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 520),
                  CustomButton(
                    onPressed: _submitForm,
                    backgroundColor: green1,
                    textStyle: semibold16,
                    textColor: white,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
