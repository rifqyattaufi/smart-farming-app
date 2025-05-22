import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/hama_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddHamaScreen extends StatefulWidget {
  final VoidCallback? onHamaAdded;
  final bool isUpdate;
  final String? id;
  final String? nama;

  const AddHamaScreen({
    super.key,
    this.onHamaAdded,
    this.isUpdate = false,
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
    if (widget.isUpdate) {
      _nameController.text = widget.nama ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;

    try {
      if (!_formKey.currentState!.validate()) return;

      setState(() {
        _isLoading = true;
      });

      final data = {
        'nama': _nameController.text,
      };

      Map<String, dynamic>? response;

      if (widget.isUpdate) {
        response = await _hamaService.updateJenisHama(
          widget.id!,
          data,
        );
      } else {
        response = await _hamaService.createJenisHama(data);
      }

      if (response['status'] == true) {
        if (widget.onHamaAdded != null) {
          widget.onHamaAdded!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.isUpdate
                  ? 'Berhasil memperbarui data jenis hama'
                  : 'Berhasil menambahkan data jenis hama'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
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
          title: const Header(
              headerType: HeaderType.back,
              title: 'Laporan Hama',
              greeting: 'Tambah Hama'),
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
                    label: "Nama hama",
                    hint: "Contoh: Tikus",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama jenis hama tidak boleh kosong';
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
                    isLoading: _isLoading,
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
