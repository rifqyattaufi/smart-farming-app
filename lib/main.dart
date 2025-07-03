import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smart_farming_app/screen/komoditas/detail_komoditas_screen.dart';
import 'package:smart_farming_app/screen/login/reset_password_screen.dart';
import 'package:smart_farming_app/screen/main_screen_petugas.dart';
import 'package:toastification/toastification.dart';
import 'package:smart_farming_app/firebase_options.dart';
import 'package:smart_farming_app/model/notifikasi_model.dart';
import 'package:smart_farming_app/screen/blank_screen.dart';
import 'package:smart_farming_app/screen/grade/add_grade_screen.dart';
import 'package:smart_farming_app/screen/grade/grade_screen.dart';
import 'package:smart_farming_app/screen/hama/add_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/add_laporan_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/detail_hama_screen.dart';
import 'package:smart_farming_app/screen/hama/hama_screen.dart';
import 'package:smart_farming_app/screen/notifications/add_global_notification.dart';
import 'package:smart_farming_app/screen/notifications/notification_management_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pilih_komoditas_tanaman_screen.dart';
import 'package:smart_farming_app/screen/laporan/statistik_tanaman_report.dart';
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
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_harian_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_mati_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_nutrisi_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_sakit_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_harian_tanaman_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_tindakan_massal_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/tanaman/pelaporan_harian_tanaman_tabel_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_harian_ternak_screen.dart';
import 'package:smart_farming_app/screen/pelaporan/detail/detail_laporan_panen_ternak_screen.dart';
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
import 'package:smart_farming_app/screen/laporan/statistik_ternak_report.dart';
import 'package:smart_farming_app/screen/tanaman/add_tanaman_screen.dart';
import 'package:smart_farming_app/screen/tanaman/detail_tanaman_screen.dart';
import 'package:smart_farming_app/screen/tanaman/tanaman_screen.dart';
import 'package:smart_farming_app/screen/ternak/add_ternak_screen.dart';
import 'package:smart_farming_app/screen/ternak/detail_ternak_screen.dart';
import 'package:smart_farming_app/screen/ternak/ternak_screen.dart';
import 'package:smart_farming_app/screen/users/add_user_screen.dart';
import 'package:smart_farming_app/screen/users/detail_user_screen.dart';
import 'package:smart_farming_app/screen/users/users_screen.dart';
import 'package:smart_farming_app/service/database_helper.dart';
import 'package:smart_farming_app/service/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  if (message.messageId != null && message.notification != null) {
    final notifikasi = NotifikasiModel(
      id: message.messageId!,
      title: message.notification?.title ?? 'Tanpa Judul',
      message: message.notification?.body ?? 'Tidak ada pesan',
      receivedAt: message.sentTime ?? DateTime.now(),
      isRead: false,
      notificationType: message.data['notificationType'] as String?,
      payload: jsonEncode(message.data),
    );
    await dbHelper.insertNotification(notifikasi);
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _requestNotificationPermissions() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    announcement: false,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'smart_farming_default_channel_id', 'Smart Farming Notifications',
      description: 'Channel untuk notifikasi umum aplikasi Smart Farming.',
      importance: Importance.high);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

late FcmService fcmService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      if (notificationResponse.payload != null &&
          notificationResponse.payload!.isNotEmpty) {
        // Di sini Anda akan memanggil fungsi global atau fungsi dari FcmService/NavigationService
        // untuk menangani navigasi berdasarkan payload.
        // Contoh: handleNotificationTap(jsonDecode(notificationResponse.payload!));
      }
      // Callback ketika notifikasi (yang di-tap dari background) di-handle oleh plugin ini
      // (biasanya FCM `onMessageOpenedApp` lebih umum digunakan untuk ini)
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    },
  );

  await _requestNotificationPermissions();
  await dotenv.load(fileName: ".env");

  fcmService = FcmService(flutterLocalNotificationsPlugin);
  await fcmService.initFCM();

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

// (Opsional) Handler untuk tap notifikasi lokal dari background jika menggunakan flutter_local_notifications
// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {
//   print('Background Local Notification Tapped (via flutter_local_notifications): ${notificationResponse.payload}');
//   // Logic serupa dengan onDidReceiveNotificationResponse
// }

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
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
    ShellRoute(
        builder: (context, state, child) => MainScreenPetugas(child: child),
        routes: [
          GoRoute(
            path: '/home-petugas',
            builder: (context, state) => const HomeScreenPetugas(),
          ),
          GoRoute(
              path: '/inventory-petugas',
              builder: (context, state) => const InventoryScreen()),
          GoRoute(
            path: '/account-petugas',
            builder: (context, state) => const AccountScreen(),
          )
        ]),
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
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as ResetPasswordScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/verifikasi-otp',
      builder: (context, state) {
        final extra = state.extra as OtpScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pilih-tanaman',
      builder: (context, state) {
        final extra = state.extra as PilihTanamanScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pilih-ternak',
      builder: (context, state) {
        final extra = state.extra as PilihTernakScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pilih-kebun',
      builder: (context, state) {
        final extra = state.extra as PilihKebunScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pilih-kandang',
      builder: (context, state) {
        final extra = state.extra as PilihKandangScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pilih-komoditas-tanaman',
      builder: (context, state) {
        final extra = state.extra as PilihKomoditasTanamanScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pilih-komoditas',
      builder: (context, state) {
        final extra = state.extra as PilihKomoditasScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/manajemen-komoditas',
      builder: (context, state) => const KomoditasScreen(),
    ),
    GoRoute(
      path: '/pelaporan-harian-tanaman',
      builder: (context, state) {
        final extra = state.extra as PelaporanHarianTanamanScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pelaporan-tindakan-massal',
      builder: (context, state) {
        final extra = state.extra as PelaporanTindakanMassalScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pelaporan-harian-tanaman-tabel',
      builder: (context, state) {
        final extra = state.extra as PelaporanHarianTanamanTabelScreen;
        return extra;
      },
    ),
    GoRoute(
        path: '/detail-laporan-harian-tanaman/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return DetailLaporanHarianScreen(
            idLaporanHarian: id,
          );
        }),
    GoRoute(
      path: '/pelaporan-harian-ternak',
      builder: (context, state) {
        final extra = state.extra as PelaporanHarianTernakScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-laporan-harian-ternak/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailLaporanHarianTernakScreen(
          idLaporanHarianTernak: id,
        );
      },
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
      builder: (context, state) {
        final extra = state.extra as PelaporanNutrisiTanamanScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-laporan-nutrisi-tanaman/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailLaporanNutrisiScreen(
          idLaporanNutrisi: id,
        );
      },
    ),
    GoRoute(
      path: '/pelaporan-nutrisi-ternak',
      builder: (context, state) {
        final extra = state.extra as PelaporanNutrisiTernakScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pelaporan-kematian-ternak',
      builder: (context, state) {
        final extra = state.extra as PelaporanKematianTernakScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pelaporan-tanaman-mati',
      builder: (context, state) {
        final extra = state.extra as PelaporanTanamanMatiScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-laporan-mati-tanaman/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailLaporanMatiScreen(
          idLaporanMati: id,
        );
      },
    ),
    GoRoute(
      path: '/pelaporan-panen-tanaman',
      builder: (context, state) {
        final extra = state.extra as PelaporanTanamanPanenScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/pelaporan-panen-ternak',
      builder: (context, state) {
        final extra = state.extra as PelaporanTernakPanenScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-laporan-panen-ternak/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailLaporanPanenTernakScreen(
          idLaporanPanenTernak: id,
        );
      },
    ),
    GoRoute(
      path: '/pelaporan-tanaman-sakit',
      builder: (context, state) {
        final extra = state.extra as PelaporanTanamanSakitScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-laporan-sakit-tanaman/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailLaporanSakitScreen(
          idLaporanSakit: id,
        );
      },
    ),
    GoRoute(
      path: '/pelaporan-ternak-sakit',
      builder: (context, state) {
        final extra = state.extra as PelaporanTernakSakitScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail',
      builder: (context, state) => const BlankScreen(),
    ),
    GoRoute(
      path: '/statistik-laporan-tanaman/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return StatistikTanamanReport(
          idTanaman: id,
        );
      },
    ),
    GoRoute(
      path: '/statistik-laporan-ternak/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return StatistikTernakReport(
          idTernak: id,
        );
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
      builder: (context, state) {
        final extra = state.extra as AddTanamanScreen;
        return extra;
      },
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
      builder: (context, state) {
        final extra = state.extra as AddKategoriInvScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/kategori-inventaris',
      builder: (context, state) => const KategoriInvScreen(),
    ),
    GoRoute(
      path: '/tambah-grade',
      builder: (context, state) {
        final extra = state.extra as AddGradeScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/manajemen-grade',
      builder: (context, state) => const GradeScreen(),
    ),
    GoRoute(
      path: '/tambah-inventaris',
      builder: (context, state) {
        final extra = state.extra as AddInventarisScreen;
        return extra;
      },
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
      builder: (context, state) {
        final extra = state.extra as AddKomoditasTanamanScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-komoditas/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailKomoditasScreen(
          idKomoditas: id,
        );
      },
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
      path: '/detail-inventaris/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailInventarisScreen(
          idInventaris: id,
        );
      },
    ),
    GoRoute(
      path: '/detail-pemakaian-inventaris/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailPemakaianInventarisScreen(
          idPemakaianInventaris: id,
        );
      },
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
        path: '/detail-kebun/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return DetailKebunScreen(
            idKebun: id,
          );
        }),
    GoRoute(
      path: '/detail-tanaman/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailTanamanScreen(
          idTanaman: id,
        );
      },
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
      path: '/detail-kandang/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailKandangScreen(
          idKandang: id,
        );
      },
    ),
    GoRoute(
      path: '/detail-kandang',
      builder: (context, state) => const DetailKandangScreen(),
    ),
    GoRoute(
      path: '/detail-ternak/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailTernakScreen(
          idTernak: id,
        );
      },
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
      path: '/detail-global-notification',
      builder: (context, state) {
        final extra = state.extra as DetailNotifScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/manajemen-notifikasi',
      builder: (context, state) => const NotificationManagementScreen(),
    ),
    GoRoute(
        path: '/add-global-notification',
        builder: (context, state) {
          final extra = state.extra as AddGlobalNotification;
          return extra;
        }),
    GoRoute(
      path: '/manajemen-pengguna',
      builder: (context, state) => const UsersScreen(),
    ),
    GoRoute(
      path: '/detail-pengguna',
      builder: (context, state) {
        final extra = state.extra as DetailUserScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/detail-pengguna',
      builder: (context, state) => const DetailUserScreen(),
    ),
    GoRoute(
      path: '/tambah-pengguna',
      builder: (context, state) {
        final extra = state.extra as AddUserScreen;
        return extra;
      },
    ),
    GoRoute(
      path: '/laporan-hama',
      builder: (context, state) => const HamaScreen(),
    ),
    GoRoute(
      path: '/detail-laporan-hama/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailHamaScreen(
          idLaporanHama: id,
        );
      },
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
      builder: (context, state) {
        final extra = state.extra as AddHamaScreen;
        return extra;
      },
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
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Smart Farming App',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
