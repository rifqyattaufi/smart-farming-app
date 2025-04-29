import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/screen/hama/add_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/add_laporan_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/hama_screen.dart';
import 'package:smart_farming_app/screen/introduction.dart';
import 'package:smart_farming_app/screen/inventaris/add_pemakaian_inventaris_screen.dart';
import 'package:smart_farming_app/screen/inventaris/riwayat_pemakaian_screen.dart';
import 'package:smart_farming_app/screen/inventaris/inventaris_screen.dart';
import 'package:smart_farming_app/screen/kandang/kandang_screen.dart';
import 'package:smart_farming_app/screen/kebun/kebun_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/komoditas/add_komoditas_ternak_screen.dart';
import 'package:smart_farming_app/screen/login/login_screen.dart';
import 'package:smart_farming_app/screen/main_screen.dart';
import 'package:smart_farming_app/screen/menu/home_screen.dart';
import 'package:smart_farming_app/screen/menu/petugas/home_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_harian_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_khusus_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_nutrisi_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_tanaman_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_tanaman_panen_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_tanaman_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pilih_kandang_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pilih_kebun_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pelaporan_khusus_tanaman_screen.dart';
import 'package:smart_farming_app/screen/menu/privacy_policy_screen.dart';
import 'package:smart_farming_app/screen/menu/report_screen.dart';
import 'package:smart_farming_app/screen/menu/inventory_screen.dart';
import 'package:smart_farming_app/screen/menu/account_screen.dart';
import 'package:smart_farming_app/screen/kebun/add_kebun_screen.dart';
import 'package:smart_farming_app/screen/kandang/add_kandang_screen.dart';
import 'package:smart_farming_app/screen/menu/terms_condition_screen.dart';
import 'package:smart_farming_app/screen/notifications/notification_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/pilih_tanaman_screen.dart';
import 'package:smart_farming_app/screen/riwayat_aktivitas/log_screen.dart';
import 'package:smart_farming_app/screen/riwayat_aktivitas/riwayat_aktivitas_screen.dart';
import 'package:smart_farming_app/screen/satuan/add_satuan_screen.dart';
import 'package:smart_farming_app/screen/satuan/satuan_screen.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/screen/tanaman/tanaman_screen.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/screen/inventaris/add_inventaris_screen.dart';
import 'package:smart_farming_app/screen/kategory_inv/add_kategori_inv_screen.dart';
import 'package:smart_farming_app/screen/detail_laporan_screen.dart';
import 'package:smart_farming_app/screen/blank_screen.dart';
import 'package:smart_farming_app/screen/ternak/ternak_screen.dart';
import 'package:smart_farming_app/screen/users/add_user_screen.dart';
import 'package:smart_farming_app/screen/users/users_screen.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/ss',
          builder: (context, state) => const HomeScreen(),
        ),
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
      path: '/',
      builder: (context, state) => const Introduction(),
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
      path: '/pilih-tanaman',
      builder: (context, state) => const PilihTanamanScreen(),
    ),
    GoRoute(
      path: '/pilih-kebun',
      builder: (context, state) => const PilihKebunScreen(),
    ),
    GoRoute(
      path: '/pilih-kandang',
      builder: (context, state) => const PilihKandangScreen(),
    ),
    GoRoute(
      path: '/pelaporan-harian-tanaman',
      builder: (context, state) => const PelaporanHarianTanamanScreen(),
    ),
    GoRoute(
      path: '/pelaporan-harian-ternak',
      builder: (context, state) => const PelaporanHarianTernakScreen(),
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
      path: '/pelaporan-tanaman-mati',
      builder: (context, state) => const PelaporanTanamanMatiScreen(),
    ),
    GoRoute(
      path: '/pelaporan-tanaman-panen',
      builder: (context, state) => const PelaporanTanamanPanenScreen(),
    ),
    GoRoute(
      path: '/pelaporan-tanaman-sakit',
      builder: (context, state) => const PelaporanTanamanSakitScreen(),
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
      builder: (context, state) => const AddKebunScreen(),
    ),
    GoRoute(
      path: '/tambah-tanaman',
      builder: (context, state) => const AddTanamanScreen(),
    ),
    GoRoute(
      path: '/tambah-kandang',
      builder: (context, state) => const AddKandangScreen(),
    ),
    GoRoute(
      path: '/tambah-ternak',
      builder: (context, state) => const AddTernakScreen(),
    ),
    GoRoute(
      path: '/tambah-kategori-inventaris',
      builder: (context, state) => const AddKategoriInvScreen(),
    ),
    GoRoute(
      path: '/tambah-inventaris',
      builder: (context, state) => const AddInventarisScreen(),
    ),
    GoRoute(
      path: '/tambah-satuan',
      builder: (context, state) => const AddSatuanScreen(),
    ),
    GoRoute(
      path: '/tambah-pemakaian-inventaris',
      builder: (context, state) => const AddPemakaianInventarisScreen(),
    ),
    GoRoute(
      path: '/tambah-komoditas-ternak',
      builder: (context, state) => const AddKomoditasTernakScreen(),
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
      path: '/manajemen-satuan',
      builder: (context, state) => const SatuanScreen(),
    ),
    GoRoute(
      path: '/manajemen-kebun',
      builder: (context, state) => const KebunScreen(),
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
      path: '/manajemen-ternak',
      builder: (context, state) => const TernakScreen(),
    ),
    GoRoute(
      path: '/notifikasi',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/manajemen-pengguna',
      builder: (context, state) => const UsersScreen(),
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
      path: '/tambah-laporan-hama',
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
