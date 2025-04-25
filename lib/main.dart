import 'package:flutter/material.dart';
import 'package:smart_farming_app/screen/detail_laporan_screen.dart';
import 'package:smart_farming_app/screen/detail_screen.dart';
import 'package:smart_farming_app/screen/main_screen.dart';
import 'package:smart_farming_app/screen/menu/home_screen.dart';
import 'package:smart_farming_app/screen/menu/report_screen.dart';
import 'package:smart_farming_app/screen/menu/inventory_screen.dart';
import 'package:smart_farming_app/screen/menu/account_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
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
      path: '/detail',
      builder: (context, state) => const DetailScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const DetailScreen(),
    ),
    GoRoute(
      path: '/laporan-inventaris',
      builder: (context, state) => const DetailScreen(),
    ),
    GoRoute(
      path: '/detail-laporan/:name',
      builder: (context, state) {
        final name = state.pathParameters['name']!;
        return DetailLaporanScreen(name: name);
      },
    )
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
