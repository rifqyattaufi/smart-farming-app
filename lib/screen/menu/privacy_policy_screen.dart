import 'package:flutter/material.dart';
import 'package:smart_farming_app/theme.dart';
import 'package:smart_farming_app/widget/header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        title: const Header(
            headerType: HeaderType.menu,
            title: 'Pengaturan Lainnya',
            greeting: 'Kebijakan Privasi'),
      ),
      body: SingleChildScrollView(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami menghargai privasi Anda dan berkomitmen untuk melindungi informasi pribadi yang Anda berikan kepada kami. Kebijakan privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda saat Anda menggunakan aplikasi Smart Farming App - FarmCenter ("Aplikasi", "kami").',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '1. Informasi yang Kami Kumpulkan',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami dapat mengumpulkan informasi pribadi yang Anda berikan kepada kami saat Anda mendaftar untuk menggunakan Aplikasi. Data tersebut yakni:\n\n• Data Pribadi: Nama, email, nomor telepon, akun Google (jika login Google digunakan).\n\n• Data Ternak dan Tanaman Budidaya: Jenis ternak dan tanaman, jumlah ternak dan tanaman, penempatan pada kandang dan kebun, dan hal-hal terkait ternak.\n\n• Data Kandang dan kebun: Jenis kandang dan kebun, ukuran kandang dan kebun, lokasi kandang dan kebun.\n\n• Data Hama: Jenis hama dan data hama yang ada pada form pelaporan hama.\n\n• Data Aktivitas: Riwayat aktivitas pemeliharaan ternak dan kebun.\n\n• Data Inventaris: Data item dan hasil panen yang ditambahkan pada Aplikasi beserta kategori dan satuannya.\n\n• Data Pengguna: Informasi tentang pengguna lain yang Anda tambahkan ke Aplikasi.\n\n• Data Pelaporan: Data aktivitas perkebunan dan peternakan, laporan panen, laporan penyakit tanaman/hewan., laporan kematian, laporan pemberian nutrisi, dan data pelaporan lainnya.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '2. Cara Kami Menggunakan Data Anda',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami menggunakan data Anda untuk memberikan layanan yang lebih baik kepada Anda, termasuk:\n\n• Mengelola akun pengguna.\n\n• Memungkinkan Anda untuk mengelola data ternak dan tanaman budidaya Anda.\n\n• Memberikan informasi dan pembaruan terkait Aplikasi.\n\n• Menganalisis penggunaan Aplikasi untuk meningkatkan pengalaman pengguna.\n\n• Mengirimkan notifikasi terkait aktivitas yang terjadi pada Aplikasi.\n\n• Mengelola laporan hama, penyakit, dan kematian pada ternak dan tanaman budidaya Anda.\n\n• Mengelola laporan aktivitas pemeliharaan ternak dan kebun Anda.\n\n• Mengelola laporan panen, laporan penyakit tanaman/hewan., laporan kematian, laporan pemberian nutrisi, dan data pelaporan lainnya.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '3. Pengungkapan ke Pihak Ketiga',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami dapat membagikan data Anda kepada pihak ketiga dalam situasi berikut:\n\n• Dengan izin Anda: Kami akan meminta izin Anda sebelum membagikan data pribadi Anda dengan pihak ketiga.\n\n• Penyedia Layanan: Kami dapat menggunakan penyedia layanan pihak ketiga untuk membantu kami mengelola Aplikasi dan memberikan layanan kepada Anda. Penyedia layanan ini hanya akan memiliki akses terbatas ke data pribadi Anda sesuai dengan kebutuhan mereka untuk menjalankan layanan tersebut.\n\n• Kewajiban Hukum: Kami dapat mengungkapkan data pribadi Anda jika diwajibkan oleh hukum atau jika kami percaya bahwa tindakan tersebut diperlukan untuk mematuhi hukum yang berlaku, melindungi hak-hak kami, atau melindungi keselamatan pengguna lain.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '4. Penyimpanan dan Keamanan Data',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami akan menyimpan data pribadi Anda selama diperlukan untuk memenuhi tujuan yang dijelaskan dalam kebijakan privasi ini. Kami akan mengambil langkah-langkah yang wajar untuk melindungi data pribadi Anda dari akses yang tidak sah, penggunaan, atau pengungkapan. Namun, tidak ada metode transmisi melalui internet atau metode penyimpanan elektronik yang sepenuhnya aman.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '5. Hak Anda',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Sebagai pengguna, Anda memiliki hak untuk:\n\n• Mengakses data pribadi Anda: Anda berhak meminta salinan data pribadi yang kami miliki tentang Anda.\n\n• Memperbaiki data pribadi Anda: Jika Anda percaya bahwa data pribadi yang kami miliki tentang Anda tidak akurat atau tidak lengkap, Anda berhak meminta perbaikan.\n\n• Menghapus data pribadi Anda: Dalam beberapa situasi, Anda dapat meminta penghapusan data pribadi yang kami miliki tentang Anda.\n\n• Menarik persetujuan: Jika kami memproses data pribadi Anda berdasarkan persetujuan, Anda berhak menarik persetujuan tersebut kapan saja.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '6. Perubahan pada Kebijakan Privasi',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan tersebut dengan memposting versi terbaru di Aplikasi. Kami mendorong Anda untuk secara berkala meninjau kebijakan privasi ini untuk tetap mendapatkan informasi terbaru tentang cara kami melindungi data pribadi Anda.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '7. Kontak Kami',
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Terima kasih telah menggunakan Aplikasi Smart Farming App - FarmCenter. Kami berkomitmen untuk melindungi privasi Anda dan memberikan pengalaman pengguna yang aman dan menyenangkan.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'End-User License Agreement (EULA)',
                  style: medium20.copyWith(color: dark1),
                ),
              ),
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
                  '1. Lisensi',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Dengan mengunduh dan menggunakan Aplikasi Smart Farming App - FarmCenter ("Aplikasi"), Anda setuju untuk mematuhi syarat dan ketentuan yang tercantum dalam Perjanjian Lisensi Pengguna Akhir ini ("EULA"). Jika Anda tidak setuju dengan syarat dan ketentuan ini, harap jangan mengunduh atau menggunakan Aplikasi ini.\n\nKami memberikan kepada Anda lisensi terbatas, tidak eksklusif, tidak dapat dipindahtangankan, dan tidak dapat disublisensikan untuk mengunduh, menginstal, dan menggunakan Aplikasi ini untuk tujuan pribadi dan non-komersial.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '2. Pembatasan',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Anda setuju untuk tidak:\n\n• Mengubah, mendistribusikan, menjual, atau menyewakan Aplikasi ini kepada pihak ketiga.\n\n• Menggunakan Aplikasi ini untuk tujuan ilegal atau melanggar hukum.\n\n• Menghapus atau mengubah hak cipta, merek dagang, atau pemberitahuan kepemilikan lainnya yang terdapat dalam Aplikasi ini.\n\n• Menggunakan Aplikasi ini dengan cara yang dapat merusak, menonaktifkan, membebani, atau mengganggu server atau jaringan kami.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '3. Hak Kekayaan Intelektual',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Semua hak kekayaan intelektual yang terkait dengan Aplikasi ini, termasuk tetapi tidak terbatas pada hak cipta, merek dagang, dan paten, adalah milik kami atau pemilik lisensinya. Anda tidak memiliki hak atau kepentingan dalam hak kekayaan intelektual tersebut.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '4. Pembatasan Tanggung Jawab',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Aplikasi ini disediakan "sebagaimana adanya" tanpa jaminan atau garansi apa pun, baik tersurat maupun tersirat. Kami tidak bertanggung jawab atas kerugian atau kerusakan yang timbul dari penggunaan atau ketidakmampuan untuk menggunakan Aplikasi ini.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '5. Pemutusan Lisensi',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami berhak untuk memutuskan lisensi ini kapan saja jika Anda melanggar syarat dan ketentuan EULA ini. Setelah pemutusan lisensi, Anda harus segera menghentikan penggunaan Aplikasi ini dan menghapusnya dari perangkat Anda.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '6. Perubahan pada EULA',
                  style: medium16.copyWith(color: dark1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  'Kami dapat memperbarui EULA ini dari waktu ke waktu. Kami akan memberi tahu Anda tentang perubahan tersebut dengan memposting versi terbaru di Aplikasi. Kami mendorong Anda untuk secara berkala meninjau EULA ini untuk tetap mendapatkan informasi terbaru tentang syarat dan ketentuan yang berlaku.',
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
                  'EULA ini diatur oleh dan ditafsirkan sesuai dengan hukum yang berlaku di negara tempat kami beroperasi. Setiap sengketa yang timbul dari EULA ini akan diselesaikan di pengadilan yang berwenang di negara tersebut.',
                  style: regular14.copyWith(color: dark1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
