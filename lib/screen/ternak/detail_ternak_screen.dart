import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailTernakScreen extends StatefulWidget {
  final String? idTernak;

  const DetailTernakScreen({super.key, this.idTernak});

  @override
  State<DetailTernakScreen> createState() => _DetailTernakScreenState();
}

class _DetailTernakScreenState extends State<DetailTernakScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _ternak;
  List<dynamic> _kandangList = [];
  int _jumlahTernak = 0;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    if (widget.idTernak == null || widget.idTernak!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(context,
              'ID ternak tidak ditemukan. Silakan kembali ke daftar ternak.',
              title: 'Kesalahan');
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
          await _jenisBudidayaService.getJenisBudidayaById(widget.idTernak!);
      final role = await _authService.getUserRole();

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _ternak = response['data']['jenisBudidaya'];
            _kandangList =
                List<dynamic>.from(response['data']['unitBudidaya'] ?? []);
            _jumlahTernak = response['data']['jumlahBudidaya'] as int? ?? 0;
            _userRole = role;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _ternak = null;
            _userRole = role;
          });
          showAppToast(
              context, response['message'] ?? 'Gagal memuat data jenis ternak');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _ternak = null;
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
              'Apakah Anda yakin ingin menghapus data jenis ternak ini beserta data terkait (unit budidaya/kandang dan objek budidaya)? Tindakan ini tidak dapat dibatalkan.'),
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
    if (!mounted || widget.idTernak == null || _isDeleting) return;
    setState(() {
      _isDeleting = true;
    });
    try {
      final response =
          await _jenisBudidayaService.deleteJenisBudidaya(widget.idTernak!);
      if (!mounted) return;

      if (response['status'] == true) {
        showAppToast(
          context,
          'Data jenis ternak berhasil dihapus.',
          isError: false,
        );
        context.pop();
      } else {
        showAppToast(context,
            response['message'] ?? 'Gagal menghapus data jenis ternak');
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
            title: 'Manajemen Jenis Ternak',
            greeting: 'Detail Jenis Ternak',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _ternak == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Gagal memuat detail ternak.',
                              style: regular12.copyWith(color: dark2),
                              key: const Key('errorText')),
                          const SizedBox(height: 10),
                          ElevatedButton(
                              key: const Key('retryButton'),
                              onPressed: _fetchData,
                              child: Text('Coba Lagi',
                                  style: regular12.copyWith(color: dark2),
                                  key: const Key('retryButtonText'))),
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
                                url: _ternak?['gambar'] as String? ?? '',
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
                              Text("Informasi Jenis Ternak",
                                  style: bold18.copyWith(color: dark1)),
                              const SizedBox(height: 12),
                              infoItem("Nama jenis ternak",
                                  _ternak?['nama'] ?? 'N/A'),
                              infoItem(
                                  "Nama latin", _ternak?['latin'] ?? 'N/A'),
                              infoItem("Jumlah ternak", '$_jumlahTernak ekor'),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Status ternak",
                                        style: medium14.copyWith(color: dark1)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (_ternak?['status'] == true ||
                                                _ternak?['status'] == 1)
                                            ? green2.withValues(alpha: .1)
                                            : red.withValues(alpha: .1),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        (_ternak?['status'] == true ||
                                                _ternak?['status'] == 1)
                                            ? 'Aktif'
                                            : 'Tidak Aktif',
                                        style: (_ternak?['status'] == true ||
                                                _ternak?['status'] == 1)
                                            ? regular12.copyWith(color: green2)
                                            : regular12.copyWith(color: red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              infoItem(
                                  "Tanggal didaftarkan",
                                  _formatTanggal(
                                      _ternak?['createdAt'] as String?)),
                              infoItem(
                                  "Waktu didaftarkan",
                                  _formatWaktu(
                                      _ternak?['createdAt'] as String?)),
                              const SizedBox(height: 8),
                              Text("Deskripsi ternak",
                                  style: medium14.copyWith(color: dark1)),
                              const SizedBox(height: 8),
                              Text(
                                _ternak?['detail'] ?? 'Tidak ada deskripsi',
                                style: regular14.copyWith(color: dark2),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                        if (_kandangList.isNotEmpty)
                          ListItem(
                            key: const Key('kandangList'),
                            title: 'Terdaftar pada kandang',
                            type: 'basic',
                            items: _kandangList.map((item) {
                              return {
                                'name': item['nama'] ?? 'N/A',
                                'icon': item['gambar'] as String? ?? '',
                                'id': item['id'],
                                'category':
                                    'Jumlah: ${item['jumlah'] ?? 0} ekor',
                              };
                            }).toList(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text("Tidak terdaftar pada kandang manapun.",
                                key: const Key('noKandangText'),
                                style: regular14.copyWith(color: dark2)),
                          ),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar:
          _isLoading || _ternak == null || _userRole != 'pjawab'
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomButton(
                          key: const Key('editTernakButton'),
                          onPressed: () {
                            if (widget.idTernak != null) {
                              context.push(
                                '/tambah-ternak',
                                extra: AddTernakScreen(
                                  onTernakAdded: () {
                                    _fetchData();
                                  },
                                  isEdit: true,
                                  idTernak: widget.idTernak,
                                ),
                              );
                            }
                          },
                          buttonText: 'Ubah Data',
                          backgroundColor: yellow2,
                          textStyle: semibold16.copyWith(color: white),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          key: const Key('deleteTernakButton'),
                          onPressed: _isDeleting
                              ? null
                              : () {
                                  _handleDeleteConfirmation();
                                },
                          buttonText: 'Hapus Data',
                          backgroundColor: red,
                          textStyle: semibold16.copyWith(color: white),
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
