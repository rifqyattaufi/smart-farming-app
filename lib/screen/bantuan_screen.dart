import 'package:flutter/material.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';
import 'package:url_launcher/url_launcher.dart';

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  State<BantuanScreen> createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  final AuthService _authService = AuthService();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await _authService.getUserRole();
    setState(() {
      userRole = role;
    });
  }

  String _getPanduanURL() {
    switch (userRole) {
      case 'pjawab':
        return 'https://www.canva.com/design/DAGs9p7pulc/1qSNfbHVpHxagF__cacXrg/edit?utm_content=DAGs9p7pulc&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton';
      case 'petugas':
        return 'https://www.canva.com/design/DAGtDJ_ImuE/KNu788X8ty2c69ESpOxrJQ/edit?utm_content=DAGtDJ_ImuE&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton';
      case 'inventor':
        return 'https://www.canva.com/design/DAGtDCBE_P8/UR0M_D-j1RTqrXRwr75s5g/edit?utm_content=DAGtDCBE_P8&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton';
      default:
        return 'https://www.canva.com/design/DAGtDJ_ImuE/KNu788X8ty2c69ESpOxrJQ/edit?utm_content=DAGtDJ_ImuE&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton';
    }
  }

  // List<Map<String, dynamic>> _getFAQByRole() {
  //   switch (userRole) {
  //     case 'pjawab':
  //       return [
  //         {
  //           'question': 'Bagaimana cara memantau kinerja petugas lapangan?',
  //           'answer':
  //               'Masuk ke menu Dashboard > Monitoring Petugas untuk melihat aktivitas dan laporan petugas secara real-time.',
  //           'icon': Icons.supervisor_account,
  //         },
  //         {
  //           'question': 'Bagaimana cara mengatur jadwal petugas?',
  //           'answer':
  //               'Gunakan menu Manajemen > Jadwal Petugas untuk mengatur shift dan area kerja petugas.',
  //           'icon': Icons.schedule,
  //         },
  //         {
  //           'question': 'Bagaimana cara melihat laporan lengkap?',
  //           'answer':
  //               'Akses menu Laporan untuk melihat analisis kinerja, produktivitas, dan ringkasan operasional.',
  //           'icon': Icons.assessment,
  //         },
  //         {
  //           'question': 'Bagaimana cara mengatur notifikasi untuk tim?',
  //           'answer':
  //               'Masuk ke Pengaturan > Notifikasi Tim untuk mengatur alert dan broadcast ke seluruh tim.',
  //           'icon': Icons.notifications_active,
  //         },
  //       ];
  //     case 'petugas':
  //       return [
  //         {
  //           'question': 'Bagaimana cara melaporkan kondisi lapangan?',
  //           'answer':
  //               'Gunakan menu Laporan Lapangan, ambil foto kondisi tanaman/perangkat, dan isi formulir laporan.',
  //           'icon': Icons.report,
  //         },
  //         {
  //           'question': 'Bagaimana cara maintenance perangkat IoT?',
  //           'answer':
  //               'Masuk ke menu Perangkat, pilih perangkat yang perlu maintenance, dan ikuti checklist yang tersedia.',
  //           'icon': Icons.build,
  //         },
  //         {
  //           'question': 'Bagaimana cara mengecek tugas harian?',
  //           'answer':
  //               'Lihat dashboard utama atau menu Tugas untuk melihat jadwal dan tugas yang harus diselesaikan hari ini.',
  //           'icon': Icons.task_alt,
  //         },
  //         {
  //           'question': 'Bagaimana cara menginput data sensor manual?',
  //           'answer':
  //               'Jika sensor offline, gunakan menu Input Manual untuk memasukkan data pembacaan sensor secara manual.',
  //           'icon': Icons.input,
  //         },
  //       ];
  //     case 'inventor':
  //       return [
  //         {
  //           'question': 'Bagaimana cara mengakses data penelitian?',
  //           'answer':
  //               'Masuk ke menu Penelitian > Data Historis untuk mengakses dataset lengkap untuk analisis dan penelitian.',
  //           'icon': Icons.science,
  //         },
  //         {
  //           'question': 'Bagaimana cara mengexport data untuk analisis?',
  //           'answer':
  //               'Gunakan menu Export Data, pilih rentang waktu dan parameter yang diinginkan, lalu download dalam format CSV/Excel.',
  //           'icon': Icons.download,
  //         },
  //         {
  //           'question': 'Bagaimana cara mengatur parameter penelitian?',
  //           'answer':
  //               'Akses menu Konfigurasi Penelitian untuk mengatur parameter monitoring khusus dan algoritma analisis.',
  //           'icon': Icons.settings_applications,
  //         },
  //         {
  //           'question': 'Bagaimana cara menambahkan sensor eksperimental?',
  //           'answer':
  //               'Masuk ke menu Perangkat > Sensor Eksperimental untuk menambah dan konfigurasi sensor penelitian.',
  //           'icon': Icons.memory,
  //         },
  //       ];
  //     default:
  //       return [
  //         {
  //           'question': 'Bagaimana cara menambahkan perangkat IoT?',
  //           'answer':
  //               'Masuk ke menu Perangkat > Tambah Perangkat > Ikuti panduan setup yang tersedia.',
  //           'icon': Icons.device_hub,
  //         },
  //         {
  //           'question': 'Bagaimana cara melihat data sensor?',
  //           'answer':
  //               'Data sensor dapat dilihat di Dashboard utama atau menu Monitoring untuk detail lebih lengkap.',
  //           'icon': Icons.sensors,
  //         },
  //         {
  //           'question': 'Bagaimana cara mengatur notifikasi?',
  //           'answer':
  //               'Masuk ke Pengaturan > Notifikasi untuk mengatur jenis dan waktu notifikasi yang diinginkan.',
  //           'icon': Icons.notifications,
  //         },
  //         {
  //           'question': 'Bagaimana cara backup data?',
  //           'answer':
  //               'Data otomatis tersimpan di cloud. Anda juga dapat export data melalui menu Laporan.',
  //           'icon': Icons.backup,
  //         },
  //       ];
  //   }
  // }

  // List<Map<String, dynamic>> _getAdditionalResources() {
  //   switch (userRole) {
  //     case 'pjawab':
  //       return [
  //         {
  //           'title': 'Dashboard Analytics',
  //           'description': 'Panduan lengkap analisis dashboard manajemen',
  //           'icon': Icons.analytics,
  //           'url': 'https://docs.google.com/document/d/analytics-pjawab-guide',
  //         },
  //         {
  //           'title': 'SOP Manajemen Tim',
  //           'description': 'Standard Operating Procedure untuk pengelolaan tim',
  //           'icon': Icons.rule,
  //           'url': 'https://docs.google.com/document/d/sop-management-guide',
  //         },
  //         {
  //           'title': 'Template Laporan',
  //           'description': 'Template laporan berkala untuk penanggung jawab',
  //           'icon': Icons.description,
  //           'url':
  //               'https://docs.google.com/spreadsheets/template-laporan-pjawab',
  //         },
  //       ];
  //     case 'petugas':
  //       return [
  //         {
  //           'title': 'Checklist Lapangan',
  //           'description': 'Daftar pemeriksaan harian untuk petugas lapangan',
  //           'icon': Icons.checklist,
  //           'url': 'https://docs.google.com/document/d/checklist-lapangan',
  //         },
  //         {
  //           'title': 'Panduan Troubleshooting',
  //           'description': 'Solusi cepat untuk masalah perangkat IoT',
  //           'icon': Icons.handyman,
  //           'url': 'https://docs.google.com/document/d/troubleshooting-iot',
  //         },
  //         {
  //           'title': 'Aplikasi Mobile Companion',
  //           'description': 'Download aplikasi pendukung untuk tugas lapangan',
  //           'icon': Icons.phone_android,
  //           'url': 'https://play.google.com/store/apps/companion-app',
  //         },
  //       ];
  //     case 'inventor':
  //       return [
  //         {
  //           'title': 'API Documentation',
  //           'description': 'Dokumentasi lengkap API untuk integrasi sistem',
  //           'icon': Icons.code,
  //           'url': 'https://api-docs.smartfarming.com',
  //         },
  //         {
  //           'title': 'Dataset Research',
  //           'description': 'Akses dataset untuk penelitian dan pengembangan',
  //           'icon': Icons.dataset,
  //           'url': 'https://research.smartfarming.com/datasets',
  //         },
  //         {
  //           'title': 'Technical Specifications',
  //           'description':
  //               'Spesifikasi teknis perangkat dan protokol komunikasi',
  //           'icon': Icons.engineering,
  //           'url': 'https://docs.google.com/document/d/technical-specs',
  //         },
  //       ];
  //     default:
  //       return [
  //         {
  //           'title': 'Forum Komunitas',
  //           'description': 'Bergabung dengan komunitas pengguna smart farming',
  //           'icon': Icons.forum,
  //           'url': 'https://community.smartfarming.com',
  //         },
  //         {
  //           'title': 'Video Tutorial',
  //           'description': 'Koleksi video tutorial penggunaan aplikasi',
  //           'icon': Icons.video_library,
  //           'url': 'https://youtube.com/smartfarming-tutorials',
  //         },
  //       ];
  //   }
  // }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // void _showFAQDetail(String title, String content) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(title, style: semibold16.copyWith(color: dark1)),
  //         content: Text(content, style: regular14.copyWith(color: dark2)),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: Text('Tutup', style: semibold14.copyWith(color: green1)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
            title: 'Pengaturan Lainnya',
            greeting: 'Bantuan',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panduan Aplikasi Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: green1.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: green1.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.book, color: green1, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Panduan Aplikasi',
                          style: semibold16.copyWith(color: green1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Akses panduan lengkap untuk menggunakan aplikasi',
                      style: regular14.copyWith(color: dark2),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchURL(_getPanduanURL()),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Buka Panduan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: green1,
                          foregroundColor: white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Section
              // Text(
              //   'Pertanyaan yang Sering Diajukan',
              //   style: semibold18.copyWith(color: dark1),
              // ),
              // const SizedBox(height: 16),

              // ..._getFAQByRole().map((faq) => _buildFAQCard(
              //       faq['question'],
              //       faq['answer'],
              //       faq['icon'],
              //     )),

              // const SizedBox(height: 24),

              // Kontak Support Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dark1.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: dark1, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Butuh Bantuan Lebih Lanjut?',
                          style: semibold16.copyWith(color: dark1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tim support kami siap membantu Anda',
                      style: regular14.copyWith(color: dark1),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL(
                                'mailto:farmcenter@telkomuniversity.ac.id'),
                            icon: const Icon(Icons.email, size: 18),
                            label: const Text('Email'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _launchURL('https://wa.me/6281234567890'),
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Aplikasi',
                          style: semibold16.copyWith(color: dark1),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Versi Aplikasi', 'v1.0.0'),
                        _buildInfoRow('Developer', 'Smart Farming Team'),
                        _buildInfoRow('Update Terakhir', 'Juli 2025')
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Role-specific Resources Section
              // if (userRole != null)
              //   Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.all(20),
              //     decoration: BoxDecoration(
              //       color: Colors.blue.withValues(alpha: 0.1),
              //       borderRadius: BorderRadius.circular(12),
              //       border:
              //           Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             const Icon(Icons.library_books,
              //                 color: Colors.blue, size: 24),
              //             const SizedBox(width: 12),
              //             Text(
              //               'Sumber Daya Tambahan',
              //               style: semibold16.copyWith(color: Colors.blue),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 12),
              //         Text(
              //           'Sumber daya tambahan untuk mendukung penggunaan aplikasi',
              //           style: regular14.copyWith(color: dark2),
              //         ),
              //         const SizedBox(height: 16),
              //         ..._getAdditionalResources().map(
              //           (resource) => Container(
              //             margin: const EdgeInsets.only(bottom: 8),
              //             child: ListTile(
              //               contentPadding: const EdgeInsets.symmetric(
              //                   horizontal: 12, vertical: 4),
              //               leading: Icon(resource['icon'],
              //                   color: Colors.blue, size: 20),
              //               title: Text(
              //                 resource['title'],
              //                 style: semibold14.copyWith(color: dark1),
              //               ),
              //               subtitle: Text(
              //                 resource['description'],
              //                 style: regular12.copyWith(color: dark2),
              //               ),
              //               trailing: Icon(Icons.arrow_forward_ios,
              //                   size: 14, color: dark3),
              //               onTap: () => _launchURL(resource['url']),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(8),
              //               ),
              //               tileColor: white,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildFAQCard(String question, String answer, IconData icon) {
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     decoration: BoxDecoration(
  //       color: white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.05),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: ListTile(
  //       contentPadding: const EdgeInsets.all(16),
  //       leading: Container(
  //         padding: const EdgeInsets.all(8),
  //         decoration: BoxDecoration(
  //           color: green1.withValues(alpha: 0.1),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Icon(icon, color: green1, size: 20),
  //       ),
  //       title: Text(
  //         question,
  //         style: semibold14.copyWith(color: dark1),
  //       ),
  //       trailing: Icon(Icons.arrow_forward_ios, size: 16, color: dark3),
  //       onTap: () => _showFAQDetail(question, answer),
  //     ),
  //   );
  // }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: regular14.copyWith(color: dark2)),
          Text(value, style: semibold14.copyWith(color: dark1)),
        ],
      ),
    );
  }
}
