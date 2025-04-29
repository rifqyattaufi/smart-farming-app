import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();

    // Inisialisasi AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Durasi animasi
    );

    // Inisialisasi animasi scale
    _animation = Tween<double>(begin: 0.9, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Mulai animasi
    _controller.forward();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulasi delay untuk menampilkan animasi splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Cek apakah refresh token masih valid
    final isRefreshTokenValid = await _authService.refreshToken();
    if (!isRefreshTokenValid) {
      await _authService.logout();
      context.go('/login'); // Redirect ke login jika token expired
      return;
    }

    // Cek role pengguna dan arahkan ke halaman sesuai role
    final role = await _authService.getUserRole();
    // if (role == 'admin') {
    //   context.go('/home'); // Halaman untuk admin
    // } else if (role == 'pjawab') {
    //   context.go('/home-petugas'); // Halaman untuk penanggung jawab
    // } else {
    //   context.go('/home'); // Default halaman
    // }
    context.go('/home'); // Default halaman
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Image.asset(
                'assets/images/logo.png',
                width: 150, // Ukuran awal logo
                height: 150,
              ),
            );
          },
        ),
      ),
    );
  }
}
