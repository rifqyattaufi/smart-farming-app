import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/blank_screen.dart';
import 'package:smart_farming_app/screen/hama/add_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/add_laporan_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/detail_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/hama_screen.dart';
import 'package:smart_farming_app/screen/harvest_report.dart';
import 'package:smart_farming_app/screen/introduction.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/screen/inventaris/add_pemakaian_inventaris_screen.dart';
import 'package:smart_farming_app/screen/inventaris/detail_inventaris_screen.dart';
import 'package:smart_farming_app/screen/inventaris/detail_pemakaian_inventaris_screen.dart';
import 'package:smart_farming_app/screen/inventaris/riwayat_pemakaian_screen.dart';
import 'package:smart_farming_app/screen/inventaris/inventaris_screen.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/screen/kandang/detail_kandang_screen.dart';
import 'package:smart_farming_app/screen/kandang/kandang_screen.dart';
import 'package:smart_farming_app/screen/kategory_inv/add_kategori_inv_screen.dart';
import 'package:smart_farming_app/screen/kategory_inv/kategori_inv_screen.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/screen/kebun/detail_kebun_screen.dart';
import 'package:smart_farming_app/screen/kebun/kebun_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_ternak_screen.dart';
import 'package:smart_farming_app/screen/komoditas/komoditas_screen.dart';
import 'package:smart_farming_app/screen/login/login_screen.dart';
import 'package:smart_farming_app/screen/login/lupa_password_screen.dart';
import 'package:smart_farming_app/screen/login/otp_screen.dart';
import 'package:smart_farming_app/screen/main_screen.dart';
import 'package:smart_farming_app/screen/menu/home_screen.dart';
import 'package:smart_farming_app/screen/menu/petugas/home_screen.dart';
import 'package:smart_farming_app/screen/notifications/detail_notif_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/detail/detail_laporan_harian_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/detail/detail_laporan_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/detail/detail_laporan_nutrisi_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/detail/detail_laporan_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/detail/detail_laporan_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_harian_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_jenis_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/detail/detail_laporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/detail/detail_laporan_mati_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/detail/detail_laporan_nutrisi_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/detail/detail_laporan_panen_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/detail/detail_laporan_sakit_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_kematian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_khusus_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_nutrisi_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_nutrisi_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tanaman_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_ternak_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pelaporan_ternak_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_kandang_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_khusus_tanaman_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_farming_app/screen/detail_laporan_screen.dart';
import 'package:smart_farming_app/screen/menu/privacy_policy_screen.dart';
import 'package:smart_farming_app/screen/menu/report_screen.dart';
import 'package:smart_farming_app/screen/menu/inventory_screen.dart';
import 'package:smart_farming_app/screen/menu/account_screen.dart';
import 'package:smart_farming_app/screen/menu/terms_condition_screen.dart';
import 'package:smart_farming_app/screen/notifications/notification_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_komoditas_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/ternak/pilih_ternak_screen.dart';
import 'package:smart_farming_app/screen/riwayat_aktivitas/log_screen.dart';
import 'package:smart_farming_app/screen/riwayat_aktivitas/riwayat_aktivitas_screen.dart';
import 'package:smart_farming_app/screen/satuan/add_satuan_screen.dart';
import 'package:smart_farming_app/screen/satuan/satuan_screen.dart';
import 'package:smart_farming_app/screen/splash_screen.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/screen/tanaman/detail_tanaman_screen.dart';
import 'package:smart_farming_app/screen/tanaman/tanaman_screen.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/screen/ternak/detail_ternak_screen.dart';
import 'package:smart_farming_app/screen/ternak/ternak_screen.dart';
import 'package:smart_farming_app/screen/users/add_user_screen.dart';
import 'package:smart_farming_app/screen/users/detail_user_screen.dart';
import 'package:smart_farming_app/screen/users/users_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/splash',
  // initialLocation: '/harvest',
  routes: [
    GoRoute(path: '/harvest', builder: (context, state) => const HarvestStatsScreen()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/report',
          builder: (context, state) => const ReportScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/introduction',
      builder: (context, state) => const Introduction(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/lupa-password',
      builder: (context, state) => const LupaPasswordScreen(),
    ),
    GoRoute(
      path: '/verifikasi-otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/pilih-tanaman',
      builder: (context, state) => const PilihTanamanScreen(),
    ),
    GoRoute(
      path: '/pilih-ternak',
      builder: (context, state) => const PilihTernakScreen(),
    ),
    GoRoute(
      path: '/pilih-kebun',
      builder: (context, state) => const PilihKebunScreen(),
    ),
    GoRoute(
      path: '/pilih-kebun-jenis',
      builder: (context, state) => const PilihKebunJenisScreen(),
    ),
    GoRoute(
      path: '/pilih-kandang',
      builder: (context, state) => const PilihKandangScreen(),
    ),
    GoRoute(
      path: '/pilih-komoditas',
      builder: (context, state) => const PilihKomoditasScreen(),
    ),
    GoRoute(
      path: '/manajemen-komoditas',
      builder: (context, state) => const KomoditasScreen(),
    ),
    GoRoute(
      path: '/pelaporan-harian-tanaman',
      builder: (context, state) => const PelaporanHarianTanamanScreen(),
    ),
    GoRoute(
        path: '/detail-laporan-harian-tanaman',
        builder: (context, state) => const DetailLaporanHarianScreen()),
    GoRoute(
      path: '/pelaporan-harian-ternak',
      builder: (context, state) => const PelaporanHarianTernakScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-harian-ternak',
      builder: (context, state) => const DetailLaporanHarianTernakScreen(),
    ),
    GoRoute(
      path: '/pelaporan-khusus-ternak',
      builder: (context, state) => const PelaporanKhususTernakScreen(),
    ),
    GoRoute(
      path: '/pelaporan-khusus-tanaman',
      builder: (context, state) => const PelaporanKhususTanamanScreen(),
    ),
    GoRoute(
      path: '/pelaporan-nutrisi-tanaman',
      builder: (context, state) => const PelaporanNutrisiTanamanScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-nutrisi-tanaman',
      builder: (context, state) => const DetailLaporanNutrisiScreen(),
    ),
    GoRoute(
      path: '/pelaporan-nutrisi-ternak',
      builder: (context, state) => const PelaporanNutrisiTernakScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-nutrisi-ternak',
      builder: (context, state) => const DetailLaporanNutrisiTernakScreen(),
    ),
    GoRoute(
      path: '/pelaporan-kematian-ternak',
      builder: (context, state) => const PelaporanKematianTernakScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-kematian-ternak',
      builder: (context, state) => const DetailLaporanMatiTernakScreen(),
    ),
    GoRoute(
      path: '/pelaporan-tanaman-mati',
      builder: (context, state) => const PelaporanTanamanMatiScreen(),
    ),
    GoRoute(
        path: '/detail-laporan-mati-tanaman',
        builder: (context, state) => const DetailLaporanMatiScreen()),
    GoRoute(
      path: '/pelaporan-panen-tanaman',
      builder: (context, state) => const PelaporanTanamanPanenScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-panen-tanaman',
      builder: (context, state) => const DetailLaporanPanenScreen(),
    ),
    GoRoute(
      path: '/pelaporan-panen-ternak',
      builder: (context, state) => const PelaporanTernakPanenScreen(),
    ),
    GoRoute(
        path: '/detail-laporan-panen-ternak',
        builder: (context, state) => const DetailLaporanPanenTernakScreen()),
    GoRoute(
      path: '/pelaporan-tanaman-sakit',
      builder: (context, state) => const PelaporanTanamanSakitScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-sakit-tanaman',
      builder: (context, state) => const DetailLaporanSakitScreen(),
    ),
    GoRoute(
      path: '/pelaporan-ternak-sakit',
      builder: (context, state) => const PelaporanTernakSakitScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-sakit-ternak',
      builder: (context, state) => const DetailLaporanSakitTernakScreen(),
    ),
    GoRoute(
      path: '/home-petugas',
      builder: (context, state) => const HomePetugasScreen(),
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) => const BlankScreen(),
    ),
    GoRoute(
      path: '/detail-laporan/:name',
      builder: (context, state) {
        final name = state.pathParameters['name']!;
        return DetailLaporanScreen(name: name);
      },
    ),
    GoRoute(
      path: '/tambah-kebun',
      builder: (context, state) {
        final extra = state.extra as AddKebunScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/tambah-tanaman',
      builder: (context, state) => const AddTanamanScreen(),
    ),
    GoRoute(
      path: '/tambah-kandang',
      builder: (context, state) {
        final extra = state.extra as AddKandangScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/tambah-ternak',
      builder: (context, state) {
        final extra = state.extra as AddTernakScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/tambah-kategori-inventaris',
      builder: (context, state) => const AddKategoriInvScreen(),
    ),
    GoRoute(
      path: '/kategori-inventaris',
      builder: (context, state) => const KategoriInvScreen(),
    ),
    GoRoute(
      path: '/tambah-inventaris',
      builder: (context, state) => const AddInventarisScreen(),
    ),
    GoRoute(
      path: '/tambah-satuan',
      builder: (context, state) {
        final extra = state.extra as AddSatuanScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/tambah-pemakaian-inventaris',
      builder: (context, state) => const AddPemakaianInventarisScreen(),
    ),
    GoRoute(
      path: '/tambah-komoditas-ternak',
      builder: (context, state) {
        final extra = state.extra as AddKomoditasTernakScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/tambah-komoditas-tanaman',
      builder: (context, state) => const AddKomoditasTanamanScreen(),
    ),
    GoRoute(
      path: '/riwayat-pemakaian-inventaris',
      builder: (context, state) => const RiwayatPemakaianScreen(),
    ),
    GoRoute(
      path: '/inventaris',
      builder: (context, state) => const InventarisScreen(),
    ),
    GoRoute(
      path: '/detail-inventaris',
      builder: (context, state) => const DetailInventarisScreen(),
    ),
    GoRoute(
      path: '/detail-pemakaian-inventaris',
      builder: (context, state) => const DetailPemakaianInventarisScreen(),
    ),
    GoRoute(
      path: '/manajemen-satuan',
      builder: (context, state) => const SatuanScreen(),
    ),
    GoRoute(
      path: '/manajemen-kebun',
      builder: (context, state) => const KebunScreen(),
    ),
    GoRoute(
      path: '/detail-kebun',
      builder: (context, state) => const DetailKebunScreen(),
    ),
    GoRoute(
      path: '/detail-jenis-tanaman',
      builder: (context, state) => const DetailTanamanScreen(),
    ),
    GoRoute(
      path: '/manajemen-jenis-tanaman',
      builder: (context, state) => const TanamanScreen(),
    ),
    GoRoute(
      path: '/manajemen-kandang',
      builder: (context, state) => const KandangScreen(),
    ),
    GoRoute(
      path: '/detail-kandang',
      builder: (context, state) => const DetailKandangScreen(),
    ),
    GoRoute(
      path: '/detail-ternak',
      builder: (context, state) => const DetailTernakScreen(),
    ),
    GoRoute(
      path: '/manajemen-ternak',
      builder: (context, state) => const TernakScreen(),
    ),
    GoRoute(
      path: '/notifikasi',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/detail-notifikasi',
      builder: (context, state) {
        final title = state.extra != null ? (state.extra as Map)['title'] : '';
        final date = state.extra != null ? (state.extra as Map)['date'] : '';
        final message = state.extra != null ? (state.extra as Map)['message'] : '';
        return DetailNotifScreen(title: title, date: date, message: message);
      },
    ),
    GoRoute(
      path: '/manajemen-pengguna',
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: '/detail-pengguna',
      builder: (context, state) => const DetailUserScreen(),
    ),
    GoRoute(
      path: '/tambah-pengguna',
      builder: (context, state) => const AddUserScreen(),
    ),
    GoRoute(
      path: '/laporan-hama',
      builder: (context, state) => const HamaScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-hama',
      builder: (context, state) => const DetailHamaScreen(),
    ),
    GoRoute(
      path: '/pelaporan-hama',
      builder: (context, state) => const AddLaporanHamaScreen(),
    ),
    GoRoute(
      path: '/tambah-hama',
      builder: (context, state) => const AddHamaScreen(),
    ),
    GoRoute(
      path: '/riwayat-aktivitas',
      builder: (context, state) => const RiwayatAktivitasScreen(),
    ),
    GoRoute(
      path: '/log-aktivitas',
      builder: (context, state) => const LogScreen(),
    ),
    GoRoute(
      path: '/kebijakan-privasi',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/syarat-dan-ketentuan',
      builder: (context, state) => const TermsConditionScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Farming App',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
