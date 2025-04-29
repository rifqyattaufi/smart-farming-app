import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

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
              title: 'Pengaturan Lainnya',
              greeting: 'Syarat dan Ketentuan'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'Tanggal berlaku: 28 April 2025',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '1. Persetujuan',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Dengan menggunakan aplikasi ini, Anda setuju untuk mematuhi syarat dan ketentuan yang berlaku. Jika Anda tidak setuju dengan syarat dan ketentuan ini, harap tidak menggunakan aplikasi ini.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '2. Akun Pengguna',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda dan bertanggung jawab atas semua aktivitas yang terjadi di akun Anda.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '3. Penggunaan Aplikasi',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Anda setuju untuk tidak menggunakan aplikasi ini untuk tujuan ilegal atau dilarang oleh syarat dan ketentuan ini. Penggunaan aplikasi ini harus sesuai dengan hukum yang berlaku di wilayah Anda. Dilarang untuk mengakses, mengubah, atau merusak aplikasi ini tanpa izin yang sah.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '4. Layanan Pihak Ketiga',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Aplikasi ini menggunakana layanan pihak ketiga untuk mendukung fungsionalitas tertentu.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '5. Pembatasan Tanggung Jawab',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Kami tidak bertanggung jawab atas kerugian atau kerusakan yang timbul akibat penggunaan aplikasi ini. Penggunaan aplikasi ini sepenuhnya merupakan risiko Anda sendiri.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '6. Perubahan Syarat dan Ketentuan',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Kami berhak untuk mengubah syarat dan ketentuan ini kapan saja. Perubahan akan diberitahukan melalui aplikasi ini. Dengan terus menggunakan aplikasi ini setelah perubahan, Anda setuju untuk terikat oleh syarat dan ketentuan yang telah diperbarui.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '7. Hukum yang Berlaku',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Syarat dan ketentuan ini diatur oleh hukum yang berlaku di negara Anda. Setiap sengketa yang timbul dari syarat dan ketentuan ini akan diselesaikan di pengadilan yang berwenang.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '8. Penutupan Akun',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Kami berhak menangguhkan atau menghapus akun jika Anda melanggar syarat ini.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '9. Kontak',
                    style: medium16.copyWith(color: dark1),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Jika Anda memiliki pertanyaan atau komentar tentang kebijakan privasi ini, silakan hubungi kami di:\n\n• Email: farmcenter@telkomuniversity.ac.id\n\n• Telepon: +62-xxx-xxxx-xxxx\n\n• Alamat: Jl. Ketintang No.156 Surabaya, Jawa Timur.',
                    style: regular14.copyWith(color: dark1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
