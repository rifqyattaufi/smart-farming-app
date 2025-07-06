import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_harian_tanaman_tabel_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_tanaman_screen.dart';
import 'package:smart_farming_app/service/inventaris_service.dart';
import 'package:smart_farming_app/service/satuan_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/utils/app_utils.dart';
import 'package:smart_farming_app/widget/banner.dart';
import 'package:smart_farming_app/widget/button.dart';
import 'package:smart_farming_app/widget/dropdown_field.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:smart_farming_app/widget/input_field.dart';
import 'package:smart_farming_app/widget/radio_field.dart';

class PelaporanTindakanMassalScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String greeting;
  final String tipe;
  final int step;

  const PelaporanTindakanMassalScreen({
    super.key,
    this.data = const {},
    required this.greeting,
    required this.tipe,
    this.step = 1,
  });

  @override
  State<PelaporanTindakanMassalScreen> createState() =>
      _PelaporanTindakanMassalScreenState();
}

class _PelaporanTindakanMassalScreenState
    extends State<PelaporanTindakanMassalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final InventarisService _inventarisService = InventarisService();
  final SatuanService _satuanService = SatuanService();

  // Status untuk tindakan massal
  String statusPenyiraman = 'Ya';
  String statusPruning = 'Ya';
  String statusNutrisi = 'Ya';
  String statusRepotting = 'Ya';

  // Data nutrisi massal
  String? statusPemberianMassal = 'Pupuk';
  Map<String, dynamic> selectedBahanMassal = {};
  List<Map<String, dynamic>> listBahanVitamin = [];
  List<Map<String, dynamic>> listBahanPupuk = [];
  List<Map<String, dynamic>> listBahanDisinfektan = [];

  final TextEditingController _sizeMassalController = TextEditingController();
  final TextEditingController _satuanMassalController = TextEditingController();

  bool _isLoadingInventaris = false;

  @override
  void initState() {
    super.initState();
    _fetchInventarisData();
  }

  @override
  void dispose() {
    _sizeMassalController.dispose();
    _satuanMassalController.dispose();
    super.dispose();
  }

  Future<void> _fetchInventarisData() async {
    setState(() {
      _isLoadingInventaris = true;
    });

    try {
      final responseVitamin =
          await _inventarisService.getInventarisByKategoriName('Vitamin');
      final responsePupuk =
          await _inventarisService.getInventarisByKategoriName('Pupuk');
      final responseDisinfektan =
          await _inventarisService.getInventarisByKategoriName('Disinfektan');

      if (responseVitamin['status']) {
        setState(() {
          listBahanVitamin = responseVitamin['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
                  })
              .toList();
        });
      }

      if (responsePupuk['status']) {
        setState(() {
          listBahanPupuk = responsePupuk['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
                  })
              .toList();
        });
      }

      if (responseDisinfektan['status']) {
        setState(() {
          listBahanDisinfektan = responseDisinfektan['data']
              .map<Map<String, dynamic>>((item) => {
                    'name': item['nama'],
                    'id': item['id'],
                    'satuanId': item['SatuanId'],
                    'stok': item['jumlah'],
                    'satuanNama': item['Satuan']?['nama'] ?? '',
                  })
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        showAppToast(context, 'Terjadi kesalahan: $e. Silakan coba lagi',
            title: 'Error Tidak Terduga 😢');
      }
    } finally {
      setState(() {
        _isLoadingInventaris = false;
      });
    }
  }

  Future<void> _changeSatuanMassal() async {
    final satuanId = selectedBahanMassal['satuanId'];
    if (satuanId != null) {
      final response = await _satuanService.getSatuanById(satuanId);
      if (response['status']) {
        setState(() {
          _satuanMassalController.text =
              "${response['data']['nama']} - ${response['data']['lambang']}";
        });
      } else {
        showAppToast(context,
            response['message'] ?? 'Terjadi kesalahan tidak diketahui');
      }
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      showAppToast(
        context,
        'Harap lengkapi semua field yang diperlukan',
      );
      return;
    }

    // Validasi khusus untuk nutrisi jika diaktifkan
    if (statusNutrisi == 'Ya') {
      if (selectedBahanMassal.isEmpty) {
        showAppToast(
          context,
          'Harap pilih bahan nutrisi yang akan digunakan',
          isError: true,
        );
        return;
      }
      if (_sizeMassalController.text.isEmpty) {
        showAppToast(
          context,
          'Harap masukkan jumlah/dosis nutrisi',
          isError: true,
        );
        return;
      }
    }

    // Menyiapkan data tindakan massal
    final updatedData = Map<String, dynamic>.from(widget.data ?? {});
    updatedData['tindakanMassal'] = {
      'penyiraman': statusPenyiraman == 'Ya',
      'pruning': statusPruning == 'Ya',
      'nutrisi': statusNutrisi == 'Ya',
      'repotting': statusRepotting == 'Ya',
      // Data nutrisi massal jika diaktifkan
      if (statusNutrisi == 'Ya') ...{
        'nutrisiData': {
          'jenisPemberian': statusPemberianMassal,
          'bahan': selectedBahanMassal,
          'jumlahDosis': double.tryParse(_sizeMassalController.text) ?? 0.0,
          'satuan': _satuanMassalController.text,
        }
      }
    };

    // Navigasi ke screen tabel input cepat
    context.push('/pelaporan-harian-tanaman-tabel',
        extra: PelaporanHarianTanamanTabelScreen(
          greeting: widget.greeting,
          data: updatedData,
          tipe: widget.tipe,
          step: widget.step + 1,
        ));
  }

  Future<void> _editTanaman() async {
    // Kembali ke screen pilih tanaman dengan data yang sudah ada
    final result = await context.push('/pilih-tanaman',
        extra: PilihTanamanScreen(
          greeting: widget.greeting,
          data: widget.data,
          tipe: widget.tipe,
          step: widget.step - 1,
        ));

    // Jika ada perubahan tanaman, reload screen dengan data baru
    if (result != null && mounted) {
      final Map<String, dynamic> updatedData = result as Map<String, dynamic>;
      // Navigate ulang ke screen ini dengan data yang sudah diupdate
      context.pushReplacement('/pelaporan-tindakan-massal',
          extra: PelaporanTindakanMassalScreen(
            greeting: widget.greeting,
            data: updatedData,
            tipe: widget.tipe,
            step: widget.step,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? objekBudidayaList = widget.data?['objekBudidaya'];
    final int jumlahTanaman = objekBudidayaList?.length ?? 0;

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
            title: 'Menu Pelaporan',
            greeting: widget.greeting,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                BannerWidget(
                  title: 'Step ${widget.step} - Tindakan Massal',
                  subtitle:
                      'Pilih tindakan yang dilakukan untuk semua tanaman!',
                  showDate: true,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan untuk $jumlahTanaman Tanaman Terpilih',
                          style: bold20.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Pilih tindakan yang dilakukan untuk semua tanaman yang dipilih. Pengaturan ini akan diterapkan ke semua tanaman.',
                          style: medium14.copyWith(color: dark2),
                        ),
                        const SizedBox(height: 16),

                        // Daftar tanaman yang dipilih
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tanaman yang Dipilih ($jumlahTanaman)',
                                    style: semibold16.copyWith(color: dark1),
                                  ),
                                  TextButton.icon(
                                    onPressed: _editTanaman,
                                    icon: Icon(Icons.edit,
                                        size: 16, color: green1),
                                    label: Text(
                                      'Edit',
                                      style: semibold12.copyWith(color: green1),
                                    ),
                                    key: const Key('edit_tanaman_button'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (objekBudidayaList != null &&
                                  objekBudidayaList.isNotEmpty)
                                Column(
                                  children: objekBudidayaList
                                      .take(3)
                                      .map<Widget>((objek) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: green1,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              objek['name'] ?? 'Tanaman',
                                              style: regular12.copyWith(
                                                  color: dark1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              if (jumlahTanaman > 3)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'dan ${jumlahTanaman - 3} tanaman lainnya...',
                                        style: regular12.copyWith(
                                            color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        RadioField(
                          key: const Key('status_penyiraman_massal'),
                          label: 'Dilakukan penyiraman?',
                          selectedValue: statusPenyiraman,
                          options: const ['Ya', 'Tidak'],
                          onChanged: (value) {
                            setState(() {
                              statusPenyiraman = value;
                            });
                          },
                        ),
                        RadioField(
                          key: const Key('status_pruning_massal'),
                          label: 'Dilakukan pruning?',
                          selectedValue: statusPruning,
                          options: const ['Ya', 'Tidak'],
                          onChanged: (value) {
                            setState(() {
                              statusPruning = value;
                            });
                          },
                        ),
                        RadioField(
                          key: const Key('status_nutrisi_massal'),
                          label:
                              'Dilakukan pemberian pupuk/vitamin/disinfektan?',
                          selectedValue: statusNutrisi,
                          options: const ['Ya', 'Tidak'],
                          onChanged: (value) {
                            setState(() {
                              statusNutrisi = value;
                              if (value == 'Tidak') {
                                // Reset data nutrisi jika tidak dipilih
                                selectedBahanMassal = {};
                                _sizeMassalController.clear();
                                _satuanMassalController.clear();
                              }
                            });
                          },
                        ),

                        // Form input nutrisi massal jika dipilih
                        if (statusNutrisi == 'Ya') ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.eco,
                                        color: Colors.orange.shade700,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Data Pemberian Nutrisi Massal',
                                      style: semibold16.copyWith(
                                          color: Colors.orange.shade700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Atur nutrisi yang akan diberikan untuk semua tanaman dengan dosis yang sama.',
                                  style: regular12.copyWith(
                                      color: Colors.orange.shade600),
                                ),
                                const SizedBox(height: 16),
                                RadioField(
                                  key: const Key('status_pemberian_massal'),
                                  label: 'Jenis Pemberian',
                                  selectedValue:
                                      statusPemberianMassal ?? 'Pupuk',
                                  options: const [
                                    'Pupuk',
                                    'Vitamin',
                                    'Disinfektan'
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      statusPemberianMassal = value;
                                      selectedBahanMassal = {};
                                      _satuanMassalController.clear();
                                      _sizeMassalController.clear();
                                    });
                                  },
                                ),
                                if (_isLoadingInventaris)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else
                                  DropdownFieldWidget(
                                    key: const Key('bahan_pemberian_massal'),
                                    label: "Nama Bahan",
                                    hint: "Pilih jenis bahan",
                                    items: (() {
                                      switch (statusPemberianMassal) {
                                        case 'Vitamin':
                                          return listBahanVitamin
                                              .map((item) =>
                                                  item['name'] as String)
                                              .toList();
                                        case 'Pupuk':
                                          return listBahanPupuk
                                              .map((item) =>
                                                  item['name'] as String)
                                              .toList();
                                        case 'Disinfektan':
                                          return listBahanDisinfektan
                                              .map((item) =>
                                                  item['name'] as String)
                                              .toList();
                                        default:
                                          return <String>[];
                                      }
                                    })(),
                                    selectedValue:
                                        selectedBahanMassal['name'] as String?,
                                    onChanged: (value) {
                                      if (value == null) return;

                                      Map<String, dynamic> findBahan(
                                          List<Map<String, dynamic>> list) {
                                        return list.firstWhere(
                                          (item) => item['name'] == value,
                                          orElse: () => <String, dynamic>{},
                                        );
                                      }

                                      setState(() {
                                        Map<String, dynamic> bahanTerpilih = {};
                                        switch (statusPemberianMassal) {
                                          case 'Vitamin':
                                            bahanTerpilih =
                                                findBahan(listBahanVitamin);
                                            break;
                                          case 'Pupuk':
                                            bahanTerpilih =
                                                findBahan(listBahanPupuk);
                                            break;
                                          case 'Disinfektan':
                                            bahanTerpilih =
                                                findBahan(listBahanDisinfektan);
                                            break;
                                        }
                                        selectedBahanMassal = bahanTerpilih;

                                        if (bahanTerpilih.isNotEmpty) {
                                          _changeSatuanMassal();
                                        } else {
                                          _satuanMassalController.clear();
                                        }
                                      });
                                    },
                                    validator: (value) {
                                      if (statusNutrisi == 'Ya' &&
                                          (value == null || value.isEmpty)) {
                                        return 'Pilih bahan';
                                      }
                                      return null;
                                    },
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: InputFieldWidget(
                                        key: const Key('jumlah_dosis_massal'),
                                        label: (() {
                                          String labelUntukJumlah =
                                              "Jumlah/dosis per tanaman";
                                          String satuanDisplay = "";

                                          if (selectedBahanMassal.isNotEmpty &&
                                              selectedBahanMassal['stok'] !=
                                                  null) {
                                            dynamic stokValue =
                                                selectedBahanMassal['stok'];
                                            String stokFormatted = "";

                                            if (stokValue is num) {
                                              stokFormatted =
                                                  stokValue.toStringAsFixed(1);
                                            } else {
                                              stokFormatted =
                                                  stokValue.toString();
                                            }

                                            satuanDisplay = selectedBahanMassal[
                                                    'satuanNama'] as String? ??
                                                '';
                                            labelUntukJumlah =
                                                "Jumlah/dosis per tanaman (Sisa: $stokFormatted $satuanDisplay)";
                                          }
                                          return labelUntukJumlah;
                                        })(),
                                        hint: "Contoh: 10",
                                        controller: _sizeMassalController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        validator: (value) {
                                          if (statusNutrisi == 'Ya') {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Masukkan jumlah/dosis';
                                            }
                                            final number =
                                                double.tryParse(value);
                                            if (number == null) {
                                              return 'Masukkan angka yang valid';
                                            }
                                            if (number <= 0) {
                                              return 'Jumlah/dosis harus lebih dari 0';
                                            }

                                            // Validasi stok - kalikan dengan jumlah tanaman
                                            final List<dynamic>?
                                                objekBudidayaList =
                                                widget.data?['objekBudidaya'];
                                            final int jumlahTanaman =
                                                objekBudidayaList?.length ?? 0;
                                            final double totalDosis =
                                                number * jumlahTanaman;

                                            if (selectedBahanMassal
                                                    .isNotEmpty &&
                                                selectedBahanMassal['stok'] !=
                                                    null) {
                                              dynamic stokValue =
                                                  selectedBahanMassal['stok'];
                                              if (stokValue is num &&
                                                  totalDosis > stokValue) {
                                                String satuanDisplay =
                                                    selectedBahanMassal[
                                                                'satuanNama']
                                                            as String? ??
                                                        '';
                                                return 'Total dosis ($totalDosis) melebihi stok (${stokValue.toStringAsFixed(1)} $satuanDisplay)';
                                              }
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: InputFieldWidget(
                                        key: const Key('satuan_dosis_massal'),
                                        label: "Satuan",
                                        hint: "",
                                        controller: _satuanMassalController,
                                        isDisabled: true,
                                        validator: (value) {
                                          if (statusNutrisi == 'Ya' &&
                                              (value == null ||
                                                  value.isEmpty)) {
                                            return 'Pilih satuan';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        RadioField(
                          key: const Key('status_repotting_massal'),
                          label:
                              'Dilakukan repotting (pemindahan pot/mengganti media tanam)?',
                          selectedValue: statusRepotting,
                          options: const ['Ya', 'Tidak'],
                          onChanged: (value) {
                            setState(() {
                              statusRepotting = value;
                            });
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.blue.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Informasi',
                                    style: semibold14.copyWith(
                                        color: Colors.blue.shade700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pengaturan di atas akan diterapkan untuk semua $jumlahTanaman tanaman yang dipilih. Pada langkah selanjutnya, Anda akan mengisi data spesifik untuk setiap tanaman seperti tinggi tanaman dan kondisi daun.',
                                style: regular12.copyWith(
                                    color: Colors.blue.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            onPressed: _submitForm,
            buttonText: 'Lanjutkan ke Data Individual',
            backgroundColor: green1,
            textStyle: semibold16.copyWith(color: white),
            key: const Key('next_to_individual_data_button'),
          ),
        ),
      ),
    );
  }
}
