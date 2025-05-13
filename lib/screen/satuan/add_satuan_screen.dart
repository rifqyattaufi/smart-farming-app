import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';

class AddSatuanScreen extends StatefulWidget {
  final VoidCallback? onSatuanAdded;
  final bool isUpdate;
  final String? id;
  final String? nama;
  final String? lambang;

  const AddSatuanScreen({
    super.key,
    this.onSatuanAdded,
    this.isUpdate = false,
    this.id,
    this.nama,
    this.lambang,
  });

  @override
  _AddSatuanScreenState createState() => _AddSatuanScreenState();
}

class _AddSatuanScreenState extends State<AddSatuanScreen> {
  final SatuanService _satuanService = SatuanService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lambangController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _nameController.text = widget.nama ?? '';
      _lambangController.text = widget.lambang ?? '';
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
        'lambang': _lambangController.text,
      };

      Map<String, dynamic>? response;

      if (widget.isUpdate) {
        response = await _satuanService.updateSatuan(
          widget.id!,
          data,
        );
      } else {
        response = await _satuanService.createSatuan(data);
      }

      if (response['status'] == true) {
        if (widget.onSatuanAdded != null) {
          widget.onSatuanAdded!();
        }

        Navigator.pop(context);
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
              title: 'Manajemen Satuan',
              greeting: widget.isUpdate ? 'Edit Satuan' : 'Tambah Satuan'),
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
                    label: "Nama satuan",
                    hint: "Contoh: Kilogram",
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama satuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  InputFieldWidget(
                    label: "Lambang satuan",
                    hint: "Contoh: Kg",
                    controller: _lambangController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lambang satuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 450),
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
