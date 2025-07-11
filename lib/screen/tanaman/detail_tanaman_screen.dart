import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/service/jenis_budidaya_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:smart_farming_app/widget/image_builder.dart';
import 'package:smart_farming_app/widget/list_items.dart';

class DetailTanamanScreen extends StatefulWidget {
  final String? idTanaman;

  const DetailTanamanScreen({super.key, this.idTanaman});

  @override
  State<DetailTanamanScreen> createState() => _DetailTanamanScreenState();
}

class _DetailTanamanScreenState extends State<DetailTanamanScreen> {
  final JenisBudidayaService _jenisBudidayaService = JenisBudidayaService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _tanaman;
  List<dynamic> _kebunList = [];
  int _jumlahTanaman = 0;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    if (widget.idTanaman == null || widget.idTanaman!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppToast(
            context,
            'ID tanaman tidak ditemukan. Silakan pilih tanaman terlebih dahulu.',
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
          await _jenisBudidayaService.getJenisBudidayaById(widget.idTanaman!);
      final role = await _authService.getUserRole();

      if (mounted) {
        if (response['status'] == true && response['data'] != null) {
          setState(() {
            _tanaman = response['data']['jenisBudidaya'];
            _kebunList =
                List<dynamic>.from(response['data']['unitBudidaya'] ?? []);
            _jumlahTanaman = response['data']['jumlahBudidaya'] as int? ?? 0;
            _userRole = role;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _userRole = role;
          });
          showAppToast(
              context, response['message'] ?? 'Gagal memuat detail tanaman');
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
              'Apakah Anda yakin ingin menghapus data jenis tanaman ini beserta data terkait (unit budidaya dan objek budidaya)? Tindakan ini tidak dapat dibatalkan.'),
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
    if (!mounted || widget.idTanaman == null || _isDeleting) return;
    setState(() {
      _isDeleting = true;
    });
    try {
      final response =
          await _jenisBudidayaService.deleteJenisBudidaya(widget.idTanaman!);
      if (!mounted) return;

      if (response['status'] == true) {
        showAppToast(
          context,
          'Data jenis tanaman berhasil dihapus.',
          isError: false,
        );

        context.pop();
      } else {
        showAppToast(context,
            response['message'] ?? 'Gagal menghapus data jenis tanaman');
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
            title: 'Daftar Jenis Tanaman',
            greeting: 'Detail Jenis Tanaman',
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tanaman == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Gagal memuat detail tanaman.',
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
                                url: _tanaman?['gambar'] as String? ?? '',
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
                              Text("Informasi Jenis Tanaman",
                                  style: bold18.copyWith(color: dark1)),
                              const SizedBox(height: 12),
                              infoItem("Nama jenis tanaman",
                                  _tanaman?['nama'] ?? 'N/A'),
                              infoItem(
                                  "Nama latin", _tanaman?['latin'] ?? 'N/A'),
                              infoItem("Jumlah dibudidaya",
                                  '$_jumlahTanaman tanaman'),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Status tanaman",
                                        style: medium14.copyWith(color: dark1)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (_tanaman?['status'] == true ||
                                                _tanaman?['status'] == 1)
                                            ? green2.withValues(alpha: 0.1)
                                            : red.withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        (_tanaman?['status'] == true ||
                                                _tanaman?['status'] == 1)
                                            ? 'Aktif'
                                            : 'Tidak Aktif',
                                        style: (_tanaman?['status'] == true ||
                                                _tanaman?['status'] == 1)
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
                                      _tanaman?['createdAt'] as String?)),
                              infoItem(
                                  "Waktu didaftarkan",
                                  _formatWaktu(
                                      _tanaman?['createdAt'] as String?)),
                              const SizedBox(height: 8),
                              Text("Deskripsi tanaman",
                                  style: medium14.copyWith(color: dark1)),
                              const SizedBox(height: 8),
                              Text(
                                _tanaman?['detail'] ?? 'Tidak ada deskripsi',
                                style: regular14.copyWith(color: dark2),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                        if (_kebunList.isNotEmpty)
                          ListItem(
                            key: const Key('kebun_list_item'),
                            title: 'Terdaftar pada kebun',
                            type: 'basic',
                            items: _kebunList.map((item) {
                              return {
                                'name': item['nama'] ?? 'N/A',
                                'icon': item['gambar'] as String? ?? '',
                                'id': item['id'],
                                'category': 'Jumlah: ${item['jumlah'] ?? 0}',
                              };
                            }).toList(),
                          )
                        else
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text("Tidak terdaftar pada kebun manapun.",
                                  style: regular14.copyWith(color: dark2),
                                  key: const Key('no_kebun_message'))),
                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar:
          _isLoading || _tanaman == null || _userRole != 'pjawab'
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
                            if (widget.idTanaman != null) {
                              context
                                  .push(
                                    '/tambah-tanaman',
                                    extra: AddTanamanScreen(
                                      onTanamanAdded: () {
                                        _fetchData();
                                      },
                                      isEdit: true,
                                      idTanaman: widget.idTanaman,
                                    ),
                                  )
                                  .then((value) {});
                            }
                          },
                          buttonText: 'Ubah Data',
                          backgroundColor: yellow2,
                          textStyle: semibold16.copyWith(color: white),
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
