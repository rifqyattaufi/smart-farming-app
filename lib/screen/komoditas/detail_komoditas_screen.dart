import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_ternak_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/komoditas_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';

class DetailKomoditasScreen extends StatefulWidget {
  final String? idKomoditas;

  const DetailKomoditasScreen({super.key, this.idKomoditas});

  @override
  State<DetailKomoditasScreen> createState() => _DetailTanamanScreenState();
}

class _DetailTanamanScreenState extends State<DetailKomoditasScreen> {
  final KomoditasService _komoditasService = KomoditasService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _komoditas;
  int _jumlahHasilPanen = 0;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    if (widget.idKomoditas == null || widget.idKomoditas!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(
            context,
            'ID komoditas tidak ditemukan. Silakan pilih komoditas terlebih dahulu.',
          );
          context.pop();
        }
      });
      setState(() {
        _isLoading = false;
      });
    } else {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await _komoditasService.getKomoditasById(widget.idKomoditas!);
      final role = await _authService.getUserRole();

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _komoditas = response['data'];
            _jumlahHasilPanen = response['data']['jumlah'] as int? ?? 0;
            _userRole = role;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _userRole = role;
          });
          showAppToast(
              context, response['message'] ?? 'Gagal memuat detail komoditas');
        }
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

  Future<void> _handleDeleteConfirmation() async {
    if (_isDeleting || !mounted) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
              'Apakah Anda yakin ingin menghapus data komoditas ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              key: const Key('cancelButton'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              key: const Key('deleteButton'),
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteData();
    }
  }

  Future<void> _deleteData() async {
    if (!mounted || widget.idKomoditas == null || _isDeleting) return;
    setState(() {
      _isDeleting = true;
    });
    try {
      final response =
          await _komoditasService.deleteKomoditas(widget.idKomoditas!);
      if (!mounted) return;

      if (response['status'] == true) {
        showAppToast(
          context,
          'Data komoditas berhasil dihapus.',
          isError: false,
        );

        context.pop();
      } else {
        showAppToast(
            context, response['message'] ?? 'Gagal menghapus data komoditas');
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  String _formatTanggal(String? tanggalString) {
    if (tanggalString == null || tanggalString.isEmpty) {
      return 'Tidak diketahui';
    }
    try {
      final dateTime = DateTime.tryParse(tanggalString);
      if (dateTime == null) return 'Format tanggal tidak valid';
      return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return 'Error format tanggal';
    }
  }

  String _formatWaktu(String? tanggalString) {
    if (tanggalString == null || tanggalString.isEmpty) {
      return 'Tidak diketahui';
    }
    try {
      final dateTime = DateTime.tryParse(tanggalString);
      if (dateTime == null) return 'Format waktu tidak valid';
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return 'Error format waktu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
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
            title: 'Manajemen Komoditas',
            greeting: 'Detail Komoditas',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _komoditas == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Gagal memuat detail komoditas.',
                            style: regular12.copyWith(color: dark2),
                            key: const Key('error_message'),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              onPressed: _fetchData,
                              child: Text('Coba Lagi',
                                  style: regular12.copyWith(color: dark2),
                                  key: const Key('retry_button')))
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: DottedBorder(
                            color: green1,
                            strokeWidth: 1.5,
                            dashPattern: const [6, 4],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ImageBuilder(
                                url: _komoditas?['gambar'] as String? ?? '',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Informasi Komoditas Tanaman",
                                  style: bold18.copyWith(color: dark1)),
                              const SizedBox(height: 12),
                              infoItem("Nama komoditas",
                                  _komoditas?['nama'] ?? 'N/A'),
                              infoItem(
                                  "Nama jenis tanaman",
                                  _komoditas?['JenisBudidaya']?['nama'] ??
                                      'N/A'),
                              infoItem("Jumlah hasil panen",
                                  "$_jumlahHasilPanen ${_komoditas?['Satuan']?['lambang'] ?? 'N/A'}"),
                              infoItem(
                                "Satuan",
                                "${_komoditas?['Satuan']?['nama'] ?? 'N/A'} - ${_komoditas?['Satuan']?['lambang'] ?? 'N/A'}",
                              ),
                              infoItem(
                                  "Tanggal didaftarkan",
                                  _formatTanggal(
                                      _komoditas?['createdAt'] as String?)),
                              infoItem(
                                  "Waktu didaftarkan",
                                  _formatWaktu(
                                      _komoditas?['createdAt'] as String?)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar:
          _isLoading || _komoditas == null || _userRole != 'pjawab'
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomButton(
                          key: const Key('ubah_data_button'),
                          onPressed: () {
                            if (widget.idKomoditas != null) {
                              if (_komoditas?['JenisBudidaya']?['tipe'] ==
                                  'hewan') {
                                context
                                    .push(
                                      '/tambah-komoditas-ternak',
                                      extra: AddKomoditasTernakScreen(
                                        onKomoditasAdded: () {
                                          _fetchData();
                                        },
                                        isEdit: true,
                                        idKomoditas: widget.idKomoditas,
                                      ),
                                    )
                                    .then((value) {});
                              } else {
                                context
                                    .push(
                                      '/tambah-komoditas-tanaman',
                                      extra: AddKomoditasTanamanScreen(
                                        onKomoditasTanamanAdded: () {
                                          _fetchData();
                                        },
                                        isEdit: true,
                                        idKomoditas: widget.idKomoditas,
                                      ),
                                    )
                                    .then((value) {});
                              }
                            }
                          },
                          buttonText: 'Ubah Data',
                          backgroundColor: yellow2,
                          textStyle: semibold16.copyWith(color: white),
                          textColor: white,
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          key: const Key('hapus_data_button'),
                          onPressed: _isDeleting
                              ? null
                              : () {
                                  _handleDeleteConfirmation();
                                },
                          buttonText: 'Hapus Data',
                          backgroundColor: red,
                          textStyle: semibold16.copyWith(color: white),
                          textColor: white,
                          isLoading: _isDeleting,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: medium14.copyWith(color: dark1)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: regular14.copyWith(color: dark2),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
