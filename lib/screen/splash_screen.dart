import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farming_app/service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  bool _noInternet = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.9, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Mulai navigasi setelah animasi
    _navigateToNextScreen();
  }

  Future<bool> hasRealInternet() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com/generate_204'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  Future<void> _navigateToNextScreen() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // Cek status jaringan dulu
    await Future.delayed(const Duration(seconds: 2));
    if (connectivityResult
        .every((result) => result == ConnectivityResult.none)) {
      setState(() {
        _noInternet = true;
      });
      return;
    }

    // Cek benar-benar ada akses internet
    final realInternet = await hasRealInternet();
    if (!realInternet) {
      setState(() {
        _noInternet = true;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
      if (!mounted) return;
      context.go('/introduction');
      return;
    }

    // Cek validitas token
    final isRefreshTokenValid = await _authService.refreshToken();
    if (!isRefreshTokenValid) {
      await _authService.logout();
      if (!mounted) return;
      context.go('/login');
      return;
    }

    // Cek role pengguna dan arahkan ke halaman sesuai role
    // final role = await _authService.getUserRole();
    if (!mounted) return;
    // if (role == 'admin') {
    //   context.go('/home'); // Halaman untuk admin
    // } else if (role == 'pjawab') {
    //   context.go('/home-petugas'); // Halaman untuk penanggung jawab
    // } else {
    //   context.go('/home'); // Default halaman
    // }
    context.go('/home'); // Atur sesuai role jika diperlukan
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
      body: Stack(
        children: [
          // Logo selalu di tengah layar
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                );
              },
            ),
          ),
          // Pesan error di bawah logo, tetap di tengah layar
          if (_noInternet)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 64),
                child: Text(
                  'Ups! Tidak ada koneksi internet.\nSilakan periksa jaringan Anda dan coba lagi.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
